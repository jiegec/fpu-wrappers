package fpuwrapper.fudian

import chisel3._
import chisel3.util._
import fpuwrapper.EmitChiselModule
import fpuwrapper.FloatH
import fpuwrapper.FloatS
import fpuwrapper.FloatD
import fpuwrapper.FloatType
import fpuwrapper.Synthesis

class IEEEFMARequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val operands = Vec(3, Vec(lanes, UInt(floatType.width().W)))
}

class IEEEFMAResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.width().W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

// adapted from fudian.FCMA
// insert pipeline stages between FMUL and FCMA_ADD
class FCMAPipe(val expWidth: Int, val precision: Int, val stages: Int)
    extends Module {
  val io = IO(new Bundle() {
    val a, b, c = Input(UInt((expWidth + precision).W))
    val rm = Input(UInt(3.W))
    val result = Output(UInt((expWidth + precision).W))
    val fflags = Output(UInt(5.W))
  })

  val fmul = Module(new fudian.FMUL(expWidth, precision))
  val fadd = Module(new fudian.FCMA_ADD(expWidth, 2 * precision, precision))

  fmul.io.a := io.a
  fmul.io.b := io.b
  fmul.io.rm := io.rm

  val mul_to_fadd = ShiftRegister(fmul.io.to_fadd, stages)
  fadd.io.a := ShiftRegister(Cat(io.c, 0.U(precision.W)), stages)
  fadd.io.b := mul_to_fadd.fp_prod.asUInt
  fadd.io.b_inter_valid := true.B
  fadd.io.b_inter_flags := mul_to_fadd.inter_flags
  fadd.io.rm := ShiftRegister(io.rm, stages)

  io.result := fadd.io.result
  io.fflags := fadd.io.fflags
}

class IEEEFMA(
    floatType: FloatType,
    lanes: Int,
    stages: Int,
) extends Module {
  val io = IO(new Bundle {
    val req = Flipped(Valid(new IEEEFMARequest(floatType, lanes)))
    val resp = Valid(new IEEEFMAResponse(floatType, lanes))
  })

  val internalStages = if (stages > 1) 1 else 0
  val inputStages = (stages - internalStages) / 2
  val outputStages = stages - internalStages - inputStages

  val reqValid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    val fma = Module(
      new fudian.FCMA(
        floatType.exp(),
        floatType.sig()
      )
    )
    fma.suggestName(s"fma_${floatType.kind()}_${i}")
    fma.io.a := Pipe(
      reqValid,
      io.req.bits.operands(0)(i),
      inputStages
    ).bits
    fma.io.b := Pipe(
      reqValid,
      io.req.bits.operands(1)(i),
      inputStages
    ).bits
    fma.io.c := Pipe(
      reqValid,
      io.req.bits.operands(2)(i),
      inputStages
    ).bits

    // TODO
    fma.io.rm := 0.U

    val res =
      Pipe(true.B, fma.io.result, outputStages).bits
    val exc = Pipe(true.B, fma.io.fflags, outputStages).bits
    (res, exc)
  }

  // collect result
  val res = results.map(_._1)
  // exception flags
  val exc = results.map(_._2)

  val resValid = ShiftRegister(reqValid, stages)

  io.resp.valid := resValid
  io.resp.bits.res := res
  io.resp.bits.exc := exc
}

object IEEEFMA extends EmitChiselModule {
  emitChisel(
    (floatType, lanes, stages) => new IEEEFMA(floatType, lanes, stages),
    "IEEEFMA",
    "fudian"
  )
}

object IEEEFMASynth extends EmitChiselModule {
  for (floatType <- Seq(FloatH, FloatS, FloatD)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(2, 3, 4)) {
      emitChisel(
        (floatType, lanes, stages) =>
          new IEEEFMA(floatType, lanes, stages),
        "IEEEFMA",
        "fudian",
        allStages = Seq(stages),
        floatTypes = Seq(floatType),
        lanes = Seq(1)
      )
      val name = s"IEEEFMA_${floatName}1l${stages}s_fudian"
      Synthesis.build(
        Seq(s"${name}.sv"),
        s"${name}_IEEEFMA",
        s"${name}"
      )
    }
  }
}
