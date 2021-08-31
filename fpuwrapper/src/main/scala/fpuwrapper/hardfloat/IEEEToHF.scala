package fpuwrapper.hardfloat

import chisel3._
import fpuwrapper._
import chisel3.util.Valid
import chisel3.util.ShiftRegister

class IEEEToHF(floatType: FloatType, lanes: Int, stages: Int) extends Module {
  val io = IO(new Bundle {
    val float = Input(Valid(Vec(lanes, Bits(floatType.width().W))))
    val hardfloat = Output(Valid(Vec(lanes, Bits(floatType.widthHardfloat.W))))
  })

  io.hardfloat.valid := ShiftRegister(io.float.valid, stages)
  for (i <- 0 until lanes) {
    io.hardfloat.bits(i) := ShiftRegister(
      floatType.toHardfloat(io.float.bits(i)),
      stages
    )
  }
}

object IEEEToHF extends EmitVerilogApp {
  for (kind <- Seq(FloatH, FloatS, FloatD)) {
    val name = kind.kind().toString()
    for (concurrency <- Seq(1, 2, 4, 8)) {
      val stages = 1
      emit(
        () => new IEEEToHF(kind, concurrency, stages),
        s"IEEEToHF_${name}${concurrency}l${stages}s"
      )
    }
  }
}
