package fpuwrapper

import chiseltest.simulator.IcarusBackendAnnotation
import chiseltest.simulator.VerilatorBackendAnnotation
import chiseltest.simulator.WriteVcdAnnotation
import firrtl2.AnnotationSeq
import chiseltest.simulator.VcsBackendAnnotation
import chiseltest.simulator.VerilatorFlags

object Simulator {

  /** check if vcs is found */
  def vcsFound(): Boolean = {
    os.proc("which", "vcs").call(check = false).exitCode == 0
  }

  /** check if icarus verilog is found */
  def icarusFound(): Boolean = {
    os.proc("which", "iverilog").call(check = false).exitCode == 0
  }

  /** check if verilator is found */
  def verilatorFound(): Boolean = {
    os.proc("which", "verilator").call(check = false).exitCode == 0
  }

  /** get annotations for chiseltest */
  def getAnnotations(
      useVCS: Boolean = true,
      useIcarus: Boolean = true,
      useVerilator: Boolean = true
  ): AnnotationSeq = {
    val annotations = if (vcsFound() && useVCS) {
      println("Using VCS")
      Seq(
        VcsBackendAnnotation
      )
    } else if (icarusFound() && useIcarus) {
      println("Using Icarus Verilog")
      Seq(
        IcarusBackendAnnotation
      )
    } else if (verilatorFound() && useVerilator) {
      println("Using Verilator")
      Seq(
        VerilatorBackendAnnotation,
        VerilatorFlags(Seq("-Wno-BLKANDNBLK"))
      )
    } else {
      throw new RuntimeException("No usable simulator")
      Seq()
    }
    annotations ++ Seq(WriteVcdAnnotation)
  }
}
