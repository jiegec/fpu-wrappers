package fpuwrapper.hardfloat

import chisel3._
import chisel3.util.ShiftRegister
import chisel3.util.Valid
import fpuwrapper._

class IEEEToHF(floatType: FloatType, lanes: Int, stages: Int) extends Module {
  val io = IO(new Bundle {
    val float = Input(Valid(Vec(lanes, Bits(floatType.width().W))))
    val hardfloat = Output(Valid(Vec(lanes, Bits(floatType.widthHardfloat().W))))
  })

  io.hardfloat.valid := ShiftRegister(io.float.valid, stages)
  for (i <- 0 until lanes) {
    io.hardfloat.bits(i) := ShiftRegister(
      floatType.toHardfloat(io.float.bits(i)),
      stages
    )
  }
}

object IEEEToHF extends EmitChiselModule {
  emitChisel(
    (floatType, lanes, stages, _) => new IEEEToHF(floatType, lanes, stages),
    "IEEEToHF",
    "hardfloat"
  )
}
