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
VSRCS += FPNewBlackbox$(SUFFIX).sv

VERILATOR_OPTS = -E +incdir+$(ROOT)/fpnew/src/common_cells/include

# Must use defer here, otherwise it can fail with TAG_WIDTH=0
FPNewBlackbox$(SUFFIX).synth.v: FPNewBlackbox$(SUFFIX).preprocessed.v
	yosys -p 'read_verilog -defer $^' -p 'hierarchy -top FPNewBlackbox' -p 'proc' -p 'opt' -p 'write_verilog -noattr $@'

FPNewBlackbox$(SUFFIX).preprocessed.v: FPNewBlackbox$(SUFFIX).preprocessed.sv
	~/sv2v/bin/sv2v $^ > $@
	sed -i '/\$$fatal/d' $@

FPNewBlackbox$(SUFFIX).preprocessed.sv: Makefile $(VSRCS)
	cat $(VSRCS) > cat.sv
	verilator --cc --exe $(VERILATOR_OPTS) cat.sv --top-module FPNewBlackbox > $@
	sed -i '/^`line/d' $@
	rm cat.sv

clean:
	rm -f FPNewBlackbox*.synth.v FPNewBlackbox*.preprocessed.v FPNewBlackbox*.preprocessed.sv
