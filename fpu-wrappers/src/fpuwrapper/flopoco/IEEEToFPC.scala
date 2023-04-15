package fpuwrapper.flopoco

import fpuwrapper._
import spinal.core._
import spinal.lib._

class IEEEToFPCInner(floatType: FloatType) extends Component {
  val io = new Bundle {
    val req = in(UInt(floatType.width() bits))
    val resp = out(UInt(floatType.widthFlopoco() bits))
  }

  val ieee = io.req
  val fracX = ieee(floatType.sig() - 2 downto 0)
  val expX = ieee(floatType.width() - 2 downto floatType.sig() - 1)
  val sX = ieee(floatType.width() - 1)

  val expZero = expX === 0
  val expInfty = expX.andR
  val fracZero = fracX === 0
  val reprSubNormal = fracX(floatType.sig() - 2)

  // representable subnormal numbers
  val sfracX = UInt(floatType.sig() - 1 bits)
  when(expZero && reprSubNormal) {
    sfracX := fracX(floatType.sig() - 3 downto 0) << 1
  } otherwise {
    sfracX := fracX
  }

  val fpc = UInt(floatType.widthFlopoco() bits)
  io.resp := fpc

  val fracR = UInt(floatType.sig() - 1 bits)
  val expR = UInt(floatType.exp() bits)
  val sR = Bool()
  val exnR = UInt(2 bits)
  fpc := Cat(exnR, sR, expR, fracR).asUInt

  sR := sX
  expR := expX
  fracR := sfracX

  when(expInfty) {
    when(fracZero) {
      // inf
      exnR := 2
    } otherwise {
      // nan
      exnR := 3
    }
  } elsewhen (expZero && !reprSubNormal) {
    // zero
    exnR := 0
  } otherwise {
    // normal and representable subnormal
    exnR := 1
  }
}

/** Conversion from IEEE for flopoco format
  *
  * @param floatType
  * @param lanes
  */
class IEEEToFPC(floatType: FloatType, lanes: Int, stages: Int)
    extends Component {
  val io = new Bundle {
    val req = slave(Flow(Vec(UInt(floatType.width() bits), lanes)))
    val resp = master(Flow(Vec(UInt(floatType.widthFlopoco() bits), lanes)))
  }

  io.resp.valid := Delay(io.req.valid, stages)

  for (i <- 0 until lanes) {
    val inner = new IEEEToFPCInner(floatType)
    inner.io.req := io.req.payload(i)
    io.resp.payload(i) := Delay(inner.io.resp, stages)
  }
}

object IEEEToFPC extends EmitSpinalModule {
  emitFlopoco(
    0,
    (floatType, lanes, stages) => new IEEEToFPC(floatType, lanes, stages),
    "FlopocoIEEEToFPC"
  )
}
