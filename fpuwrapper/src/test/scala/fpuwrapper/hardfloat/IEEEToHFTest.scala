package fpuwrapper.hardfloat

import chisel3._
import chisel3.tester._
import org.scalatest.FreeSpec
import chiseltest.experimental.TestOptionBuilder._
import chiseltest.internal.VerilatorBackendAnnotation
import chiseltest.internal.WriteVcdAnnotation
import chisel3.experimental.BundleLiterals._
import chiseltest.legacy.backends.verilator.VerilatorFlags
import fpuwrapper.FloatS

class IEEEToHFSpec extends FreeSpec with ChiselScalatestTester {
  "IEEEToHF should work" in {
    test(new IEEEToHF(FloatS, 2, 2))
      .withAnnotations(
        Seq(
          VerilatorBackendAnnotation,
          WriteVcdAnnotation
        )
      ) { dut =>
        dut.clock.step(16)

        def enqueueReq() {
          dut.io.float.valid.poke(true.B)
          dut.clock.step(1)
          dut.io.float.valid.poke(false.B)
        }

        def expectResp()(x: IEEEToHF => Unit) {
          while (dut.io.hardfloat.valid.peek().litToBoolean == false) {
            dut.clock.step(1)
          }
          dut.io.hardfloat.valid.expect(true.B)
          x(dut)
          dut.clock.step(1)
        }

        dut.io.float.bits(0).poke("h03f800000".U) // 1
        dut.io.float.bits(1).poke("h042c80000".U) // 100
        enqueueReq()
        expectResp() { dut =>
          dut.io.hardfloat.bits(0).expect("h080000000".U)
          dut.io.hardfloat.bits(1).expect("h083480000".U)
        }

      }
  }
}
