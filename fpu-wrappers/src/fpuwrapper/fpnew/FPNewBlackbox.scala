package fpuwrapper.fpnew

import chisel3._
import chisel3.experimental._
import chisel3.util.HasBlackBoxResource
import fpuwrapper.FloatType

class FPNewBlackbox(
    floatType: FloatType,
    lanes: Int,
    stages: Int,
    tagWidth: Int,
) extends BlackBox(
      Map()
    )
    with HasBlackBoxResource {
  val fLen = floatType.width() * lanes
  val io = IO(new Bundle {
    val clk_i = Input(Clock())
    val rst_ni = Input(Bool())
    val operands_i = Input(UInt((fLen * 3).W))
    val rnd_mode_i = Input(UInt(3.W))
    val op_i = Input(UInt(4.W))
    val op_mod_i = Input(Bool())
    val src_fmt_i = Input(UInt(3.W))
    val dst_fmt_i = Input(UInt(3.W))
    val int_fmt_i = Input(UInt(2.W))
    val vectorial_op_i = Input(Bool())
    val tag_i = Input(UInt(tagWidth.W))
    val in_valid_i = Input(Bool())
    val in_ready_o = Output(Bool())
    val flush_i = Input(Bool())
    val result_o = Output(UInt(fLen.W))
    val status_o = Output(UInt(5.W))
    val tag_o = Output(UInt(tagWidth.W))
    val out_valid_o = Output(Bool())
    val out_ready_i = Input(Bool())
    val busy_o = Output(Bool())
  }).suggestName("io")

  addResource(s"/fpnew/FPNewBlackbox_${floatType.kind().toString()}${lanes}l${stages}s.synth.v")
}
