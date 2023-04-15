package fpuwrapper.hardfloat

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import fpuwrapper.FloatS
import fpuwrapper.Simulator

class IEEEToHFTest extends AnyFreeSpec with ChiselScalatestTester {
  for (stages <- 1 to 5) {
    s"IEEEToHF of ${stages} stages should work" in {
      test(new IEEEToHF(FloatS, 2, stages))
        .withAnnotations(Simulator.getAnnotations()) { dut =>
          dut.clock.step(16)

          def enqueueReq() = {
            dut.io.float.valid.poke(true.B)
            dut.clock.step(1)
            dut.io.float.valid.poke(false.B)
          }

          def expectResp()(x: IEEEToHF => Unit) = {
            val expectedCycles = stages - 1
            var cycles = 0
            while (dut.io.hardfloat.valid.peek().litToBoolean == false) {
              dut.clock.step(1)
              cycles += 1
            }
            dut.io.hardfloat.valid.expect(true.B)
            x(dut)
            dut.clock.step(1)
            assert(
              cycles == expectedCycles,
              s"Response does not appear after expected cycles: ${cycles} != ${expectedCycles}"
            )
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
}
