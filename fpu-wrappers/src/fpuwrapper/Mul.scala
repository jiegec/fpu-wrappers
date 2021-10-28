package fpuwrapper

import spinal.core._
import spinal.lib._

/** An integer multiplier
  *
  * @param bitWidth
  *   the bit width of integer
  * @param stages
  *   pipeline stages
  */
class Mul(bitWidth: Int, stages: Int) extends Component {
  val a = in(UInt(bitWidth bits))
  val b = in(UInt(bitWidth bits))
  val c = out(UInt(2 * bitWidth bits))

  c := Delay(a * b, stages)
}

/** Generate Mul module
  */
object Mul extends SpinalGen {
  for (width <- Seq(8, 16, 32)) {
    for (stages <- Seq(0, 1, 2)) {
      work(new Mul(width, stages), s"Mul_${width}w${stages}s")
    }
  }
}

/** Synthesize Mul
  */
object MulSynth extends SpinalGen {
  for (width <- Seq(11, 24, 53)) {
    for (stages <- Seq(0, 1, 2)) {
      work(new Mul(width, stages), s"Mul_${width}w${stages}s")
      val name = s"Mul_${width}w${stages}s"
      Synthesis.build(
        Seq(
          s"${name}.v"
        ),
        s"Mul",
        name
      )
    }
  }
}
