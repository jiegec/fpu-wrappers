package fpuwrapper.hardfloat

import chisel3._
import chisel3.util._
import chisel3.experimental._
import fpuwrapper._
import _root_.hardfloat.CompareRecFN

object FCmpOp extends ChiselEnum {
  val EQ = Value
  val NE = Value
  val LT = Value
  val LE = Value
  val GT = Value
  val GE = Value

  val NOP = EQ

  implicit def bitpat(op: FCmpOp.Type): BitPat =
    BitPat(op.litValue.U)
}

class FCmpRequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val op = FCmpOp()
  val r1 = Vec(lanes, UInt(floatType.widthHardfloat().W))
  val r2 = Vec(lanes, UInt(floatType.widthHardfloat().W))
}

class FCmpResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.width().W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class FCmp(floatType: FloatType, lanes: Int, stages: Int) extends Module {
  val io = IO(new Bundle {
    val req = Flipped(Valid(new FCmpRequest(floatType, lanes)))
    val resp = Valid(new FCmpResponse(floatType, lanes))
  })

  // replicate small units for higher throughput
  val valid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    val cmp = Module(
      new CompareRecFN(
        floatType.exp(),
        floatType.sig()
      )
    )
    cmp.suggestName(s"cmp${floatType.kind()}_${i}")
    cmp.io.a := io.req.bits.r1(i)
    cmp.io.b := io.req.bits.r2(i)
    cmp.io.signaling := true.B

    val result = Wire(UInt(floatType.width().W))
    val exception = Wire(UInt(5.W))
    exception := cmp.io.exceptionFlags
    result := 0.U
    switch(io.req.bits.op) {
      is(FCmpOp.EQ) {
        when(cmp.io.eq) {
          result := 1.U
        }
      }
      is(FCmpOp.NE) {
        when(!cmp.io.eq) {
          result := 1.U
        }
      }
      is(FCmpOp.GE) {
        when(cmp.io.gt || cmp.io.eq) {
          result := 1.U
        }
      }
      is(FCmpOp.LE) {
        when(cmp.io.lt || cmp.io.eq) {
          result := 1.U
        }
      }
      is(FCmpOp.GT) {
        when(cmp.io.gt) {
          result := 1.U
        }
      }
      is(FCmpOp.LT) {
        when(cmp.io.lt) {
          result := 1.U
        }
      }
    }

    // stages
    val res = Pipe(
      valid,
      result,
      stages
    ).bits
    val exc = Pipe(
      valid,
      exception,
      stages
    ).bits
    (res, exc)
  }

  // collect result
  val res = results.map(_._1)
  // exception flags
  val exc = results.map(_._2)

  val resValid = ShiftRegister(valid, stages)

  io.resp.valid := resValid
  io.resp.bits.res := res
  io.resp.bits.exc := exc
}

object FCmp extends EmitChiselModule {
  emitChisel(
    (floatType, lanes, stages) => new FCmp(floatType, lanes, stages),
    "HardfloatFCmp"
  )
}
