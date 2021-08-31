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
    BitPat(op.litValue().U)
}

class FCmpRequest(val floatType: FloatType) extends Bundle {
  val op = FCmpOp()
  val r1 = UInt(floatType.widthHardfloat().W)
  val r2 = UInt(floatType.widthHardfloat().W)
}

class FCmpResponse(val floatType: FloatType) extends Bundle {
  // result
  val res = UInt(floatType.width().W)
  // exception status
  val exc = Bits(5.W)
}

class FCmp(floatType: FloatType) extends Module {
  val fLen = floatType.widthHardfloat()

  val io = IO(new Bundle {
    val req = Flipped(Valid(new FCmpRequest(floatType)))
    val resp = Valid(new FCmpResponse(floatType))
  })

  // replicate small units for higher throughput
  val valid = io.req.valid
  val stages = 2

  val cmp = Module(
    new CompareRecFN(
      floatType.exp(),
      floatType.sig()
    )
  )
  cmp.suggestName(s"cmp${floatType.kind()}")
  cmp.io.a := io.req.bits.r1
  cmp.io.b := io.req.bits.r2
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

  val resValid = ShiftRegister(valid, stages)

  io.resp.valid := resValid
  io.resp.bits.res := res
  io.resp.bits.exc := exc
}

object FCmp extends EmitVerilogApp {
  for (kind <- Seq(FloatH, FloatS, FloatD)) {
    val name = kind.getClass().getSimpleName().stripSuffix("$")
    emit(() => new FCmp(kind), s"FCmp_${name}")
  }
}
