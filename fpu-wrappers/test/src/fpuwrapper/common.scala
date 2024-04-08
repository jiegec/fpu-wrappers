package fpuwrapper

import svsim._
import chisel3.RawModule
import chisel3.simulator._

// custom EphemeralSimulator to add options to verilator
object Simulator extends PeekPokeAPI {

  def simulate[T <: RawModule](
      module: => T
  )(body: (T) => Unit): Unit = {
    synchronized {
      simulator
        .simulate(module)({ (sim, dut) =>
          {
            sim.setTraceEnabled(true);
            body(dut)
          }
        })
        .result
    }
  }

  private class DefaultSimulator(val workspacePath: String)
      extends SingleBackendSimulator[verilator.Backend] {
    val backend = verilator.Backend.initializeFromProcessEnvironment()
    val tag = "default"
    val commonCompilationSettings = CommonCompilationSettings(
    )
    val backendSpecificCompilationSettings =
      verilator.Backend.CompilationSettings(
        traceStyle =
          Some(verilator.Backend.CompilationSettings.TraceStyle.Vcd()),
        // for fpnew
        disabledWarnings = Seq(
          "UNOPTFLAT",
          "CASEOVERLAP",
          "UNSIGNED",
          "WIDTHTRUNC",
          "WIDTHEXPAND",
          "ASCRANGE",
          "PINMISSING"
        )
      )
  }
  private lazy val simulator: DefaultSimulator = {
    val currentDirectory = System.getProperty("user.dir")
    // TODO: Use ProcessHandle when we can drop Java 8 support
    // val id = ProcessHandle.current().pid().toString()
    val id = java.lang.management.ManagementFactory.getRuntimeMXBean().getName()
    val className = getClass().getName().stripSuffix("$")
    new DefaultSimulator(Seq(currentDirectory, className, id).mkString("/"))
  }
}
