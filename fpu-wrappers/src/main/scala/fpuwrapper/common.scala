package fpuwrapper

import chisel3._
import chisel3.stage.ChiselStage
import firrtl.stage.RunFirrtlTransformAnnotation
import firrtl.options.Dependency
import _root_.hardfloat.{recFNFromFN, fNFromRecFN}

trait FloatType {
  // must implement
  // exp bits
  def exp(): Int
  // (total - exp) bits
  def sig(): Int
  def kind(): FpKind.FpKind

  // auto implemented
  // total bits
  def width(): Int = exp() + sig()
  // HF width in bits
  def widthHardfloat(): Int = width() + 1
  // conversion to hardfloat internal representation
  def toHardfloat(n: UInt) = recFNFromFN(exp(), sig(), n)
  def fromHardfloat(n: UInt) = fNFromRecFN(exp(), sig(), n)
  // extract one element from packed
  def extract(data: UInt, offset: Int) =
    data((offset + 1) * width() - 1, offset * width())
  def extractHardfloat(data: UInt, offset: Int) =
    data((offset + 1) * widthHardfloat() - 1, offset * widthHardfloat())
  // generate the representation of 1.0
  def oneBigInt() = (((BigInt(1) << (exp() - 1)) - 1) << (sig() - 1))
  // chisel
  def oneChisel() = (((BigInt(1) << (exp() - 1)) - 1) << (sig() - 1)).U(width().W)
  def oneHardfloatChisel() = (BigInt(1) << (exp() + sig() - 1)).U(widthHardfloat().W)
}

object FpKind extends Enumeration {
  type FpKind = Value
  // Double, Single, Half precision
  val D, S, H = Value
}

object FloatD extends FloatType {
  def exp() = 11
  def sig() = 53
  def kind() = FpKind.D
}

object FloatS extends FloatType {
  def exp() = 8
  def sig() = 24
  def kind() = FpKind.S
}

object FloatH extends FloatType {
  def exp() = 5
  def sig() = 11
  def kind() = FpKind.H
}

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

trait EmitHardfloatModule extends EmitVerilogApp {
  def emitHardfloat(stages: Int, genModule: (FloatType, Int, Int) => RawModule, name: String) {
    for (kind <- Seq(FloatH, FloatS, FloatD)) {
      val floatName = kind.kind().toString()
      for (lanes <- Seq(1, 2, 4, 8)) {
        emit(
          () => genModule(kind, lanes, stages),
          s"${name}_${floatName}${lanes}l${stages}s"
        )
      }
    }
  }
}

trait SpinalGen extends App {
  def work[T <: spinal.core.Component](gen: => T, netlistName: String = null): Unit = {
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
  def emitFlopoco[T <: spinal.core.Component](stages: Int, genModule: (FloatType, Int, Int) => T, name: String) {
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