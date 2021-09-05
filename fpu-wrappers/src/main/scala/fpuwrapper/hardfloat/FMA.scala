package fpuwrapper.hardfloat

import chisel3._
import chisel3.util._
import chisel3.experimental._
import fpuwrapper._

object FMAOp extends ChiselEnum {
  // 1 * op[1] + op[2]
  val FADD = Value
  // 1 * op[1] - op[2]
  val FSUB = Value
  // op[0] * op[1] + 0
  val FMUL = Value
  // op[0] * op[1] + op[2]
  val FMADD = Value
  // op[0] * op[1] - op[2]
  val FMSUB = Value
  // -(op[0] * op[1] - op[2])
  val FNMSUB = Value
  // -(op[0] * op[1] + op[2])
  val FNMADD = Value

  val NOP = FADD

  implicit def bitpat(op: FMAOp.Type): BitPat =
    BitPat(op.litValue().U)
}

class FMARequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val op = FMAOp()
  val operands = Vec(3, Vec(lanes, UInt(floatType.widthHardfloat.W)))
}

class FMAResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(lanes, UInt(floatType.widthHardfloat.W))
  // exception status
  val exc = Vec(lanes, Bits(5.W))
}

class FMA(floatType: FloatType, lanes: Int, stages: Int) extends Module {

  val io = IO(new Bundle {
    val req = Flipped(Valid(new FMARequest(floatType, lanes)))
    val resp = Valid(new FMAResponse(floatType, lanes))
  })

  val one = Wire(Vec(lanes, UInt(floatType.widthHardfloat().W)))
  val zero = Wire(Vec(lanes, UInt(floatType.widthHardfloat().W)))
  for (i <- 0 until lanes) {
    one(i) := floatType.oneHardfloatChisel()
    zero(i) := 0.U
  }

  // fma: neg * (op[0] * op[1]) + sign * op[2]
  // neg: {0 => 1, 1 => -1}
  // sub: {0 => 1, 1 => -1}
  val op1 = WireInit(io.req.bits.operands(0))
  val op2 = WireInit(io.req.bits.operands(1))
  val op3 = WireInit(io.req.bits.operands(2))
  val neg = WireInit(false.B)
  val sign = WireInit(false.B)

  // see the definition of FMAOp for more detail
  switch(io.req.bits.op) {
    is(FMAOp.FADD) {
      op1 := one
    }
    is(FMAOp.FSUB) {
      op1 := one
      sign := true.B
    }
    is(FMAOp.FMUL) {
      op3 := zero
    }
    is(FMAOp.FMADD) {
      // do nothing
    }
    is(FMAOp.FMSUB) {
      sign := true.B
    }
    is(FMAOp.FNMSUB) {
      neg := true.B
    }
    is(FMAOp.FNMADD) {
      neg := true.B
      sign := true.B
    }
  }

  // replicate small units for higher throughput
  val reqValid = io.req.valid
  val results = for (i <- 0 until lanes) yield {
    // MulAddRecFNPipe only support stages <= 2
    val fma = Module(
      new MulAddRecFNPipe(
        stages min 2,
        floatType.exp(),
        floatType.sig()
      )
    )
    fma.suggestName(s"fma_${floatType.kind()}_${i}")
    // TODO: mask
    // when stages > 2, handle the rest here
    fma.io.validin := Pipe(reqValid, reqValid, (stages - 2) max 0).bits
    fma.io.a := Pipe(
      reqValid,
      op1(i),
      (stages - 2) max 0
    ).bits
    fma.io.b := Pipe(
      reqValid,
      op2(i),
      (stages - 2) max 0
    ).bits
    fma.io.c := Pipe(
      reqValid,
      op3(i),
      (stages - 2) max 0
    ).bits

    fma.io.op := Pipe(
      reqValid,
      Cat(neg, sign),
      (stages - 2) max 0
    ).bits
    // TODO
    fma.io.roundingMode := 0.U
    fma.io.detectTininess := 0.U

    val res = fma.io.out
    val exc = fma.io.exceptionFlags
    (res, exc)
  }

  // collect result
  val res = results.map(_._1)
  // exception flags
  val exc = results.map(_._2)

  val resValid = ShiftRegister(reqValid, stages)

  io.resp.valid := resValid
  io.resp.bits.res := res
  io.resp.bits.exc := exc
}

