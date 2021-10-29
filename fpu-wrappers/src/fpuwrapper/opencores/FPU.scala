package fpuwrapper.opencores

import fpuwrapper._
import spinal.core._
import spinal.lib._

import java.nio.file.Paths

object FPUOp extends SpinalEnum {
  val FADD = newElement()
  val FSUB = newElement()
  val FMUL = newElement()
  val FDIV = newElement()

  val NOP = FADD
}

class FPURequest(val floatType: FloatType) extends Bundle {
  val op = FPUOp()
  val operands = Vec(UInt(floatType.width() bits), 2)
}

class FPUResponse(val floatType: FloatType) extends Bundle {
  // result
  val res = UInt(floatType.width() bits)
}

class FPU extends Component {
  val floatType = FloatS
  val stages = 4
  val io = new Bundle {
    val req = slave(Flow(new FPURequest(floatType)))
    val resp = master(Flow(new FPUResponse(floatType)))
  }

  val fpu = new FPUBlackBox(floatType)
  fpu.rmode := 0
  fpu.fpu_op := io.req.op.asBits.resized
  fpu.opa := io.req.operands(0).asBits
  fpu.opb := io.req.operands(1).asBits
  io.resp.res := fpu.out.asUInt

  io.resp.valid := Delay(io.req.valid, stages)
}

class FPUBlackBox(val floatType: FloatType) extends BlackBox {
  val clk = in(Bool)
  val rmode = in(Bits(2 bits))
  val fpu_op = in(Bits(3 bits))
  val opa = in(Bits(floatType.width bits))
  val opb = in(Bits(floatType.width bits))

  val out = spinal.core.out(Bits(floatType.width bits))
  val inf = spinal.core.out(Bool)
  val snan = spinal.core.out(Bool)
  val qnan = spinal.core.out(Bool)
  val ine = spinal.core.out(Bool)
  val overflow = spinal.core.out(Bool)
  val underflow = spinal.core.out(Bool)
  val zero = spinal.core.out(Bool)
  val div_by_zero = spinal.core.out(Bool)

  setDefinitionName("fpu")

  // Map the clk
  mapCurrentClockDomain(
    clock = clk
  )

  val files = Seq(
    "except.v",
    "fpu.v",
    "post_norm.v",
    "pre_norm_fmul.v",
    "pre_norm.v",
    "primitives.v"
  )
  for (file <- files) {
    val res = getClass().getResource(s"/opencores/${file}");
    addRTLPath(Paths.get(res.toURI()).toFile().getAbsolutePath())
  }
}

object FPU extends App {
  val verilog = spinal.core.SpinalConfig(netlistFileName = "OpencoresFPU.v")
  verilog.generateVerilog(new FPU())
}

object FPUSynth extends App {
  val files = Seq(
    "except.v",
    "fpu.v",
    "post_norm.v",
    "pre_norm_fmul.v",
    "pre_norm.v",
    "primitives.v"
  )
  val sources = for (file <- files) yield {
    s"./fpu-wrappers/resources/opencores/${file}"
  }

  Synthesis.build(
    Seq(
      s"OpencoresFPU.v"
    ) ++ sources,
    s"FPU_1",
    s"opencores_FPU"
  )
}
