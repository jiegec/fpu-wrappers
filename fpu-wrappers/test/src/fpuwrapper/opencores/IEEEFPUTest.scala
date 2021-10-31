package fpuwrapper.opencores

import org.scalatest.funsuite.AnyFunSuite
import spinal.core._
import spinal.core.sim._

// IEEEFPU's testbench
class IEEEFPUTest extends AnyFunSuite {
  test("IEEEFPU") {
    SimConfig.withWave.withIVerilog
      .doSim(
        new IEEEFPU()
      ) { dut =>
        dut.clockDomain.forkStimulus(period = 10)
        dut.clockDomain.waitRisingEdge()

        dut.io.req.valid #= false
        sleep(160)

        dut.clockDomain.waitSampling()
        dut.io.req.valid #= true
        dut.io.req.operands(0) #= BigInt("3f800000", 16) // 1.0
        dut.io.req.operands(1) #= BigInt("40000000", 16) // 2.0
        dut.io.req.op #= IEEEFPUOp.FADD

        dut.clockDomain.waitSampling()
        dut.io.req.valid #= false
        dut.clockDomain.waitSamplingWhere {
          dut.io.resp.valid.toBoolean
        }
        assert(dut.io.resp.res.toBigInt == BigInt("40400000", 16)) // 3.0

        dut.clockDomain.waitSampling()
        dut.io.req.valid #= true
        dut.io.req.operands(0) #= BigInt("40400000", 16) // 3.0
        dut.io.req.operands(1) #= BigInt("40800000", 16) // 4.0

        dut.clockDomain.waitSampling()
        dut.io.req.valid #= false
        dut.clockDomain.waitSamplingWhere {
          dut.io.resp.valid.toBoolean
        }
        assert(dut.io.resp.res.toBigInt == BigInt("40e00000", 16)) // 7.0

        sleep(100)
      }
  }
}
