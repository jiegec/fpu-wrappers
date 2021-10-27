package fpuwrapper.fpnew

import chisel3._
import chisel3.util.HasBlackBoxResource
import chisel3.experimental._

class FPNewBlackbox(
    fLen: Int = 64,
    enableVectors: Boolean = true,
    enableNanBox: Boolean = true,
    enableFP32: Boolean = true,
    enableFP64: Boolean = true,
    enableFP16: Boolean = true,
    enableFP8: Boolean = false,
    enableFP16Alt: Boolean = false,
    enableInt8: Boolean = false,
    enableInt16: Boolean = true,
    enableInt32: Boolean = true,
    enableInt64: Boolean = true,
    tagWidth: Int = 0,
    pipelineStages: Int = 0
) extends BlackBox(
      Map(
        "FLEN" -> IntParam(fLen),
        "ENABLE_VECTORS" -> IntParam(enableVectors.compare(false)),
        "ENABLE_NAN_BOX" -> IntParam(enableNanBox.compare(false)),
        "ENABLE_FP32" -> IntParam(enableFP32.compare(false)),
        "ENABLE_FP64" -> IntParam(enableFP64.compare(false)),
        "ENABLE_FP16" -> IntParam(enableFP16.compare(false)),
        "ENABLE_FP8" -> IntParam(enableFP8.compare(false)),
        "ENABLE_FP16ALT" -> IntParam(enableFP16Alt.compare(false)),
        "ENABLE_INT8" -> IntParam(enableInt8.compare(false)),
        "ENABLE_INT16" -> IntParam(enableInt16.compare(false)),
        "ENABLE_INT32" -> IntParam(enableInt32.compare(false)),
        "ENABLE_INT64" -> IntParam(enableInt64.compare(false)),
        "TAG_WIDTH" -> IntParam(tagWidth),
        "PIPELINE_STAGES" -> IntParam(pipelineStages)
      )
    )
    with HasBlackBoxResource {
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

  addResource("/fpnew/FPNewBlackbox.preprocessed.sv")
}
