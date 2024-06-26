package fpuwrapper.fudian

import chisel3._
import chisel3.experimental.BundleLiterals._
import fpuwrapper.Simulator._
import org.scalatest.freespec.AnyFreeSpec
import fpuwrapper.FloatS

class IEEEFDivSqrtTest extends AnyFreeSpec {
  s"IEEEFDivSqrt should work" in {
    simulate(new IEEEFDivSqrt(FloatS, 2)) { dut =>
      dut.reset.poke(true.B)
      dut.clock.step()
      dut.reset.poke(false.B)
      dut.clock.step()

      dut.clock.step(16)

      def enqueueReq() = {
        dut.io.req.valid.poke(true.B)
        dut.clock.step(1)
        dut.io.req.valid.poke(false.B)
      }

      def expectResp()(x: IEEEFDivSqrt => Unit) = {
        while (dut.io.resp.valid.peek().litToBoolean == false) {
          dut.clock.step(1)
        }
        dut.io.resp.valid.expect(true.B)
        x(dut)
        dut.clock.step(1)
      }

      dut.io.req.bits.a(0).poke("h3f800000".U) // 1.0
      dut.io.req.bits.b(0).poke("h40000000".U) // 2.0
      dut.io.req.bits.a(1).poke("h40400000".U) // 3.0
      dut.io.req.bits.b(1).poke("h40800000".U) // 4.0
      dut.io.req.bits.op.poke(IEEEFDivSqrtOp.DIV)
      enqueueReq()
      expectResp() { dut =>
        dut.io.resp.bits.res(0).expect("h3f000000".U) // 0.5
        dut.io.resp.bits.res(1).expect("h3f400000".U) // 0.75
      }

      dut.io.req.bits.a(0).poke("h40800000".U) // 4.0
      dut.io.req.bits.b(0).poke("h00000000".U) // 0.0
      dut.io.req.bits.a(1).poke("h41100000".U) // 9.0
      dut.io.req.bits.b(1).poke("h00000000".U) // 0.0
      dut.io.req.bits.op.poke(IEEEFDivSqrtOp.SQRT)
      enqueueReq()
      expectResp() { dut =>
        dut.io.resp.bits.res(0).expect("h40000000".U) // 2.0
        dut.io.resp.bits.res(1).expect("h40400000".U) // 3.0
      }
    }
  }
}
