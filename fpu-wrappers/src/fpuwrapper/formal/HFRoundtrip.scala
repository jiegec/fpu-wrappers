package fpuwrapper.formal

import circt.stage.ChiselStage
import chisel3._
import fpuwrapper.FloatS
import fpuwrapper.FloatType
import fpuwrapper.hardfloat.HFToIEEE
import fpuwrapper.hardfloat.IEEEToHF

import scala.sys.process._

class HFRoundtrip(floatType: FloatType) extends Module {
  val io = IO(new Bundle {
    val req = Input(UInt(floatType.width().W))
  })

  val ieee2hf = Module(
    new IEEEToHF(floatType, 1, 0)
  )
  ieee2hf.io.float.valid := true.B
  ieee2hf.io.float.bits(0) := io.req

  val hf2ieee = Module(
    new HFToIEEE(floatType, 1, 0)
  )
  hf2ieee.io.hardfloat.valid := true.B
  hf2ieee.io.hardfloat.bits(0) := ieee2hf.io.hardfloat.bits(0)

  chisel3.assert(hf2ieee.io.float.bits(0) === io.req)
}

object HFRoundtrip extends App {
  ChiselStage.emitSystemVerilog(
    new HFRoundtrip(FloatS),
    Array("-o", "HFRoundtrip")
  )
  Seq(
    "yosys",
    "-v2",
    "-p",
    "read_verilog -formal HFRoundtrip.sv",
    "-p",
    "prep",
    "-p",
    "write_smt2 -wires HFRoundtrip.smt2"
  ).!
  Seq(
    "yosys-smtbmc",
    "-s",
    "z3",
    "-t",
    "30",
    "--dump-vcd",
    "test.vcd",
    "-m",
    "HFRoundtrip",
    "HFRoundtrip.smt2"
  ).!
}
