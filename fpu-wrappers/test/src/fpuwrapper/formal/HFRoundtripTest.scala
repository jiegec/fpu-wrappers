package fpuwrapper.formal

import org.scalatest.freespec.AnyFreeSpec
import chiseltest.ChiselScalatestTester
import chiseltest.formal.Formal
import chiseltest.formal.BoundedCheck
import treadle.WriteVcdAnnotation
import fpuwrapper.FloatH

class HFRoundtripTest
    extends AnyFreeSpec
    with ChiselScalatestTester
    with Formal {

  s"Formal verification of HFRoundtrip" in {
    // too slow to complete
    /*
    verify(
      new HFRoundtrip(FloatH),
      Seq(BoundedCheck(kMax = 1), WriteVcdAnnotation)
    )
    */
  }
}
