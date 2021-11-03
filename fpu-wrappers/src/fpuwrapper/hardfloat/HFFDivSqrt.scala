package fpuwrapper.hardfloat

import chisel3._
import chisel3.experimental.ChiselEnum
import chisel3.util._
import fpuwrapper.FloatType
import hardfloat.DivSqrtRecFN_small

object HFFDivSqrtOp extends ChiselEnum {
  val DIV = Value
  val SQRT = Value

  val NOP = DIV

  implicit def bitpat(op: HFFDivSqrtOp.Type): BitPat =
    BitPat(op.litValue().U)
}

class HFFDivSqrtRequest(val floatType: FloatType, val lanes: Int)
    extends Bundle {
  val op = HFFDivSqrtOp()
  val a = Vec(lanes, UInt(floatType.widthHardfloat.W))
  val b = Vec(lanes, UInt(floatType.widthHardfloat.W))
}

class HFFDivSqrtResponse(val floatType: FloatType, val lanes: Int)
    extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.widthHardfloat.W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class HFFDivSqrt(val floatType: FloatType, val lanes: Int)
    extends Module
    with RequireAsyncReset {
  val io = IO(new Bundle {
    val req = Flipped(Decoupled(new HFFDivSqrtRequest(floatType, lanes)))
    val resp = Valid(new HFFDivSqrtResponse(floatType, lanes))
  })

  // replicate small units for higher throughput
  val valid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    val div_sqrt = Module(
      new DivSqrtRecFN_small(
        floatType.exp(),
        floatType.sig(),
        0
      )
    )
    div_sqrt.suggestName(s"div_sqrt${floatType.kind()}_${i}")
    div_sqrt.io.a := io.req.bits.a(i)
    div_sqrt.io.b := io.req.bits.b(i)
    div_sqrt.io.inValid := io.req.valid

    // TODO
    div_sqrt.io.roundingMode := 0.U
    div_sqrt.io.detectTininess := 0.U

    val result = div_sqrt.io.out
    val exception = Wire(UInt(5.W))
    exception := div_sqrt.io.exceptionFlags
    div_sqrt.io.sqrtOp := io.req.bits.op === HFFDivSqrtOp.SQRT

    // lanes might not complete in the same cycle
    val resultReg = Reg(UInt(floatType.width().W))
    val exceptionReg = Reg(UInt(5.W))
    val resultValidReg = RegInit(false.B)
    val done = Wire(Bool())
    when(div_sqrt.io.outValid_div | div_sqrt.io.outValid_sqrt) {
      resultReg := result
      exceptionReg := exception
      resultValidReg := true.B
    }
    when(done) {
      resultValidReg := false.B
    }

    (
      resultReg,
      exceptionReg,
      resultValidReg,
      done,
      div_sqrt.io.inReady
    )
  }

  io.req.ready := results.map(_._5).reduce(_ & _)

  // collect result
  val res = results.map(_._1)
  // exception flags
  val exc = results.map(_._2)

  val resValid = results.map(_._3).reduce(_ & _)
  // all done
  for (lane <- results) {
    lane._4 := resValid
  }

  io.resp.valid := resValid
  io.resp.bits.res := res
  io.resp.bits.exc := exc
}
