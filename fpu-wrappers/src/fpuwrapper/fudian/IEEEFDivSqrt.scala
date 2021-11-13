package fpuwrapper.fudian

import chisel3._
import chisel3.experimental.ChiselEnum
import chisel3.util._
import fpuwrapper.FloatType

object IEEEFDivSqrtOp extends ChiselEnum {
  val DIV = Value
  val SQRT = Value

  val NOP = DIV

  implicit def bitpat(op: IEEEFDivSqrtOp.Type): BitPat =
    BitPat(op.litValue().U)
}

class IEEEFDivSqrtRequest(val floatType: FloatType, val lanes: Int)
    extends Bundle {
  val op = IEEEFDivSqrtOp()
  val a = Vec(lanes, UInt(floatType.width.W))
  val b = Vec(lanes, UInt(floatType.width.W))
}

class IEEEFDivSqrtResponse(val floatType: FloatType, val lanes: Int)
    extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.width.W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class IEEEFDivSqrt(val floatType: FloatType, val lanes: Int)
    extends Module
    with RequireAsyncReset {
  val io = IO(new Bundle {
    val req = Flipped(Decoupled(new IEEEFDivSqrtRequest(floatType, lanes)))
    val resp = Valid(new IEEEFDivSqrtResponse(floatType, lanes))
  })

  // replicate small units for higher throughput
  val valid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    val div_sqrt = Module(
      new fudian.FDIV(
        floatType.exp(),
        floatType.sig()
      )
    )
    div_sqrt.suggestName(s"div_sqrt${floatType.kind()}_${i}")
    div_sqrt.io.a := io.req.bits.a(i)
    div_sqrt.io.b := io.req.bits.b(i)
    div_sqrt.io.specialIO.in_valid := io.req.valid
    div_sqrt.io.specialIO.kill := false.B

    // TODO
    div_sqrt.io.rm := 0.U

    val result = div_sqrt.io.result
    val exception = Wire(UInt(5.W))
    exception := div_sqrt.io.fflags
    div_sqrt.io.specialIO.isSqrt := io.req.bits.op === IEEEFDivSqrtOp.SQRT

    // lanes might not complete in the same cycle
    val resultReg = Reg(UInt(floatType.width().W))
    val exceptionReg = Reg(UInt(5.W))
    val resultValidReg = RegInit(false.B)
    val done = Wire(Bool())
    div_sqrt.io.specialIO.out_ready := true.B
    when(div_sqrt.io.specialIO.out_valid) {
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
      div_sqrt.io.specialIO.in_ready
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
