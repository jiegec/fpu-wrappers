package fpuwrapper.formal

import org.scalatest.freespec.AnyFreeSpec
import chiseltest.ChiselScalatestTester
import chiseltest.formal.Formal
import fpuwrapper.FloatH
import chiseltest.simulator.WriteVcdAnnotation
import chiseltest.formal.BoundedCheck

class IEEEFMAFormalTest
    extends AnyFreeSpec
    with ChiselScalatestTester
    with Formal {

  s"Formal verification of IEEEFMA" in {
    verify(
      new IEEEFMAFormal(FloatH, 1, 1),
      Seq(BoundedCheck(kMax = 1), WriteVcdAnnotation)
    )
  }
}
