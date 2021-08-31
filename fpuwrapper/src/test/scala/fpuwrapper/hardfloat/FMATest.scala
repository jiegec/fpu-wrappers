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

class FMASpec extends FreeSpec with ChiselScalatestTester {
  "FMA should work" in {
    test(new FMA(FloatS, 2, 3))
      .withAnnotations(
        Seq(
          VerilatorBackendAnnotation,
          WriteVcdAnnotation
        )
      ) { dut =>
        dut.clock.step(16)

        def enqueueReq() {
          dut.io.req.valid.poke(true.B)
          dut.clock.step(1)
          dut.io.req.valid.poke(false.B)
        }

        def expectResp()(x: FMA => Unit) {
          while (dut.io.resp.valid.peek().litToBoolean == false) {
            dut.clock.step(1)
          }
          dut.io.resp.valid.expect(true.B)
          x(dut)
          dut.clock.step(1)
        }

        dut.io.req.bits.operands(0)(0).poke("h080000000".U) // 1
        dut.io.req.bits.operands(1)(0).poke("h080800000".U) // 2
        dut.io.req.bits.operands(2)(0).poke("h080c00000".U) // 3
        dut.io.req.bits.operands(0)(1).poke("h081000000".U) // 4
        dut.io.req.bits.operands(1)(1).poke("h081200000".U) // 5
        dut.io.req.bits.operands(2)(1).poke("h081400000".U) // 6
        dut.io.req.bits.op.poke(FMAOp.FMADD)
        enqueueReq()
        expectResp() { dut =>
          dut.io.resp.bits.res(0).expect("h081200000".U) // 5
          dut.io.resp.bits.res(1).expect("h082500000".U) // 26
        }
      }
  }
}
