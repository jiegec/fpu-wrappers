package fpuwrapper

import chiseltest.simulator.IcarusBackendAnnotation
import chiseltest.simulator.VerilatorBackendAnnotation
import chiseltest.simulator.VerilatorFlags
import chiseltest.simulator.WriteVcdAnnotation
import firrtl.AnnotationSeq
import chiseltest.simulator.VcsBackendAnnotation

object Simulator {
  def getAnnotations(): AnnotationSeq = {
    val vcsFound = os.proc("which", "vcs").call().exitCode == 0
    val icarusFound = os.proc("which", "iverilog").call().exitCode == 0
    if (vcsFound) {
      println("Using VCS")
      Seq(
        VcsBackendAnnotation
      )
    } else if (icarusFound) {
      println("Using Icarus Verilog")
      Seq(
        IcarusBackendAnnotation
      )
    } else {
      println("Using Verilator")
      Seq(
        VerilatorBackendAnnotation
      )
    } ++ Seq(WriteVcdAnnotation)
  }
}
