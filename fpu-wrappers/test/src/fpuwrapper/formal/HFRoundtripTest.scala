package fpuwrapper.formal

import org.scalatest.freespec.AnyFreeSpec
import chiseltest.ChiselScalatestTester
import chiseltest.formal.Formal
import chiseltest.simulator.WriteVcdAnnotation
import fpuwrapper.FloatH
import chiseltest.formal.BoundedCheck

class HFRoundtripTest
    extends AnyFreeSpec
    with ChiselScalatestTester
    with Formal {

  s"Formal verification of HFRoundtrip" in {
    verify(
      new HFRoundtrip(FloatH),
      Seq(BoundedCheck(kMax = 10), WriteVcdAnnotation)
    )
  }
}
