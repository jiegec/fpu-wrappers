package fpuwrapper.hardfloat

import chisel3._
import chisel3.util._
import chisel3.experimental._

class MulRecFNPipe(expWidth: Int, sigWidth: Int, latency: Int) extends Module {
  val io = IO(new Bundle {
    val validin = Input(Bool())
    val a = Input(UInt((expWidth + sigWidth + 1).W))
    val b = Input(UInt((expWidth + sigWidth + 1).W))
    val roundingMode = Input(UInt(3.W))
    val detectTininess = Input(Bool())

    val out = Output(UInt((expWidth + sigWidth + 1).W))
    val exceptionFlags = Output(UInt(5.W))
    val validout = Output(Bool())
  })

  //------------------------------------------------------------------------
  //------------------------------------------------------------------------
  val mulRawFN = Module(new _root_.hardfloat.MulRawFN(expWidth, sigWidth))

  mulRawFN.io.a := _root_.hardfloat.rawFloatFromRecFN(expWidth, sigWidth, io.a)
  mulRawFN.io.b := _root_.hardfloat.rawFloatFromRecFN(expWidth, sigWidth, io.b)

  //------------------------------------------------------------------------
  //------------------------------------------------------------------------
  val roundRawFNToRecFN =
    Module(new _root_.hardfloat.RoundRawFNToRecFN(expWidth, sigWidth, 0))
  roundRawFNToRecFN.io.invalidExc := Pipe(
    io.validin,
    mulRawFN.io.invalidExc,
    latency
  ).bits
  roundRawFNToRecFN.io.infiniteExc := false.B
  roundRawFNToRecFN.io.in := Pipe(
    io.validin,
    mulRawFN.io.rawOut,
    latency
  ).bits
  roundRawFNToRecFN.io.roundingMode := Pipe(
    io.validin,
    io.roundingMode,
    latency
  ).bits
  roundRawFNToRecFN.io.detectTininess := Pipe(
    io.validin,
    io.detectTininess,
    latency
  ).bits

  io.validout := Pipe(io.validin, false.B, latency).valid
  io.out := roundRawFNToRecFN.io.out
  io.exceptionFlags := roundRawFNToRecFN.io.exceptionFlags
}
