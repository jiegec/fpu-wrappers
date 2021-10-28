package fpuwrapper

import _root_.hardfloat.fNFromRecFN
import _root_.hardfloat.recFNFromFN
import chisel3._

/** Trait for floating point type
  */
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
  def oneChisel() =
    (((BigInt(1) << (exp() - 1)) - 1) << (sig() - 1)).U(width().W)
  def oneHardfloatChisel() =
    (BigInt(1) << (exp() + sig() - 1)).U(widthHardfloat().W)
}

/** Enum of floating point types
  */
object FpKind extends Enumeration {
  type FpKind = Value
  // Double, Single, Half precision
  val D, S, H = Value
}

/** 64-bit Double
  */
object FloatD extends FloatType {
  def exp() = 11
  def sig() = 53
  def kind() = FpKind.D
}

/** 32-bit Float
  */
object FloatS extends FloatType {
  def exp() = 8
  def sig() = 24
  def kind() = FpKind.S
}

/** 16-bit Half Float
  */
object FloatH extends FloatType {
  def exp() = 5
  def sig() = 11
  def kind() = FpKind.H
}
