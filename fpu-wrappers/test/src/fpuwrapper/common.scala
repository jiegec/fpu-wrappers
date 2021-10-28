package fpuwrapper

import chiseltest.simulator.IcarusBackendAnnotation
import chiseltest.simulator.VerilatorBackendAnnotation
import chiseltest.simulator.VerilatorFlags
import chiseltest.simulator.WriteVcdAnnotation
import firrtl.AnnotationSeq

object Simulator {
  def getAnnotations(): AnnotationSeq = {
    val icarusFound = os.proc("which", "iverilog").call().exitCode == 0
    if (icarusFound) {
      println("Using Icarus Verilog")
      Seq(
        IcarusBackendAnnotation
      )
    } else {
      println("Using Verilator")
      Seq(
        VerilatorBackendAnnotation,
        VerilatorFlags(Seq("-Wno-BLKANDNBLK"))
      )
    } ++ Seq(WriteVcdAnnotation)
  }
}
