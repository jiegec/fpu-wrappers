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

class FCmpSpec extends FreeSpec with ChiselScalatestTester {
  "FCmp should work" in {
    test(new FCmp(FloatS, 2, 2))
      .withAnnotations(
        Seq(
          WriteVcdAnnotation
        )
      ) { dut =>
        dut.clock.step(16)

        def enqueueReq() {
          dut.io.req.valid.poke(true.B)
          dut.clock.step(1)
          dut.io.req.valid.poke(false.B)
        }

        def expectResp()(x: FCmp => Unit) {
          while (dut.io.resp.valid.peek().litToBoolean == false) {
            dut.clock.step(1)
          }
          dut.io.resp.valid.expect(true.B)
          x(dut)
          dut.clock.step(1)
        }

        dut.io.req.bits.r1(0).poke("h080000000".U) // 1
        dut.io.req.bits.r2(0).poke("h000000000".U) // 0
        dut.io.req.bits.r1(1).poke("h083480000".U) // 100
        dut.io.req.bits.r2(1).poke("h083460000".U) // 99
        dut.io.req.bits.op.poke(FCmpOp.GE)
        enqueueReq()
        expectResp() { dut =>
          dut.io.resp.bits.res(0).expect("h00000001".U) // true
          dut.io.resp.bits.res(1).expect("h00000001".U) // true
        }

        dut.io.req.bits.r1(0).poke("h000000000".U) // 0
        dut.io.req.bits.r2(0).poke("h080000000".U) // 1
        dut.io.req.bits.r1(1).poke("h083460000".U) // 99
        dut.io.req.bits.r2(1).poke("h083480000".U) // 100
        dut.io.req.bits.op.poke(FCmpOp.GE)
        enqueueReq()
        expectResp() { dut =>
          dut.io.resp.bits.res(0).expect("h00000000".U) // false
          dut.io.resp.bits.res(1).expect("h00000000".U) // false
        }

        dut.io.req.bits.r1(0).poke("h180000000".U) // -1
        dut.io.req.bits.r2(0).poke("h000000000".U) // 0
        dut.io.req.bits.r1(1).poke("h183460000".U) // -99
        dut.io.req.bits.r2(1).poke("h183480000".U) // -100
        dut.io.req.bits.op.poke(FCmpOp.LT)
        enqueueReq()
        expectResp() { dut =>
          dut.io.resp.bits.res(0).expect("h00000001".U) // true
          dut.io.resp.bits.res(1).expect("h00000000".U) // false
        }
      }
  }
}
