package fpuwrapper.flopoco

import fpuwrapper.FloatType
import spinal.lib._
import spinal.core._
import fpuwrapper.EmitFlopocoModule

object FMAOp extends SpinalEnum {
  // 1 * op[1] + op[2]
  val FADD = newElement()
  // 1 * op[1] - op[2]
  val FSUB = newElement()
  // op[0] * op[1] + 0
  val FMUL = newElement()
  // op[0] * op[1] + op[2]
  val FMADD = newElement()
  // op[0] * op[1] - op[2]
  val FMSUB = newElement()
  // -(op[0] * op[1] - op[2])
  val FNMSUB = newElement()
  // -(op[0] * op[1] + op[2])
  val FNMADD = newElement()

  val NOP = FADD
}

class FMARequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val op = FMAOp()
  val operands = Vec(Vec(UInt(floatType.width() bits), lanes), 3)
}

class FMAResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(UInt(floatType.width() bits), lanes)
}

class FMA(floatType: FloatType, lanes: Int, stages: Int) extends Component {
  val io = new Bundle {
    val req = slave(Flow(new FMARequest(floatType, lanes)))
    val resp = master(Flow(new FMAResponse(floatType, lanes)))
  }

  val negateAB = False
  val negateC = False
  val op1 = Vec(UInt(floatType.width() bits), lanes)
  val op2 = Vec(UInt(floatType.width() bits), lanes)
  val op3 = Vec(UInt(floatType.width() bits), lanes)
  op1 := io.req.operands(0)
  op2 := io.req.operands(1)
  op3 := io.req.operands(2)

  val one = Vec(UInt(floatType.width() bits), lanes)
  val zero = Vec(UInt(floatType.width() bits), lanes)
  for (i <- 0 until lanes) {
    one(i) := floatType.oneBigInt()
    zero(i) := 0
  }

  switch(io.req.op) {
    is(FMAOp.FADD) {
      op1 := one
    }
    is(FMAOp.FSUB) {
      op1 := one
      negateC := True
    }
    is(FMAOp.FMUL) {
      op3 := zero
    }
    is(FMAOp.FMADD) {
      // do nothing
    }
    is(FMAOp.FMSUB) {
      negateC := True
    }
    is(FMAOp.FNMSUB) {
      negateAB := True
    }
    is(FMAOp.FNMADD) {
      negateAB := True
      negateC := True
    }
  }

  for (i <- 0 until lanes) {
    val fma = new FMABlackBox(floatType)
    fma.A := op1(i).asBits
    fma.B := op2(i).asBits
    fma.C := op3(i).asBits
    fma.negateAB := negateAB
    fma.negateC := negateC
    fma.RndMode := 0
    io.resp.res(i) := fma.R.asUInt
  }

  io.resp.valid := Delay(io.req.valid, stages)
}

class FMABlackBox(floatType: FloatType) extends BlackBox {
  val clk = in(Bool)
  val A = in(Bits(floatType.width bits))
  val B = in(Bits(floatType.width bits))
  val C = in(Bits(floatType.width bits))
  val negateAB = in(Bool)
  val negateC = in(Bool)
  val RndMode = in(Bits(2 bits))
  val R = out(Bits(floatType.width bits))

  setDefinitionName(s"FMA_S")

  // Map the clk
  mapCurrentClockDomain(
    clock = clk
  )

  addRTLPath(s"./fpuwrapper/src/main/resources/flopoco/flopoco.vhdl")
}

object FMA extends EmitFlopocoModule {
  emitFlopoco(
    3,
    (floatType, lanes, stages) => new FMA(floatType, lanes, stages),
    "FMA"
  )
}
