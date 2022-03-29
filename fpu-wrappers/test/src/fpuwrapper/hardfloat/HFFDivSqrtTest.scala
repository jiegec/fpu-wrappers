package fpuwrapper.hardfloat

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import fpuwrapper.FloatS
import fpuwrapper.Simulator

class HFFDivSqrtTest extends AnyFreeSpec with ChiselScalatestTester {
  s"HFFDivSqrt should work" in {
    test(new HFFDivSqrt(FloatS, 2))
      .withAnnotations(Simulator.getAnnotations()) { dut =>
        dut.clock.step(16)

        def enqueueReq() {
          dut.io.req.valid.poke(true.B)
          dut.clock.step(1)
          dut.io.req.valid.poke(false.B)
        }

        def expectResp()(x: HFFDivSqrt => Unit) {
          while (dut.io.resp.valid.peek().litToBoolean == false) {
            dut.clock.step(1)
          }
          dut.io.resp.valid.expect(true.B)
          x(dut)
          dut.clock.step(1)
        }

        dut.io.req.bits.a(0).poke("h080000000".U) // 1.0
        dut.io.req.bits.b(0).poke("h080800000".U) // 2.0
        dut.io.req.bits.a(1).poke("h080c00000".U) // 3.0
        dut.io.req.bits.b(1).poke("h081000000".U) // 4.0
        dut.io.req.bits.op.poke(HFFDivSqrtOp.DIV)
        enqueueReq()
        expectResp() { dut =>
          dut.io.resp.bits.res(0).expect("h07f800000".U) // 0.5
          dut.io.resp.bits.res(1).expect("h07fc00000".U) // 0.75
        }

        dut.io.req.bits.a(0).poke("h080000000".U) // 1.0
        dut.io.req.bits.b(0).poke("h180800000".U) // -2.0
        dut.io.req.bits.a(1).poke("h080c00000".U) // 3.0
        dut.io.req.bits.b(1).poke("h181000000".U) // -4.0
        dut.io.req.bits.op.poke(HFFDivSqrtOp.DIV)
        enqueueReq()
        expectResp() { dut =>
          dut.io.resp.bits.res(0).expect("h17f800000".U) // -0.5
          dut.io.resp.bits.res(1).expect("h17fc00000".U) // -0.75
        }

        dut.io.req.bits.a(0).poke("h081000000".U) // 4.0
        dut.io.req.bits.b(0).poke("h000000000".U) // 0.0
        dut.io.req.bits.a(1).poke("h081900000".U) // 9.0
        dut.io.req.bits.b(1).poke("h000000000".U) // 0.0
        dut.io.req.bits.op.poke(HFFDivSqrtOp.SQRT)
        enqueueReq()
        expectResp() { dut =>
          dut.io.resp.bits.res(0).expect("h080800000".U) // 2.0
          dut.io.resp.bits.res(1).expect("h080c00000".U) // 3.0
        }
      }
  }
}
