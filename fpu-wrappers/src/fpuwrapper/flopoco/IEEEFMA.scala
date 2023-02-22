package fpuwrapper.flopoco

import fpuwrapper._
import spinal.core._
import spinal.lib._

object IEEEFMAOp extends SpinalEnum {
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

class IEEEFMARequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val op = IEEEFMAOp()
  val operands = Vec(Vec(UInt(floatType.width() bits), lanes), 3)
}

class IEEEFMAResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(UInt(floatType.width() bits), lanes)
}

class IEEEFMA(floatType: FloatType, lanes: Int, stages: Int) extends Component {
  val io = new Bundle {
    val req = slave(Flow(new IEEEFMARequest(floatType, lanes)))
    val resp = master(Flow(new IEEEFMAResponse(floatType, lanes)))
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
    is(IEEEFMAOp.FADD) {
      op1 := one
    }
    is(IEEEFMAOp.FSUB) {
      op1 := one
      negateC := True
    }
    is(IEEEFMAOp.FMUL) {
      op3 := zero
    }
    is(IEEEFMAOp.FMADD) {
      // do nothing
    }
    is(IEEEFMAOp.FMSUB) {
      negateC := True
    }
    is(IEEEFMAOp.FNMSUB) {
      negateAB := True
    }
    is(IEEEFMAOp.FNMADD) {
      negateAB := True
      negateC := True
    }
  }

  for (i <- 0 until lanes) {
    val fma = new IEEEFMABlackBox(floatType, stages)
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

class IEEEFMABlackBox(floatType: FloatType, stages: Int) extends BlackBox {
  val clk = in(Bool())
  val A = in(Bits(floatType.width bits))
  val B = in(Bits(floatType.width bits))
  val C = in(Bits(floatType.width bits))
  val negateAB = in(Bool())
  val negateC = in(Bool())
  val RndMode = in(Bits(2 bits))
  val R = out(Bits(floatType.width bits))

  setDefinitionName(s"IEEEFMA_${floatType.kind().toString()}")

  // Map the clk
  mapCurrentClockDomain(
    clock = clk
  )

  val fileName = s"IEEEFMA_${floatType.kind().toString()}${stages}s.v"
  assert(
    getClass().getResource(s"/flopoco/${fileName}") != null,
    s"file ${fileName} not found"
  )
  addRTLPath(Resource.path(s"/flopoco/${fileName}"))
}

object IEEEFMA extends EmitSpinalModule {
  emitFlopoco(
    3,
    (floatType, lanes, stages) => new IEEEFMA(floatType, lanes, stages),
    "FlopocoIEEEFMA"
  )
}

object IEEEFMASynth extends SpinalEmitVerilog {
  for (floatType <- Seq(FloatS)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(4)) {
      val lanes = 1
      val name = s"IEEEFMA_${floatName}${lanes}l${stages}s"
      work(
        new IEEEFMA(floatType, lanes, stages),
        name
      )

      val fileName = s"IEEEFMA_${floatName}${stages}s.v"
      Synthesis.build(
        Seq(
          s"${name}.v",
          s"./fpu-wrappers/resources/flopoco/${fileName}"
        ),
        s"IEEEFMA",
        s"${name}_flopoco"
      )
    }
  }
}

object IEEEFMABench extends SpinalEmitVerilog with VivadoBench {
  for (floatType <- Seq(FloatS)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(3)) {
      val lanes = 1
      val name = s"IEEEFMA_${floatName}${lanes}l${stages}s"
      work(
        new IEEEFMA(floatType, lanes, stages),
        name
      )

      val fileName = s"IEEEFMA_${floatName}${stages}s.v"
      bench(
        s"${name}_flopoco",
        Seq(s"${name}.v", s"./fpu-wrappers/resources/flopoco/${fileName}"),
        s"IEEEFMA"
      )
    }
  }
}
