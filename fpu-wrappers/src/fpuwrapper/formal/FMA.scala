package fpuwrapper.formal

import fpuwrapper.FloatType
import chisel3._
import chisel3.util._

class FMARequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val operands = Vec(3, Vec(lanes, UInt(floatType.width.W)))
}

class FMAResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.width.W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class FMAFormal(floatType: FloatType, lanes: Int, stages: Int) extends Module {
  val io = IO(new Bundle {
    val req = Flipped(Valid(new FMARequest(floatType, lanes)))
  })

  val hardfloat = Module(
    new fpuwrapper.hardfloat.IEEEFMA(floatType, lanes, stages)
  )
  hardfloat.io.req.valid := io.req.valid
  hardfloat.io.req.bits.op := fpuwrapper.hardfloat.FMAOp.FMADD
  hardfloat.io.req.bits.operands := io.req.bits.operands

  val fudian = Module(
    new fpuwrapper.fudian.FMA(floatType, lanes, stages)
  )
  fudian.io.req.valid := io.req.valid
  fudian.io.req.bits.operands := io.req.bits.operands

  assert(hardfloat.io.resp.valid === fudian.io.resp.valid)
}