// https://github.com/chipsalliance/rocket-chip/blob/master/src/main/scala/tile/FPU.scala
class MulAddRecFNPipe(latency: Int, expWidth: Int, sigWidth: Int)
    extends Module {
  require(latency <= 2)

  val io = IO(new Bundle {
    val validin = Input(Bool())
    val op = Input(Bits(2.W))
    val a = Input(Bits((expWidth + sigWidth + 1).W))
    val b = Input(Bits((expWidth + sigWidth + 1).W))
    val c = Input(Bits((expWidth + sigWidth + 1).W))
    val roundingMode = Input(UInt(3.W))
    val detectTininess = Input(UInt(1.W))
    val out = Output(Bits((expWidth + sigWidth + 1).W))
    val exceptionFlags = Output(Bits(5.W))
    val validout = Output(Bool())
  })

  //------------------------------------------------------------------------
  //------------------------------------------------------------------------

  val mulAddRecFNToRaw_preMul = Module(
    new _root_.hardfloat.MulAddRecFNToRaw_preMul(expWidth, sigWidth)
  )
  val mulAddRecFNToRaw_postMul = Module(
    new _root_.hardfloat.MulAddRecFNToRaw_postMul(expWidth, sigWidth)
  )

  mulAddRecFNToRaw_preMul.io.op := io.op
  mulAddRecFNToRaw_preMul.io.a := io.a
  mulAddRecFNToRaw_preMul.io.b := io.b
  mulAddRecFNToRaw_preMul.io.c := io.c

  val mulAddResult =
    (mulAddRecFNToRaw_preMul.io.mulAddA *
      mulAddRecFNToRaw_preMul.io.mulAddB) +&
      mulAddRecFNToRaw_preMul.io.mulAddC

  val valid_stage0 = Wire(Bool())
  val roundingMode_stage0 = Wire(UInt(3.W))
  val detectTininess_stage0 = Wire(UInt(1.W))

  val postmul_regs = if (latency > 0) 1 else 0
  mulAddRecFNToRaw_postMul.io.fromPreMul := Pipe(
    io.validin,
    mulAddRecFNToRaw_preMul.io.toPostMul,
    postmul_regs
  ).bits
  mulAddRecFNToRaw_postMul.io.mulAddResult := Pipe(
    io.validin,
    mulAddResult,
    postmul_regs
  ).bits
  mulAddRecFNToRaw_postMul.io.roundingMode := Pipe(
    io.validin,
    io.roundingMode,
    postmul_regs
  ).bits
  roundingMode_stage0 := Pipe(io.validin, io.roundingMode, postmul_regs).bits
  detectTininess_stage0 := Pipe(
    io.validin,
    io.detectTininess,
    postmul_regs
  ).bits
  valid_stage0 := Pipe(io.validin, false.B, postmul_regs).valid

  //------------------------------------------------------------------------
  //------------------------------------------------------------------------

  val roundRawFNToRecFN = Module(
    new _root_.hardfloat.RoundRawFNToRecFN(expWidth, sigWidth, 0)
  )

  val round_regs = if (latency == 2) 1 else 0
  roundRawFNToRecFN.io.invalidExc := Pipe(
    valid_stage0,
    mulAddRecFNToRaw_postMul.io.invalidExc,
    round_regs
  ).bits
  roundRawFNToRecFN.io.in := Pipe(
    valid_stage0,
    mulAddRecFNToRaw_postMul.io.rawOut,
    round_regs
  ).bits
  roundRawFNToRecFN.io.roundingMode := Pipe(
    valid_stage0,
    roundingMode_stage0,
    round_regs
  ).bits
  roundRawFNToRecFN.io.detectTininess := Pipe(
    valid_stage0,
    detectTininess_stage0,
    round_regs
  ).bits
  io.validout := Pipe(valid_stage0, false.B, round_regs).valid

  roundRawFNToRecFN.io.infiniteExc := false.B

  io.out := roundRawFNToRecFN.io.out
  io.exceptionFlags := roundRawFNToRecFN.io.exceptionFlags
}

object FMA extends EmitHardfloatModule {
  for (stages <- Seq(1, 2, 3, 4)) {
    emitHardfloat(
      stages,
      (floatType, lanes, stages) => new FMA(floatType, lanes, stages),
      "FMA"
    )
  }
}

object FMASynth extends App {
  for (stages <- Seq(4)) {
    val name = s"FMA_D1l${stages}s"
    Synthesis.build(Seq(s"${name}.v"), s"${name}_FMA", s"hardfloat_${name}")
  }
}
