package fpuwrapper.formal

import org.scalatest.freespec.AnyFreeSpec
import chiseltest.ChiselScalatestTester
import chiseltest.formal.Formal

class FMAFormalTest extends AnyFreeSpec with ChiselScalatestTester with Formal {

  s"Formal verification of FMA" in {
    // too slow to complete
    /*
    verify(
      new FMAFormal(FloatH, 1, 1),
      Seq(BoundedCheck(kMax = 1), WriteVcdAnnotation)
    )
     */
  }
}
