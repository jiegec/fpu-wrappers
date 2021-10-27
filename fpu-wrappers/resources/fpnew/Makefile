ROOT = ../../../thirdparty
VSRCS = $(ROOT)/fpnew/src/common_cells/src/rr_arb_tree.sv \
		$(ROOT)/fpnew/src/common_cells/src/cf_math_pkg.sv \
		$(ROOT)/fpnew/src/common_cells/src/lzc.sv \
		$(ROOT)/fpnew/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv \
		$(ROOT)/fpnew/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv \
		$(ROOT)/fpnew/src/fpu_div_sqrt_mvp/hdl/div_sqrt_top_mvp.sv \
		$(ROOT)/fpnew/src/fpu_div_sqrt_mvp/hdl/iteration_div_sqrt_mvp.sv \
		$(ROOT)/fpnew/src/fpu_div_sqrt_mvp/hdl/norm_div_sqrt_mvp.sv \
		$(ROOT)/fpnew/src/fpu_div_sqrt_mvp/hdl/nrbd_nrsc_mvp.sv \
		$(ROOT)/fpnew/src/fpu_div_sqrt_mvp/hdl/preprocess_mvp.sv
VSRCS += $(ROOT)/fpnew/src/fpnew_pkg.sv \
		$(ROOT)/fpnew/src/fpnew_cast_multi.sv \
		$(ROOT)/fpnew/src/fpnew_classifier.sv \
		$(ROOT)/fpnew/src/fpnew_divsqrt_multi.sv \
		$(ROOT)/fpnew/src/fpnew_fma.sv \
		$(ROOT)/fpnew/src/fpnew_fma_multi.sv \
		$(ROOT)/fpnew/src/fpnew_noncomp.sv \
		$(ROOT)/fpnew/src/fpnew_opgroup_block.sv \
		$(ROOT)/fpnew/src/fpnew_opgroup_fmt_slice.sv \
		$(ROOT)/fpnew/src/fpnew_opgroup_multifmt_slice.sv \
		$(ROOT)/fpnew/src/fpnew_rounding.sv \
		$(ROOT)/fpnew/src/fpnew_top.sv
VSRCS += FPNewBlackbox.sv

VERILATOR_OPTS = -E +incdir+$(ROOT)/fpnew/src/common_cells/include

FPNewBlackbox.preprocessed.sv: Makefile $(VSRCS)
	cat $(VSRCS) > cat.sv
	verilator --cc --exe $(VERILATOR_OPTS) cat.sv --top-module FPNewBlackbox > $@
	gsed -i '/^`line/d' $@
	rm cat.sv
