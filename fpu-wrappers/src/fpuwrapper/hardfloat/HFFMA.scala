package fpuwrapper.hardfloat

import chisel3._
import chisel3.util._
import fpuwrapper._
import chisel3.experimental.annotate
import sifive.enterprise.firrtl.NestedPrefixModulesAnnotation
import chisel3.experimental.ChiselAnnotation

class HFFMARequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val op = FMAOp()
  val operands = Vec(3, Vec(lanes, UInt(floatType.widthHardfloat().W)))
}

class HFFMAResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.widthHardfloat().W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class HFFMA(
    floatType: FloatType,
    lanes: Int,
    stages: Int,
    prefix: String = ""
) extends Module {
  AddPrefix(this, prefix)

  val io = IO(new Bundle {
    val req = Flipped(Valid(new HFFMARequest(floatType, lanes)))
    val resp = Valid(new HFFMAResponse(floatType, lanes))
  })

  val one = Wire(Vec(lanes, UInt(floatType.widthHardfloat().W)))
  val zero = Wire(Vec(lanes, UInt(floatType.widthHardfloat().W)))
  for (i <- 0 until lanes) {
    one(i) := floatType.oneHardfloatChisel()
    zero(i) := 0.U
  }

  // fma: neg * (op[0] * op[1]) + sign * op[2]
  // neg: {0 => 1, 1 => -1}
  // sub: {0 => 1, 1 => -1}
  val op1 = WireInit(io.req.bits.operands(0))
  val op2 = WireInit(io.req.bits.operands(1))
  val op3 = WireInit(io.req.bits.operands(2))
  val neg = WireInit(false.B)
  val sign = WireInit(false.B)

  // see the definition of FMAOp for more detail
  switch(io.req.bits.op) {
    is(FMAOp.FADD) {
      op1 := one
    }
    is(FMAOp.FSUB) {
      op1 := one
      sign := true.B
    }
    is(FMAOp.FMUL) {
      op3 := zero
    }
    is(FMAOp.FMADD) {
      // do nothing
    }
    is(FMAOp.FMSUB) {
      sign := true.B
    }
    is(FMAOp.FNMSUB) {
      neg := true.B
    }
    is(FMAOp.FNMADD) {
      neg := true.B
      sign := true.B
    }
  }

  // when stages > 3, add extra stages
  val extraStages = (stages - 2) max 0
  val inputStages = (extraStages + 1) / 2
  val outputStages = extraStages - inputStages

  // replicate small units for higher throughput
  val reqValid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    // MulAddRecFNPipe only support stages <= 2
    val fma = Module(
      new MulAddRecFNPipe(
        stages min 2,
        floatType.exp(),
        floatType.sig()
      )
    )
    fma.suggestName(s"fma_${floatType.kind()}_${i}")
    fma.io.validin := Pipe(reqValid, reqValid, inputStages).bits
    fma.io.a := Pipe(
      reqValid,
      op1(i),
      inputStages
    ).bits
    fma.io.b := Pipe(
      reqValid,
      op2(i),
      inputStages
    ).bits
    fma.io.c := Pipe(
      reqValid,
      op3(i),
      inputStages
    ).bits

    fma.io.op := Pipe(
      reqValid,
      Cat(neg, sign),
      inputStages
    ).bits
    // TODO
    fma.io.roundingMode := 0.U
    fma.io.detectTininess := 0.U

    val res = Pipe(true.B, fma.io.out, outputStages).bits
    val exc = Pipe(true.B, fma.io.exceptionFlags, outputStages).bits
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

object HFFMA extends EmitChiselModule {
  emitChisel(
    (floatType, lanes, stages, prefix) =>
      new HFFMA(floatType, lanes, stages, prefix),
    "HFFMA",
    "hardfloat"
  )
}

object HFFMASynth extends EmitChiselModule {
  for (floatType <- Seq(FloatS)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(3)) {
      emitChisel(
        (floatType, lanes, stages, _) => new HFFMA(floatType, lanes, stages),
        "HFFMA",
        "hardfloat",
        allStages = Seq(stages),
        floatTypes = Seq(floatType),
        lanes = Seq(1)
      )
      val name = s"Hardfloat_HFFMA_${floatName}1l${stages}s"
      Synthesis.build(Seq(s"${name}.v"), s"${name}_HFFMA", s"hardfloat_${name}")
    }
  }
}

object HFFMABench extends EmitChiselModule with VivadoBench {
  val library = "hardfloat"
  val moduleName = "HFFMA"
  for (floatType <- Seq(FloatS)) {
    for (stages <- Seq(3)) {
      for (lanes <- Seq(2)) {
        val floatName = floatType.kind().toString()
        emitChisel(
          (floatType, lanes, stages, prefix) =>
            new HFFMA(floatType, lanes, stages, prefix),
          moduleName,
          library,
          allStages = Seq(stages),
          floatTypes = Seq(floatType),
          lanes = Seq(lanes)
        )
        val name = s"${moduleName}_${floatName}${lanes}l${stages}s"
        bench(
          s"${name}_${library}",
          Seq(s"${name}_${library}.sv"),
          s"${name}_${library}_${moduleName}"
        )
      }
    }
  }
}
