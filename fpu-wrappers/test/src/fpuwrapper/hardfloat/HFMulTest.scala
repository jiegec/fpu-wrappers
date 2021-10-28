package fpuwrapper.hardfloat

import chisel3._
import chisel3.tester._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._
import fpuwrapper.FloatS
import fpuwrapper.Simulator

class HFMulTest extends AnyFreeSpec with ChiselScalatestTester {
  for (stages <- 1 to 5) {
    s"HFMul of ${stages} stages should work" in {
      test(new HFMul(FloatS, 2, stages))
        .withAnnotations(Simulator.getAnnotations) { dut =>
          dut.clock.step(16)

          def enqueueReq() {
            dut.io.req.valid.poke(true.B)
            dut.clock.step(1)
            dut.io.req.valid.poke(false.B)
          }

          def expectResp()(x: HFMul => Unit) {
            val expectedCycles = stages - 1
            var cycles = 0
            while (dut.io.resp.valid.peek().litToBoolean == false) {
              dut.clock.step(1)
              cycles += 1
            }
            dut.io.resp.valid.expect(true.B)
            x(dut)
            dut.clock.step(1)
            assert(
              cycles == expectedCycles,
              s"Response does not appear after expected cycles: ${cycles} != ${expectedCycles}"
            )
          }

          dut.io.req.bits.a(0).poke("h080000000".U) // 1
          dut.io.req.bits.b(0).poke("h080800000".U) // 2
          dut.io.req.bits.a(1).poke("h080c00000".U) // 3
          dut.io.req.bits.b(1).poke("h081000000".U) // 4
          enqueueReq()
          expectResp() { dut =>
            dut.io.resp.bits.res(0).expect("h080800000".U) // 2
            dut.io.resp.bits.res(1).expect("h081c00000".U) // 12
          }
        }
    }
  }
}
