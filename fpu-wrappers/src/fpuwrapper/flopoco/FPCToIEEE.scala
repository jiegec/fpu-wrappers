package fpuwrapper.flopoco

import fpuwrapper._
import spinal.core._
import spinal.lib._

class FPCToIEEEInner(floatType: FloatType) extends Component {
  val io = new Bundle {
    val req = in(UInt(floatType.widthFlopoco() bits))
    val resp = out(UInt(floatType.width() bits))
  }

  val fpc = io.req
  val fracX = fpc(floatType.sig() - 2 downto 0)
  val expX = fpc(floatType.width() - 2 downto floatType.sig() - 1)
  val sX = Bool
  val exnX = fpc(floatType.width() + 1 downto floatType.width())
  when(exnX === 1 || exnX === 2 || exnX === 0) {
    sX := fpc(floatType.width() - 1)
  } otherwise {
    sX := False
  }

  val expZero = expX === 0

  val ieee = UInt(floatType.width() bits)
  io.resp := ieee

  val fracR = UInt(floatType.sig() - 1 bits)
  val expR = UInt(floatType.exp() bits)
  val sR = Bool
  ieee := Cat(sR, expR, fracR).asUInt

  switch(exnX) {
    is(0) {
      // zero
      fracR := 0
      expR := 0
      sR := sX
    }
    is(1) {
      // normal
      when(expZero) {
        fracR := Cat(True, fracX(floatType.sig() - 2 downto 1)).asUInt
      }.otherwise {
        fracR := fracX
      }
      expR := expX
      sR := sX
    }
    is(2) {
      // inf
      fracR := exnX(0).asUInt.resized
      expR.setAllTo(True)
      sR := sX
    }
    default {
      // nan
      fracR := exnX(0).asUInt.resized
      expR.setAllTo(True)
      sR := False
    }
  }
}

/** Implementation of OutputIEEE operator of Flopoco
  *
  * @param floatType
  *   @param lanes
  */
class FPCToIEEE(floatType: FloatType, lanes: Int, stages: Int)
    extends Component {
  val io = new Bundle {
    val req = slave(Flow(Vec(UInt(floatType.widthFlopoco() bits), lanes)))
    val resp = master(Flow(Vec(UInt(floatType.width() bits), lanes)))
  }

  io.resp.valid := Delay(io.req.valid, stages)

  for (i <- 0 until lanes) {
    val inner = new FPCToIEEEInner(floatType)
    inner.io.req := io.req.payload(i)
    io.resp.payload(i) := Delay(inner.io.resp, stages)
  }
}

object FPCToIEEE extends EmitSpinalModule {
  emitFlopoco(
    0,
    (floatType, lanes, stages) => new FPCToIEEE(floatType, lanes, stages),
    "FlopocoFPCToIEEE"
  )
}
