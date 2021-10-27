package fpuwrapper.flopoco

import org.scalatest.funsuite.AnyFunSuite
import spinal.core._
import spinal.core.sim._
import fpuwrapper.FloatS

// FMA's testbench
class FMATest extends AnyFunSuite {
  test("FMA") {
    SimConfig.withWave.withIVerilog.withLogging
      .doSim(
        new FMA(
          FloatS,
          2,
          3
        )
      ) { dut =>
        dut.clockDomain.forkStimulus(period = 10)
        dut.clockDomain.waitRisingEdge()

        dut.io.req.valid #= false
        sleep(160)

        dut.clockDomain.waitSampling()
        dut.io.req.valid #= true
        dut.io.req.operands(0)(0) #= BigInt("3f800000", 16) // 1.0
        dut.io.req.operands(1)(0) #= BigInt("40000000", 16) // 2.0
        dut.io.req.operands(2)(0) #= BigInt("40400000", 16) // 3.0
        dut.io.req.operands(0)(1) #= BigInt("40800000", 16) // 4.0
        dut.io.req.operands(1)(1) #= BigInt("40a00000", 16) // 5.0
        dut.io.req.operands(2)(1) #= BigInt("40c00000", 16) // 6.0
        dut.io.req.op #= FMAOp.FMADD

        dut.clockDomain.waitSamplingWhere {
          dut.io.resp.valid.toBoolean
        }
        assert(dut.io.resp.res(0).toBigInt == BigInt("40a00000", 16)) // 5.0
        assert(dut.io.resp.res(1).toBigInt == BigInt("41d00000", 16)) // 26.0

        sleep(100)
      }
  }
}
