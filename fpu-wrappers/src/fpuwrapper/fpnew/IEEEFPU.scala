package fpuwrapper.fpnew

import chisel3._
import chisel3.experimental.ChiselEnum
import chisel3.util.Decoupled
import fpuwrapper.EmitChiselModule
import fpuwrapper.FloatType
import fpuwrapper.FpKind
import fpuwrapper.FloatS
import fpuwrapper.Synthesis

class FPConfig(
)

object FPFloatFormat extends ChiselEnum {
  val Fp32, Fp64, Fp16, Fp8, Fp16Alt = Value
}

object FPIntFormat extends ChiselEnum {
  val Int8, Int16, Int32, Int64 = Value
}

object FPOperation extends ChiselEnum {
  val FMADD, FNMSUB, ADD, MUL, DIV, SQRT, SGNJ, MINMAX, CMP, CLASSIFY, F2F, F2I,
      I2F, CPKAB, CPKCD = Value
}

object FPRoundingMode extends ChiselEnum {
  val RNE, RTZ, RDN, RUP, RMM, DYN = Value
}

class FPRequest(val fLen: Int) extends Bundle {
  val operands = Vec(3, UInt(fLen.W))
  val roundingMode = FPRoundingMode()
  val op = FPOperation()
  val opModifier = Bool()
  val srcFormat = FPFloatFormat()
  val dstFormat = FPFloatFormat()
  val intFormat = FPIntFormat()
}

class FPStatus extends Bundle {
  val NV = Bool() // Invalid
  val DZ = Bool() // Divide by zero
  val OF = Bool() // Overflow
  val UF = Bool() // Underflow
  val NX = Bool() // Inexact
}

class FPResponse(val fLen: Int) extends Bundle {
  val result = UInt(fLen.W)
  val status = new FPStatus()
}

/** FPNew IO port. For meanings of ports, visit
  * https://github.com/pulp-platform/fpnew/blob/develop/docs/README.md
  */
class FPIO(val fLen: Int) extends Bundle {
  val req = Flipped(Decoupled(new FPRequest(fLen)))
  val resp = Decoupled(new FPResponse(fLen))
  val flush = Input(Bool())
  val busy = Output(Bool())
}

class IEEEFPU(
    val floatType: FloatType,
    val lanes: Int,
    val stages: Int
) extends Module {

  val fLen = floatType.width() * lanes
  val io = IO(new FPIO(fLen))

  val blackbox = Module(
    new FPNewBlackbox(
      floatType,
      lanes,
      stages,
      tagWidth = 0,
    )
  )

  // clock & reset
  blackbox.io.clk_i := clock
  blackbox.io.rst_ni := ~reset.asBool()

  // request
  blackbox.io.operands_i := io.req.bits.operands.asUInt()
  blackbox.io.rnd_mode_i := io.req.bits.roundingMode.asUInt()
  blackbox.io.op_i := io.req.bits.op.asUInt()
  blackbox.io.op_mod_i := io.req.bits.opModifier
  blackbox.io.src_fmt_i := io.req.bits.srcFormat.asUInt()
  blackbox.io.dst_fmt_i := io.req.bits.dstFormat.asUInt()
  blackbox.io.int_fmt_i := io.req.bits.intFormat.asUInt()
  blackbox.io.vectorial_op_i := 1.B
  blackbox.io.tag_i := 0.B
  blackbox.io.in_valid_i := io.req.valid
  io.req.ready := blackbox.io.in_ready_o

  // response
  io.resp.bits.result := blackbox.io.result_o
  io.resp.bits.status := blackbox.io.status_o.asTypeOf(io.resp.bits.status)
  io.resp.valid := blackbox.io.out_valid_o
  blackbox.io.out_ready_i := io.resp.ready

  // flush & flush
  blackbox.io.flush_i := io.flush
  io.busy := blackbox.io.busy_o
}

object IEEEFPU extends EmitChiselModule {
  emitChisel(
    (floatType, lanes, stages) => new IEEEFPU(floatType, lanes, stages),
    "IEEEFPU",
    "fpnew"
  )
}

object IEEEFPUSynth extends EmitChiselModule {
  for (floatType <- Seq(FloatS)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(2)) {
      for (lanes <- Seq(1)) {
        emitChisel(
          (floatType, lanes, stages) => new IEEEFPU(floatType, lanes, stages),
          "IEEEFPU",
          "fpnew",
          allStages = Seq(stages),
          floatTypes = Seq(floatType),
          lanes = Seq(lanes)
        )
        val name = s"IEEEFPU_${floatName}${lanes}l${stages}s_fpnew"

        val fileName = s"FPNewBlackbox_${floatType.kind().toString()}${lanes}l${stages}s.synth.v"
        Synthesis.build(
          Seq(s"${name}.v", s"./fpu-wrappers/resources/fpnew/${fileName}"),
          s"${name}_IEEEFPU",
          s"${name}"
        )
      }
    }
  }
}
