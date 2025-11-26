package fpuwrapper.fudian

import chisel3._
import chisel3.util._
import fpuwrapper.EmitChiselModule
import fpuwrapper.FloatD
import fpuwrapper.FloatType
import fpuwrapper.Synthesis

class IEEEFAddRequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val a = Vec(lanes, UInt(floatType.width().W))
  val b = Vec(lanes, UInt(floatType.width().W))
}

class IEEEFAddResponse(val floatType: FloatType, val lanes: Int)
    extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.width().W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class IEEEFAdd(floatType: FloatType, lanes: Int, stages: Int) extends Module {
  val io = IO(new Bundle {
    val req = Flipped(Valid(new IEEEFAddRequest(floatType, lanes)))
    val resp = Valid(new IEEEFAddResponse(floatType, lanes))
  })

  val inputStages = stages / 2
  val outputStages = stages - inputStages

  val reqValid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    val fma = Module(
      new fudian.FADD(
        floatType.exp(),
        floatType.sig()
      )
    )
    fma.suggestName(s"fadd_${floatType.kind()}_${i}")
    fma.io.a := Pipe(
      reqValid,
      io.req.bits.a(i),
      inputStages
    ).bits
    fma.io.b := Pipe(
      reqValid,
      io.req.bits.b(i),
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

object IEEEFAdd extends EmitChiselModule {
  emitChisel(
    (floatType, lanes, stages) => new IEEEFAdd(floatType, lanes, stages),
    "IEEEFAdd",
    "fudian"
  )
}

object IEEEFAddSynth extends EmitChiselModule {
  for (floatType <- Seq(FloatD)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(4)) {
      emitChisel(
        (floatType, lanes, stages) => new IEEEFAdd(floatType, lanes, stages),
        "IEEEFAdd",
        "fudian",
        allStages = Seq(stages),
        floatTypes = Seq(floatType),
        lanes = Seq(1)
      )
      val name = s"Fudian_IEEEFAdd_${floatName}1l${stages}s"
      Synthesis.build(
        Seq(s"${name}.v"),
        s"${name}_IEEEFAdd",
        s"fudian_${name}"
      )
    }
  }
}
