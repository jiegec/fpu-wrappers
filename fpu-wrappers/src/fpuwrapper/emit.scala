package fpuwrapper

import chisel3._
import chisel3.stage.ChiselGeneratorAnnotation
import chisel3.experimental.ChiselAnnotation
import circt.stage.FirtoolOption
import circt.stage.ChiselStage
import _root_.sifive.enterprise.firrtl.NestedPrefixModulesAnnotation
import chisel3.experimental.annotate

/** Helper to add prefix
  */
object AddPrefix {
  def apply(module: Module, prefix: String, inclusive: Boolean = true) = {
    if (prefix != null) {
      annotate(new ChiselAnnotation {
        def toFirrtl =
          new NestedPrefixModulesAnnotation(module.toTarget, prefix, true)
      })
    }
  }
}

/** Emit Verilog from Chisel module
  */
trait ChiselEmitVerilog extends App {
  def emit(genModule: () => RawModule, name: String) = {
    ChiselStage.emitSystemVerilogFile(
      genModule(),
      Array(),
      Array("-o", s"${name}.sv")
    )
  }
}

/** Helper to generate Chisel modules
  */
trait EmitChiselModule extends ChiselEmitVerilog {
  def emitChisel(
      genModule: (FloatType, Int, Int, String) => RawModule,
      name: String,
      library: String,
      allStages: Seq[Int] = Seq(1, 2, 3),
      floatTypes: Seq[FloatType] = Seq(FloatH, FloatS, FloatD),
      lanes: Seq[Int] = Seq(1, 2, 4)
  ) = {
    for (floatType <- floatTypes) {
      val floatName = floatType.kind().toString()
      for (lanes <- lanes) {
        for (stages <- allStages) {
          val moduleName = s"${name}_${floatName}${lanes}l${stages}s_${library}"
          val prefix = s"${moduleName}_"
          emit(
            () => genModule(floatType, lanes, stages, prefix),
            moduleName
          )
        }
      }
    }
  }
}

/** Generate Verilog from SpinalHDL module
  */
trait SpinalEmitVerilog extends App {
  def work[T <: spinal.core.Component](
      gen: => T,
      netlistName: String = null
  ): Unit = {
    // verilog
    val verilog = spinal.core.SpinalConfig(
      netlistFileName = netlistName match {
        case null => null
        case s    => s"$s.v"
      }
    )
    verilog.generateVerilog(gen)
  }
}

/** Helper to generate SpinalHDL modules
  */
trait EmitSpinalModule extends SpinalEmitVerilog {
  def emitFlopoco[T <: spinal.core.Component](
      stages: Int,
      genModule: (FloatType, Int, Int) => T,
      name: String
  ) = {
    for (kind <- Seq(FloatH, FloatS, FloatD)) {
      val floatName = kind.kind().toString()
      for (lanes <- Seq(1, 2, 4, 8)) {
        work(
          genModule(kind, lanes, stages),
          s"${name}_${floatName}${lanes}l${stages}s"
        )
      }
    }
  }
}
