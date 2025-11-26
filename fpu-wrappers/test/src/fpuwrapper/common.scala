package fpuwrapper

import svsim._
import chisel3.RawModule
import chisel3.simulator._
import java.nio.file.Files
import java.io.File
import scala.reflect.io.Directory

// custom EphemeralSimulator to add options to verilator

object Simulator extends PeekPokeAPI {

  def simulate[T <: RawModule](
      module: => T
  )(body: (T) => Unit): Unit = {
    makeSimulator.simulate(module)({ module => body(module.wrapped) }).result
  }

  private class DefaultSimulator(val workspacePath: String)
      extends Simulator[verilator.Backend] {
    override val backend = verilator.Backend.initializeFromProcessEnvironment()
    override val tag = "default"
    override val commonCompilationSettings = CommonCompilationSettings()
    override val backendSpecificCompilationSettings =
      verilator.Backend.CompilationSettings(
        traceStyle =
          Some(verilator.Backend.CompilationSettings.TraceStyle(verilator.Backend.CompilationSettings.TraceKind.Vcd)),
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

    // Try to clean up temporary workspace if possible
    sys.addShutdownHook {
      (new Directory(new File(workspacePath))).deleteRecursively()
    }
  }
  private def makeSimulator: DefaultSimulator = {
    // TODO: Use ProcessHandle when we can drop Java 8 support
    // val id = ProcessHandle.current().pid().toString()
    val id = java.lang.management.ManagementFactory.getRuntimeMXBean().getName()
    val className = getClass().getName().stripSuffix("$")
    new DefaultSimulator(
      Files.createTempDirectory(s"${className}_${id}_").toString
    )
  }
}
