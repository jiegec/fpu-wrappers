package fpuwrapper.flopoco

import fpuwrapper.EmitSpinalModule
import fpuwrapper.FloatS
import fpuwrapper.FloatType
import fpuwrapper.SpinalEmitVerilog
import fpuwrapper.Synthesis
import spinal.core._
import spinal.lib._

class IEEEFExpRequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val a = Vec(UInt(floatType.width bits), lanes)
}

class IEEEFExpResponse(val floatType: FloatType, val lanes: Int)
    extends Bundle {
  // result
  val res = Vec(UInt(floatType.width bits), lanes)
}

class IEEEFExp(floatType: FloatType, lanes: Int, stages: Int)
    extends Component {
  val io = new Bundle {
    val req = slave(Flow(new IEEEFExpRequest(floatType, lanes)))
    val resp = master(Flow(new IEEEFExpResponse(floatType, lanes)))
  }

  for (i <- 0 until lanes) {
    val ieee2fpc = new IEEEToFPCInner(floatType)
    ieee2fpc.io.req := io.req.a(i)

    val fma = new FPCFExpBlackBox(floatType, stages)
    fma.X := ieee2fpc.io.resp.asBits

    val fpc2ieee = new FPCToIEEEInner(floatType)
    fpc2ieee.io.req := fma.R.asUInt
    io.resp.res(i) := fpc2ieee.io.resp
  }

  io.resp.valid := Delay(io.req.valid, stages)
}

object IEEEFExp extends EmitSpinalModule {
  emitFlopoco(
    3,
    (floatType, lanes, stages) => new IEEEFExp(floatType, lanes, stages),
    "FlopocoIEEEFExp"
  )
}

object IEEEFExpSynth extends SpinalEmitVerilog {
  for (floatType <- Seq(FloatS)) {
    val floatName = floatType.kind().toString()
    for (stages <- Seq(3)) {
      val lanes = 1
      val name = s"IEEEFExp_${floatName}${lanes}l${stages}s"
      work(
        new IEEEFExp(floatType, lanes, stages),
        name
      )

      val fileName = s"FPCFExp_${floatName}${stages}s.v"
      Synthesis.build(
        Seq(
          s"${name}.v",
          s"./fpu-wrappers/resources/flopoco/${fileName}"
        ),
        s"IEEEFExp",
        s"${name}_flopoco"
      )
    }
  }
}
