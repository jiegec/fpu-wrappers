package fpuwrapper

import spinal.lib._
import spinal.core._

class Mul(bitWidth: Int, stages: Int) extends Component {
  val a = in(UInt(bitWidth bits))
  val b = in(UInt(bitWidth bits))
  val c = out(UInt(2 * bitWidth bits))

  c := Delay(a * b, stages)
}

object Mul extends SpinalGen {
  for (width <- Seq(8, 16, 32)) {
    for (stages <- Seq(0, 1, 2)) {
      work(new Mul(width, stages), s"Mul_${width}w${stages}s")
    }
  }
}

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
