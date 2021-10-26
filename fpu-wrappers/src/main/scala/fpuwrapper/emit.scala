package fpuwrapper

import chisel3._
import chisel3.stage.ChiselStage
import firrtl.stage.RunFirrtlTransformAnnotation
import firrtl.options.Dependency

trait EmitVerilogApp extends App {
  def emit(genModule: () => RawModule, name: String) {
    val prefix = s"${name}_"
    (new ChiselStage()).emitVerilog(
      genModule(),
      Array("-o", s"${name}.v"),
      Seq(
        RunFirrtlTransformAnnotation(Dependency(PrefixModulesPass)),
        ModulePrefix(prefix)
      )
    )
  }
}

trait EmitChiselModule extends EmitVerilogApp {
  def emitHardfloat(
      genModule: (FloatType, Int, Int) => RawModule,
      name: String,
      allStages: Seq[Int] = Seq(1, 2, 3),
      floatTypes: Seq[FloatType] = Seq(FloatH, FloatS, FloatD),
      lanes: Seq[Int] = Seq(1, 2, 4)
  ) {
    for (floatType <- floatTypes) {
      val floatName = floatType.kind().toString()
      for (lanes <- lanes) {
        for (stages <- allStages) {
          emit(
            () => genModule(floatType, lanes, stages),
            s"${name}_${floatName}${lanes}l${stages}s"
          )
        }
      }
    }
  }
}

trait SpinalGen extends App {
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

trait EmitFlopocoModule extends SpinalGen {
  def emitFlopoco[T <: spinal.core.Component](
      stages: Int,
      genModule: (FloatType, Int, Int) => T,
      name: String
  ) {
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
