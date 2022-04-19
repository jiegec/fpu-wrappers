package fpuwrapper.formal

import chisel3._
import chisel3.stage.ChiselStage
import chisel3.util._
import fpuwrapper.ChiselEmitVerilog
import fpuwrapper.FloatH
import fpuwrapper.FloatType

class FMARequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val a = Vec(lanes, UInt(floatType.width.W))
  val b = Vec(lanes, UInt(floatType.width.W))
  val c = Vec(lanes, UInt(floatType.width.W))
}

class FMAResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.width.W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class IEEEFMAFormal(floatType: FloatType, lanes: Int, stages: Int)
    extends Module {
  val io = IO(new Bundle {
    val req = Flipped(Valid(new FMARequest(floatType, lanes)))
  })

  val zeros = WireInit(VecInit.fill(lanes)(0.U(floatType.width.W)))

  val hardfloat = Module(
    new fpuwrapper.hardfloat.IEEEFMA(floatType, lanes, stages)
  )
  hardfloat.io.req.valid := io.req.valid
  hardfloat.io.req.bits.op := fpuwrapper.hardfloat.FMAOp.FMADD
  hardfloat.io.req.bits.operands(0) := zeros
  hardfloat.io.req.bits.operands(1) := io.req.bits.b
  hardfloat.io.req.bits.operands(2) := io.req.bits.c

  val fudian = Module(
    new fpuwrapper.fudian.IEEEFMA(floatType, lanes, stages)
  )
  fudian.io.req.valid := io.req.valid
  fudian.io.req.bits.operands(0) := zeros
  fudian.io.req.bits.operands(1) := io.req.bits.b
  fudian.io.req.bits.operands(2) := io.req.bits.c

  chisel3.assert(
    hardfloat.io.resp.valid === fudian.io.resp.valid
  )
  when(hardfloat.io.resp.valid) {
    for (i <- 0 until lanes) {
      chisel3.assert(
        hardfloat.io.resp.bits.res(i) === fudian.io.resp.bits.res(i)
      )
    }
  }
}

object IEEEFMAFormal extends ChiselEmitVerilog {
  (new ChiselStage()).emitSystemVerilog(
    new IEEEFMAFormal(FloatH, 1, 1),
    Array("-o", "IEEEFMAFormal"),
    Seq()
  )
}
