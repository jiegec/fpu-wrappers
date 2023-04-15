package fpuwrapper.hardfloat

import chisel3._
import chisel3.util._
import fpuwrapper._

class HFFMulRequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val a = Vec(lanes, UInt(floatType.widthHardfloat().W))
  val b = Vec(lanes, UInt(floatType.widthHardfloat().W))
}

class HFFMulResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.widthHardfloat().W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class HFFMul(floatType: FloatType, lanes: Int, stages: Int) extends Module {
  val io = IO(new Bundle {
    val req = Flipped(Valid(new HFFMulRequest(floatType, lanes)))
    val resp = Valid(new HFFMulResponse(floatType, lanes))
  })

  // when stages > 1, add extra stages
  val extraStages = (stages - 1) max 0
  val inputStages = extraStages / 2
  val outputStages = extraStages - inputStages

  // replicate small units for higher throughput
  val reqValid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    // MulRecFNPipe stages <= 1
    val fmul = Module(
      new MulRecFNPipe(
        floatType.exp(),
        floatType.sig(),
        stages min 1
      )
    )
    fmul.suggestName(s"fmul_${floatType.kind()}_${i}")
    fmul.io.validin := Pipe(reqValid, reqValid, inputStages).bits
    fmul.io.a := Pipe(
      reqValid,
      io.req.bits.a(i),
      inputStages
    ).bits
    fmul.io.b := Pipe(
      reqValid,
      io.req.bits.b(i),
      inputStages
    ).bits
    // TODO
    fmul.io.roundingMode := 0.U
    fmul.io.detectTininess := 0.U

    val res = Pipe(true.B, fmul.io.out, outputStages).bits
    val exc = Pipe(true.B, fmul.io.exceptionFlags, outputStages).bits
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

object HFFMul extends EmitChiselModule {
  emitChisel(
    (floatType, lanes, stages, _) => new HFFMul(floatType, lanes, stages),
    "HFFMul",
    "hardfloat"
  )
}

object HFFMulSynth extends EmitChiselModule {
  for (floatType <- Seq(FloatS)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(1, 2, 3)) {
      emitChisel(
        (floatType, lanes, stages, _) => new HFFMul(floatType, lanes, stages),
        "HFFMul",
        "hardfloat",
        allStages = Seq(stages),
        floatTypes = Seq(floatType),
        lanes = Seq(1)
      )
      val name = s"Hardfloat_HFFMul_${floatName}1l${stages}s"
      Synthesis.build(
        Seq(s"${name}.v"),
        s"${name}_HFFMul",
        s"hardfloat_${name}"
      )
    }
  }
}
