package fpuwrapper.flopoco

import org.scalatest.funsuite.AnyFunSuite
import spinal.core._
import spinal.core.sim._
import fpuwrapper.FloatS

// IEEEFMA's testbench
class IEEEFMATest extends AnyFunSuite {
  test("IEEEFMA") {
    val stages = 3
    SimConfig.withWave.withIVerilog
      .doSim(
        new IEEEFMA(
          FloatS,
          2,
          stages
        )
      ) { dut =>
        dut.clockDomain.forkStimulus(period = 10)
        dut.clockDomain.waitRisingEdge()

        var cycles = 0
        dut.clockDomain.onRisingEdges {
          cycles = cycles + 1
        }

        dut.io.req.valid #= false
        sleep(160)

        dut.clockDomain.waitRisingEdge()
        dut.io.req.valid #= true
        dut.io.req.operands(0)(0) #= BigInt("3f800000", 16) // 1.0
        dut.io.req.operands(1)(0) #= BigInt("40000000", 16) // 2.0
        dut.io.req.operands(2)(0) #= BigInt("40400000", 16) // 3.0
        dut.io.req.operands(0)(1) #= BigInt("40800000", 16) // 4.0
        dut.io.req.operands(1)(1) #= BigInt("40a00000", 16) // 5.0
        dut.io.req.operands(2)(1) #= BigInt("40c00000", 16) // 6.0
        dut.io.req.op #= IEEEFMAOp.IEEEFMADD

        val beginCycles = cycles
        dut.clockDomain.waitFallingEdgeWhere {
          dut.io.resp.valid.toBoolean
        }
        assert(cycles - beginCycles == stages)
        assert(dut.io.resp.res(0).toBigInt == BigInt("40a00000", 16)) // 5.0
        assert(dut.io.resp.res(1).toBigInt == BigInt("41d00000", 16)) // 26.0

        sleep(100)
      }
  }
}
