package fpuwrapper.flopoco

import fpuwrapper.EmitSpinalModule
import fpuwrapper.FloatType
import fpuwrapper.Resource
import spinal.core._
import spinal.lib._

class FPCFExpRequest(val floatType: FloatType, val lanes: Int) extends Bundle {
  val a = Vec(UInt(floatType.widthFlopoco bits), lanes)
}

class FPCFExpResponse(val floatType: FloatType, val lanes: Int) extends Bundle {
  // result
  val res = Vec(UInt(floatType.widthFlopoco bits), lanes)
}

class FPCFExp(floatType: FloatType, lanes: Int, stages: Int) extends Component {
  val io = new Bundle {
    val req = slave(Flow(new FPCFExpRequest(floatType, lanes)))
    val resp = master(Flow(new FPCFExpResponse(floatType, lanes)))
  }

  for (i <- 0 until lanes) {
    val fma = new FPCFExpBlackBox(floatType, stages)
    fma.X := io.req.a(i).asBits
    io.resp.res(i) := fma.R.asUInt
  }

  io.resp.valid := Delay(io.req.valid, stages)
}

class FPCFExpBlackBox(floatType: FloatType, stages: Int) extends BlackBox {
  val clk = in(Bool())
  val X = in(Bits(floatType.widthFlopoco bits))
  val R = out(Bits(floatType.widthFlopoco bits))

  setDefinitionName(s"FPCFExp_${floatType.kind().toString()}")

  // Map the clk
  mapCurrentClockDomain(
    clock = clk
  )

  val fileName = s"FPCFExp_${floatType.kind().toString()}${stages}s.v"
  assert(
    getClass().getResource(s"/flopoco/${fileName}") != null,
    s"file ${fileName} not found"
  )
  addRTLPath(Resource.path(s"/flopoco/${fileName}"))
}

object FPCFExp extends EmitSpinalModule {
  emitFlopoco(
    3,
    (floatType, lanes, stages) => new FPCFExp(floatType, lanes, stages),
    "FlopocoFPCFExp"
  )
}
