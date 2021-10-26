package fpuwrapper.hardfloat

import chisel3._
import chisel3.tester._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._
import fpuwrapper.FloatS

class IEEEFMATest extends AnyFreeSpec with ChiselScalatestTester {
  for (stages <- 1 to 5) {
    s"IEEEFMA of ${stages} stages should work" in {
      test(new IEEEFMA(FloatS, 2, stages))
        .withAnnotations(
          Seq(
          )
        ) { dut =>
          dut.clock.step(16)

          def enqueueReq() {
            dut.io.req.valid.poke(true.B)
            dut.clock.step(1)
            dut.io.req.valid.poke(false.B)
          }

          def expectResp()(x: IEEEFMA => Unit) {
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

          dut.io.req.bits.operands(0)(0).poke("h3f800000".U) // 1
          dut.io.req.bits.operands(1)(0).poke("h40000000".U) // 2
          dut.io.req.bits.operands(2)(0).poke("h40400000".U) // 3
          dut.io.req.bits.operands(0)(1).poke("h40800000".U) // 4
          dut.io.req.bits.operands(1)(1).poke("h40a00000".U) // 5
          dut.io.req.bits.operands(2)(1).poke("h40c00000".U) // 6
          dut.io.req.bits.op.poke(FMAOp.FMADD)
          enqueueReq()
          expectResp() { dut =>
            dut.io.resp.bits.res(0).expect("h40a00000".U) // 5
            dut.io.resp.bits.res(1).expect("h41d00000".U) // 26
          }
        }
    }
  }
}
