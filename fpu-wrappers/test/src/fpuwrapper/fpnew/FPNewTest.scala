package fpuwrapper.fpnew

import chisel3._
import chisel3.tester._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._
import fpuwrapper.FloatS
import chiseltest.simulator.VerilatorBackendAnnotation
import chiseltest.simulator.VerilatorFlags
import chiseltest.simulator.WriteVcdAnnotation

class FPUTest extends AnyFreeSpec with ChiselScalatestTester {
  for (stages <- 1 to 5) {
    s"FPU of ${stages} stages should work" in {
      test(new FPU(FloatS, 2, stages))
        .withAnnotations(
          Seq(
            VerilatorBackendAnnotation,
            VerilatorFlags(Seq("-Wno-BLKANDNBLK")),
            WriteVcdAnnotation
          )
        ) { dut =>
          dut.clock.step(16)

          def enqueueReq() {
            dut.io.req.valid.poke(true.B)
            while (dut.io.req.ready.peek().litToBoolean == false) {
              dut.clock.step(1)
            }
            dut.clock.step(1)
            dut.io.req.valid.poke(false.B)
          }

          def expectResp()(x: FPU => Unit) {
            dut.io.resp.ready.poke(true.B)
            while (dut.io.resp.valid.peek().litToBoolean == false) {
              dut.clock.step(1)
            }
            dut.io.resp.valid.expect(true.B)
            x(dut)
            dut.io.resp.ready.poke(true.B)
            dut.clock.step(1)
          }

          dut.io.req.bits.operands(0).poke("h3f8000003f800000".U) // 1
          dut.io.req.bits.operands(1).poke("h4000000040000000".U) // 2
          dut.io.req.bits.operands(2).poke("h4040000040400000".U) // 3
          dut.io.req.bits.op.poke(FPOperation.FMADD)
          dut.io.req.bits.srcFormat.poke(FPFloatFormat.Fp32)
          dut.io.req.bits.dstFormat.poke(FPFloatFormat.Fp32)
          enqueueReq()
          expectResp() { dut =>
            dut.io.resp.bits.result.expect("h40a0000040a00000".U)
          } // 5
        }
    }
  }
}
