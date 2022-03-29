module rr_arb_tree_52163_F264E (
	clk_i,
	rst_ni,
	flush_i,
	rr_i,
	req_i,
	gnt_o,
	data_i,
	req_o,
	gnt_i,
	data_o,
	idx_o
);
	parameter signed [31:0] DataType_TagType_TagType_TAG_WIDTH = 0;
	parameter [31:0] DataType_Width = 0;
	parameter [31:0] NumIn = 64;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] ExtPrio = 1'b0;
	parameter [0:0] AxiVldRdy = 1'b0;
	parameter [0:0] LockIn = 1'b0;
	parameter [0:0] FairArb = 1'b1;
	parameter [31:0] IdxWidth = (NumIn > 32'd1 ? $unsigned($clog2(NumIn)) : 32'd1);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire [IdxWidth - 1:0] rr_i;
	input wire [NumIn - 1:0] req_i;
	output wire [NumIn - 1:0] gnt_o;
	input wire [(NumIn * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)) - 1:0] data_i;
	output wire req_o;
	input wire gnt_i;
	output wire [((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH) - 1:0] data_o;
	output wire [IdxWidth - 1:0] idx_o;
	function automatic [IdxWidth - 1:0] sv2v_cast_1BFE4;
		input reg [IdxWidth - 1:0] inp;
		sv2v_cast_1BFE4 = inp;
	endfunction
	function automatic [((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH) - 1:0] sv2v_cast_87087;
		input reg [((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH) - 1:0] inp;
		sv2v_cast_87087 = inp;
	endfunction
	generate
		if (NumIn == $unsigned(1)) begin : gen_pass_through
			assign req_o = req_i[0];
			assign gnt_o[0] = gnt_i;
			assign data_o = data_i[0+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH];
			assign idx_o = 1'sb0;
		end
		else begin : gen_arbiter
			localparam [31:0] NumLevels = $unsigned($clog2(NumIn));
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * IdxWidth) - 1 : ((3 - (2 ** NumLevels)) * IdxWidth) + ((((2 ** NumLevels) - 2) * IdxWidth) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * IdxWidth)] index_nodes;
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)) - 1 : ((3 - (2 ** NumLevels)) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)) + ((((2 ** NumLevels) - 2) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH))] data_nodes;
			wire [(2 ** NumLevels) - 2:0] gnt_nodes;
			wire [(2 ** NumLevels) - 2:0] req_nodes;
			reg [IdxWidth - 1:0] rr_q;
			wire [NumIn - 1:0] req_d;
			assign req_o = req_nodes[0];
			assign data_o = data_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH];
			assign idx_o = index_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * IdxWidth+:IdxWidth];
			if (ExtPrio) begin : gen_ext_rr
				wire [IdxWidth:1] sv2v_tmp_4C2F0;
				assign sv2v_tmp_4C2F0 = rr_i;
				always @(*) rr_q = sv2v_tmp_4C2F0;
				assign req_d = req_i;
			end
			else begin : gen_int_rr
				wire [IdxWidth - 1:0] rr_d;
				if (LockIn) begin : gen_lock
					wire lock_d;
					reg lock_q;
					reg [NumIn - 1:0] req_q;
					assign lock_d = req_o & ~gnt_i;
					assign req_d = (lock_q ? req_q : req_i);
					always @(posedge clk_i or negedge rst_ni) begin : p_lock_reg
						if (!rst_ni)
							lock_q <= 1'sb0;
						else if (flush_i)
							lock_q <= 1'sb0;
						else
							lock_q <= lock_d;
					end
					always @(posedge clk_i or negedge rst_ni) begin : p_req_regs
						if (!rst_ni)
							req_q <= 1'sb0;
						else if (flush_i)
							req_q <= 1'sb0;
						else
							req_q <= req_d;
					end
				end
				else begin : gen_no_lock
					assign req_d = req_i;
				end
				if (FairArb) begin : gen_fair_arb
					wire [NumIn - 1:0] upper_mask;
					wire [NumIn - 1:0] lower_mask;
					wire [IdxWidth - 1:0] upper_idx;
					wire [IdxWidth - 1:0] lower_idx;
					wire [IdxWidth - 1:0] next_idx;
					wire upper_empty;
					wire lower_empty;
					genvar i;
					for (i = 0; i < NumIn; i = i + 1) begin : gen_mask
						assign upper_mask[i] = (i > rr_q ? req_d[i] : 1'b0);
						assign lower_mask[i] = (i <= rr_q ? req_d[i] : 1'b0);
					end
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_upper(
						.in_i(upper_mask),
						.cnt_o(upper_idx),
						.empty_o(upper_empty)
					);
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_lower(
						.in_i(lower_mask),
						.cnt_o(lower_idx)
					);
					assign next_idx = (upper_empty ? lower_idx : upper_idx);
					assign rr_d = (gnt_i && req_o ? next_idx : rr_q);
				end
				else begin : gen_unfair_arb
					assign rr_d = (gnt_i && req_o ? (rr_q == sv2v_cast_1BFE4(NumIn - 1) ? {IdxWidth {1'sb0}} : rr_q + 1'b1) : rr_q);
				end
				always @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
					if (!rst_ni)
						rr_q <= 1'sb0;
					else if (flush_i)
						rr_q <= 1'sb0;
					else
						rr_q <= rr_d;
				end
			end
			assign gnt_nodes[0] = gnt_i;
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : gen_levels
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : gen_level
					wire sel;
					localparam [31:0] Idx0 = ((2 ** level) - 1) + l;
					localparam [31:0] Idx1 = ((2 ** (level + 1)) - 1) + (l * 2);
					if ($unsigned(level) == (NumLevels - 1)) begin : gen_first_level
						if (($unsigned(l) * 2) < (NumIn - 1)) begin : gen_reduce
							assign req_nodes[Idx0] = req_d[l * 2] | req_d[(l * 2) + 1];
							assign sel = ~req_d[l * 2] | (req_d[(l * 2) + 1] & rr_q[(NumLevels - 1) - level]);
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_1BFE4(sel);
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH] = (sel ? data_i[((l * 2) + 1) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH] : data_i[(l * 2) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH]);
							assign gnt_o[l * 2] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2])) & ~sel;
							assign gnt_o[(l * 2) + 1] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[(l * 2) + 1])) & sel;
						end
						if (($unsigned(l) * 2) == (NumIn - 1)) begin : gen_first
							assign req_nodes[Idx0] = req_d[l * 2];
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = 1'sb0;
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH] = data_i[(l * 2) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH];
							assign gnt_o[l * 2] = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2]);
						end
						if (($unsigned(l) * 2) > (NumIn - 1)) begin : gen_out_of_range
							assign req_nodes[Idx0] = 1'b0;
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_1BFE4(1'sb0);
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH] = sv2v_cast_87087(1'sb0);
						end
					end
					else begin : gen_other_levels
						assign req_nodes[Idx0] = req_nodes[Idx1] | req_nodes[Idx1 + 1];
						assign sel = ~req_nodes[Idx1] | (req_nodes[Idx1 + 1] & rr_q[(NumLevels - 1) - level]);
						assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = (sel ? sv2v_cast_1BFE4({1'b1, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}) : sv2v_cast_1BFE4({1'b0, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}));
						assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH] = (sel ? data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH] : data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * ((DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH)+:(DataType_Width + 6) + DataType_TagType_TagType_TAG_WIDTH]);
						assign gnt_nodes[Idx1] = gnt_nodes[Idx0] & ~sel;
						assign gnt_nodes[Idx1 + 1] = gnt_nodes[Idx0] & sel;
					end
				end
			end
		end
	endgenerate
endmodule
module rr_arb_tree_DE4E6_76EE6 (
	clk_i,
	rst_ni,
	flush_i,
	rr_i,
	req_i,
	gnt_o,
	data_i,
	req_o,
	gnt_i,
	data_o,
	idx_o
);
	parameter signed [31:0] DataType_TagType_TAG_WIDTH = 0;
	parameter [31:0] DataType_WIDTH = 0;
	parameter [31:0] NumIn = 64;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] ExtPrio = 1'b0;
	parameter [0:0] AxiVldRdy = 1'b0;
	parameter [0:0] LockIn = 1'b0;
	parameter [0:0] FairArb = 1'b1;
	parameter [31:0] IdxWidth = (NumIn > 32'd1 ? $unsigned($clog2(NumIn)) : 32'd1);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire [IdxWidth - 1:0] rr_i;
	input wire [NumIn - 1:0] req_i;
	output wire [NumIn - 1:0] gnt_o;
	input wire [(NumIn * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)) - 1:0] data_i;
	output wire req_o;
	input wire gnt_i;
	output wire [((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH) - 1:0] data_o;
	output wire [IdxWidth - 1:0] idx_o;
	function automatic [IdxWidth - 1:0] sv2v_cast_71D7F;
		input reg [IdxWidth - 1:0] inp;
		sv2v_cast_71D7F = inp;
	endfunction
	function automatic [((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH) - 1:0] sv2v_cast_59569;
		input reg [((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH) - 1:0] inp;
		sv2v_cast_59569 = inp;
	endfunction
	generate
		if (NumIn == $unsigned(1)) begin : gen_pass_through
			assign req_o = req_i[0];
			assign gnt_o[0] = gnt_i;
			assign data_o = data_i[0+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH];
			assign idx_o = 1'sb0;
		end
		else begin : gen_arbiter
			localparam [31:0] NumLevels = $unsigned($clog2(NumIn));
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * IdxWidth) - 1 : ((3 - (2 ** NumLevels)) * IdxWidth) + ((((2 ** NumLevels) - 2) * IdxWidth) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * IdxWidth)] index_nodes;
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)) - 1 : ((3 - (2 ** NumLevels)) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)) + ((((2 ** NumLevels) - 2) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH))] data_nodes;
			wire [(2 ** NumLevels) - 2:0] gnt_nodes;
			wire [(2 ** NumLevels) - 2:0] req_nodes;
			reg [IdxWidth - 1:0] rr_q;
			wire [NumIn - 1:0] req_d;
			assign req_o = req_nodes[0];
			assign data_o = data_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH];
			assign idx_o = index_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * IdxWidth+:IdxWidth];
			if (ExtPrio) begin : gen_ext_rr
				wire [IdxWidth:1] sv2v_tmp_4C2F0;
				assign sv2v_tmp_4C2F0 = rr_i;
				always @(*) rr_q = sv2v_tmp_4C2F0;
				assign req_d = req_i;
			end
			else begin : gen_int_rr
				wire [IdxWidth - 1:0] rr_d;
				if (LockIn) begin : gen_lock
					wire lock_d;
					reg lock_q;
					reg [NumIn - 1:0] req_q;
					assign lock_d = req_o & ~gnt_i;
					assign req_d = (lock_q ? req_q : req_i);
					always @(posedge clk_i or negedge rst_ni) begin : p_lock_reg
						if (!rst_ni)
							lock_q <= 1'sb0;
						else if (flush_i)
							lock_q <= 1'sb0;
						else
							lock_q <= lock_d;
					end
					always @(posedge clk_i or negedge rst_ni) begin : p_req_regs
						if (!rst_ni)
							req_q <= 1'sb0;
						else if (flush_i)
							req_q <= 1'sb0;
						else
							req_q <= req_d;
					end
				end
				else begin : gen_no_lock
					assign req_d = req_i;
				end
				if (FairArb) begin : gen_fair_arb
					wire [NumIn - 1:0] upper_mask;
					wire [NumIn - 1:0] lower_mask;
					wire [IdxWidth - 1:0] upper_idx;
					wire [IdxWidth - 1:0] lower_idx;
					wire [IdxWidth - 1:0] next_idx;
					wire upper_empty;
					wire lower_empty;
					genvar i;
					for (i = 0; i < NumIn; i = i + 1) begin : gen_mask
						assign upper_mask[i] = (i > rr_q ? req_d[i] : 1'b0);
						assign lower_mask[i] = (i <= rr_q ? req_d[i] : 1'b0);
					end
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_upper(
						.in_i(upper_mask),
						.cnt_o(upper_idx),
						.empty_o(upper_empty)
					);
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_lower(
						.in_i(lower_mask),
						.cnt_o(lower_idx)
					);
					assign next_idx = (upper_empty ? lower_idx : upper_idx);
					assign rr_d = (gnt_i && req_o ? next_idx : rr_q);
				end
				else begin : gen_unfair_arb
					assign rr_d = (gnt_i && req_o ? (rr_q == sv2v_cast_71D7F(NumIn - 1) ? {IdxWidth {1'sb0}} : rr_q + 1'b1) : rr_q);
				end
				always @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
					if (!rst_ni)
						rr_q <= 1'sb0;
					else if (flush_i)
						rr_q <= 1'sb0;
					else
						rr_q <= rr_d;
				end
			end
			assign gnt_nodes[0] = gnt_i;
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : gen_levels
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : gen_level
					wire sel;
					localparam [31:0] Idx0 = ((2 ** level) - 1) + l;
					localparam [31:0] Idx1 = ((2 ** (level + 1)) - 1) + (l * 2);
					if ($unsigned(level) == (NumLevels - 1)) begin : gen_first_level
						if (($unsigned(l) * 2) < (NumIn - 1)) begin : gen_reduce
							assign req_nodes[Idx0] = req_d[l * 2] | req_d[(l * 2) + 1];
							assign sel = ~req_d[l * 2] | (req_d[(l * 2) + 1] & rr_q[(NumLevels - 1) - level]);
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_71D7F(sel);
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH] = (sel ? data_i[((l * 2) + 1) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH] : data_i[(l * 2) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH]);
							assign gnt_o[l * 2] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2])) & ~sel;
							assign gnt_o[(l * 2) + 1] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[(l * 2) + 1])) & sel;
						end
						if (($unsigned(l) * 2) == (NumIn - 1)) begin : gen_first
							assign req_nodes[Idx0] = req_d[l * 2];
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = 1'sb0;
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH] = data_i[(l * 2) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH];
							assign gnt_o[l * 2] = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2]);
						end
						if (($unsigned(l) * 2) > (NumIn - 1)) begin : gen_out_of_range
							assign req_nodes[Idx0] = 1'b0;
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_71D7F(1'sb0);
							assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH] = sv2v_cast_59569(1'sb0);
						end
					end
					else begin : gen_other_levels
						assign req_nodes[Idx0] = req_nodes[Idx1] | req_nodes[Idx1 + 1];
						assign sel = ~req_nodes[Idx1] | (req_nodes[Idx1 + 1] & rr_q[(NumLevels - 1) - level]);
						assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = (sel ? sv2v_cast_71D7F({1'b1, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}) : sv2v_cast_71D7F({1'b0, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}));
						assign data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH] = (sel ? data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH] : data_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * ((DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH)+:(DataType_WIDTH + 5) + DataType_TagType_TAG_WIDTH]);
						assign gnt_nodes[Idx1] = gnt_nodes[Idx0] & ~sel;
						assign gnt_nodes[Idx1 + 1] = gnt_nodes[Idx0] & sel;
					end
				end
			end
		end
	endgenerate
endmodule
module lzc (
	in_i,
	cnt_o,
	empty_o
);
	parameter [31:0] WIDTH = 2;
	parameter [0:0] MODE = 1'b0;
	function automatic [31:0] cf_math_pkg_idx_width;
		input reg [31:0] num_idx;
		cf_math_pkg_idx_width = (num_idx > 32'd1 ? $unsigned($clog2(num_idx)) : 32'd1);
	endfunction
	parameter [31:0] CNT_WIDTH = cf_math_pkg_idx_width(WIDTH);
	input wire [WIDTH - 1:0] in_i;
	output wire [CNT_WIDTH - 1:0] cnt_o;
	output wire empty_o;
	generate
		if (WIDTH == 1) begin : gen_degenerate_lzc
			assign cnt_o[0] = !in_i[0];
			assign empty_o = !in_i[0];
		end
		else begin : gen_lzc
			localparam [31:0] NumLevels = $clog2(WIDTH);
			wire [(WIDTH * NumLevels) - 1:0] index_lut;
			wire [(2 ** NumLevels) - 1:0] sel_nodes;
			wire [((2 ** NumLevels) * NumLevels) - 1:0] index_nodes;
			reg [WIDTH - 1:0] in_tmp;
			always @(*) begin : flip_vector
				begin : sv2v_autoblock_1
					reg [31:0] i;
					for (i = 0; i < WIDTH; i = i + 1)
						in_tmp[i] = (MODE ? in_i[(WIDTH - 1) - i] : in_i[i]);
				end
			end
			genvar j;
			for (j = 0; $unsigned(j) < WIDTH; j = j + 1) begin : g_index_lut
				function automatic [NumLevels - 1:0] sv2v_cast_5699A;
					input reg [NumLevels - 1:0] inp;
					sv2v_cast_5699A = inp;
				endfunction
				assign index_lut[j * NumLevels+:NumLevels] = sv2v_cast_5699A($unsigned(j));
			end
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : g_levels
				if ($unsigned(level) == (NumLevels - 1)) begin : g_last_level
					genvar k;
					for (k = 0; k < (2 ** level); k = k + 1) begin : g_level
						if (($unsigned(k) * 2) < (WIDTH - 1)) begin : g_reduce
							assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2] | in_tmp[(k * 2) + 1];
							assign index_nodes[(((2 ** level) - 1) + k) * NumLevels+:NumLevels] = (in_tmp[k * 2] == 1'b1 ? index_lut[(k * 2) * NumLevels+:NumLevels] : index_lut[((k * 2) + 1) * NumLevels+:NumLevels]);
						end
						if (($unsigned(k) * 2) == (WIDTH - 1)) begin : g_base
							assign sel_nodes[((2 ** level) - 1) + k] = in_tmp[k * 2];
							assign index_nodes[(((2 ** level) - 1) + k) * NumLevels+:NumLevels] = index_lut[(k * 2) * NumLevels+:NumLevels];
						end
						if (($unsigned(k) * 2) > (WIDTH - 1)) begin : g_out_of_range
							assign sel_nodes[((2 ** level) - 1) + k] = 1'b0;
							assign index_nodes[(((2 ** level) - 1) + k) * NumLevels+:NumLevels] = 1'sb0;
						end
					end
				end
				else begin : g_not_last_level
					genvar l;
					for (l = 0; l < (2 ** level); l = l + 1) begin : g_level
						assign sel_nodes[((2 ** level) - 1) + l] = sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] | sel_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) + 1];
						assign index_nodes[(((2 ** level) - 1) + l) * NumLevels+:NumLevels] = (sel_nodes[((2 ** (level + 1)) - 1) + (l * 2)] == 1'b1 ? index_nodes[(((2 ** (level + 1)) - 1) + (l * 2)) * NumLevels+:NumLevels] : index_nodes[((((2 ** (level + 1)) - 1) + (l * 2)) + 1) * NumLevels+:NumLevels]);
					end
				end
			end
			assign cnt_o = (NumLevels > $unsigned(0) ? index_nodes[0+:NumLevels] : {$clog2(WIDTH) {1'b0}});
			assign empty_o = (NumLevels > $unsigned(0) ? ~sel_nodes[0] : ~(|in_i));
		end
	endgenerate
endmodule
module control_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Start_SI,
	Kill_SI,
	Special_case_SBI,
	Special_case_dly_SBI,
	Precision_ctl_SI,
	Format_sel_SI,
	Numerator_DI,
	Exp_num_DI,
	Denominator_DI,
	Exp_den_DI,
	Div_start_dly_SO,
	Sqrt_start_dly_SO,
	Div_enable_SO,
	Sqrt_enable_SO,
	Full_precision_SO,
	FP32_SO,
	FP64_SO,
	FP16_SO,
	FP16ALT_SO,
	Ready_SO,
	Done_SO,
	Mant_result_prenorm_DO,
	Exp_result_prenorm_DO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Start_SI;
	input wire Kill_SI;
	input wire Special_case_SBI;
	input wire Special_case_dly_SBI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	input wire [1:0] Format_sel_SI;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Numerator_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_num_DI;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Denominator_DI;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_den_DI;
	output wire Div_start_dly_SO;
	output wire Sqrt_start_dly_SO;
	output reg Div_enable_SO;
	output reg Sqrt_enable_SO;
	output wire Full_precision_SO;
	output wire FP32_SO;
	output wire FP64_SO;
	output wire FP16_SO;
	output wire FP16ALT_SO;
	output reg Ready_SO;
	output reg Done_SO;
	output reg [56:0] Mant_result_prenorm_DO;
	output wire [12:0] Exp_result_prenorm_DO;
	reg [57:0] Partial_remainder_DN;
	reg [57:0] Partial_remainder_DP;
	reg [56:0] Quotient_DP;
	wire [53:0] Numerator_se_D;
	wire [53:0] Denominator_se_D;
	reg [53:0] Denominator_se_DB;
	assign Numerator_se_D = {1'b0, Numerator_DI};
	assign Denominator_se_D = {1'b0, Denominator_DI};
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	always @(*)
		if (FP32_SO)
			Denominator_se_DB = {~Denominator_se_D[53:29], {29 {1'b0}}};
		else if (FP64_SO)
			Denominator_se_DB = ~Denominator_se_D;
		else if (FP16_SO)
			Denominator_se_DB = {~Denominator_se_D[53:42], {42 {1'b0}}};
		else
			Denominator_se_DB = {~Denominator_se_D[53:45], {45 {1'b0}}};
	wire [53:0] Mant_D_sqrt_Norm;
	assign Mant_D_sqrt_Norm = (Exp_num_DI[0] ? {1'b0, Numerator_DI} : {Numerator_DI, 1'b0});
	reg [1:0] Format_sel_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Format_sel_S <= 'b0;
		else if (Start_SI && Ready_SO)
			Format_sel_S <= Format_sel_SI;
		else
			Format_sel_S <= Format_sel_S;
	assign FP32_SO = Format_sel_S == 2'b00;
	assign FP64_SO = Format_sel_S == 2'b01;
	assign FP16_SO = Format_sel_S == 2'b10;
	assign FP16ALT_SO = Format_sel_S == 2'b11;
	reg [5:0] Precision_ctl_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Precision_ctl_S <= 'b0;
		else if (Start_SI && Ready_SO)
			Precision_ctl_S <= Precision_ctl_SI;
		else
			Precision_ctl_S <= Precision_ctl_S;
	assign Full_precision_SO = Precision_ctl_S == 6'h00;
	reg [5:0] State_ctl_S;
	wire [5:0] State_Two_iteration_unit_S;
	wire [5:0] State_Four_iteration_unit_S;
	assign State_Two_iteration_unit_S = Precision_ctl_S[5:1];
	assign State_Four_iteration_unit_S = Precision_ctl_S[5:2];
	localparam defs_div_sqrt_mvp_Iteration_unit_num_S = 2'b10;
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h1b;
						else
							State_ctl_S = Precision_ctl_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h38;
						else
							State_ctl_S = Precision_ctl_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h0e;
						else
							State_ctl_S = Precision_ctl_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h0b;
						else
							State_ctl_S = Precision_ctl_S;
				endcase
			2'b01:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h0d;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h1b;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h06;
						else
							State_ctl_S = State_Two_iteration_unit_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h05;
						else
							State_ctl_S = State_Two_iteration_unit_S;
				endcase
			2'b10:
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h08;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							6'h0c, 6'h0d, 6'h0e: State_ctl_S = 6'h04;
							6'h0f, 6'h10, 6'h11: State_ctl_S = 6'h05;
							6'h12, 6'h13, 6'h14: State_ctl_S = 6'h06;
							6'h15, 6'h16, 6'h17: State_ctl_S = 6'h07;
							default: State_ctl_S = 6'h08;
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h12;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							6'h0c, 6'h0d, 6'h0e: State_ctl_S = 6'h04;
							6'h0f, 6'h10, 6'h11: State_ctl_S = 6'h05;
							6'h12, 6'h13, 6'h14: State_ctl_S = 6'h06;
							6'h15, 6'h16, 6'h17: State_ctl_S = 6'h07;
							6'h18, 6'h19, 6'h1a: State_ctl_S = 6'h08;
							6'h1b, 6'h1c, 6'h1d: State_ctl_S = 6'h09;
							6'h1e, 6'h1f, 6'h20: State_ctl_S = 6'h0a;
							6'h21, 6'h22, 6'h23: State_ctl_S = 6'h0b;
							6'h24, 6'h25, 6'h26: State_ctl_S = 6'h0c;
							6'h27, 6'h28, 6'h29: State_ctl_S = 6'h0d;
							6'h2a, 6'h2b, 6'h2c: State_ctl_S = 6'h0e;
							6'h2d, 6'h2e, 6'h2f: State_ctl_S = 6'h0f;
							6'h30, 6'h31, 6'h32: State_ctl_S = 6'h10;
							6'h33, 6'h34, 6'h35: State_ctl_S = 6'h11;
							default: State_ctl_S = 6'h12;
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h04;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							6'h09, 6'h0a, 6'h0b: State_ctl_S = 6'h03;
							default: State_ctl_S = 6'h04;
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'h00: State_ctl_S = 6'h03;
							6'h06, 6'h07, 6'h08: State_ctl_S = 6'h02;
							default: State_ctl_S = 6'h03;
						endcase
				endcase
			2'b11:
				case (Format_sel_S)
					2'b00:
						if (Full_precision_SO)
							State_ctl_S = 6'h06;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b01:
						if (Full_precision_SO)
							State_ctl_S = 6'h0d;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b10:
						if (Full_precision_SO)
							State_ctl_S = 6'h03;
						else
							State_ctl_S = State_Four_iteration_unit_S;
					2'b11:
						if (Full_precision_SO)
							State_ctl_S = 6'h02;
						else
							State_ctl_S = State_Four_iteration_unit_S;
				endcase
		endcase
	reg Div_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Div_start_dly_S <= 1'b0;
		else if (Div_start_SI && Ready_SO)
			Div_start_dly_S <= 1'b1;
		else
			Div_start_dly_S <= 1'b0;
	assign Div_start_dly_SO = Div_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Div_enable_SO <= 1'b0;
		else if (Kill_SI)
			Div_enable_SO <= 1'b0;
		else if (Div_start_SI && Ready_SO)
			Div_enable_SO <= 1'b1;
		else if (Done_SO)
			Div_enable_SO <= 1'b0;
		else
			Div_enable_SO <= Div_enable_SO;
	reg Sqrt_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sqrt_start_dly_S <= 1'b0;
		else if (Sqrt_start_SI && Ready_SO)
			Sqrt_start_dly_S <= 1'b1;
		else
			Sqrt_start_dly_S <= 1'b0;
	assign Sqrt_start_dly_SO = Sqrt_start_dly_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sqrt_enable_SO <= 1'b0;
		else if (Kill_SI)
			Sqrt_enable_SO <= 1'b0;
		else if (Sqrt_start_SI && Ready_SO)
			Sqrt_enable_SO <= 1'b1;
		else if (Done_SO)
			Sqrt_enable_SO <= 1'b0;
		else
			Sqrt_enable_SO <= Sqrt_enable_SO;
	reg [5:0] Crtl_cnt_S;
	wire Start_dly_S;
	assign Start_dly_S = Div_start_dly_S | Sqrt_start_dly_S;
	wire Fsm_enable_S;
	assign Fsm_enable_S = ((Start_dly_S | |Crtl_cnt_S) && ~Kill_SI) && Special_case_dly_SBI;
	wire Final_state_S;
	assign Final_state_S = Crtl_cnt_S == State_ctl_S;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Crtl_cnt_S <= 1'sb0;
		else if (Final_state_S | Kill_SI)
			Crtl_cnt_S <= 1'sb0;
		else if (Fsm_enable_S)
			Crtl_cnt_S <= Crtl_cnt_S + 1;
		else
			Crtl_cnt_S <= 1'sb0;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Done_SO <= 1'b0;
		else if (Start_SI && Ready_SO) begin
			if (~Special_case_SBI)
				Done_SO <= 1'b1;
			else
				Done_SO <= 1'b0;
		end
		else if (Final_state_S)
			Done_SO <= 1'b1;
		else
			Done_SO <= 1'b0;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Ready_SO <= 1'b1;
		else if (Start_SI && Ready_SO) begin
			if (~Special_case_SBI)
				Ready_SO <= 1'b1;
			else
				Ready_SO <= 1'b0;
		end
		else if (Final_state_S | Kill_SI)
			Ready_SO <= 1'b1;
		else
			Ready_SO <= Ready_SO;
	wire Qcnt_one_0;
	wire Qcnt_one_1;
	wire [1:0] Qcnt_one_2;
	wire [2:0] Qcnt_one_3;
	wire [3:0] Qcnt_one_4;
	wire [4:0] Qcnt_one_5;
	wire [5:0] Qcnt_one_6;
	wire [6:0] Qcnt_one_7;
	wire [7:0] Qcnt_one_8;
	wire [8:0] Qcnt_one_9;
	wire [9:0] Qcnt_one_10;
	wire [10:0] Qcnt_one_11;
	wire [11:0] Qcnt_one_12;
	wire [12:0] Qcnt_one_13;
	wire [13:0] Qcnt_one_14;
	wire [14:0] Qcnt_one_15;
	wire [15:0] Qcnt_one_16;
	wire [16:0] Qcnt_one_17;
	wire [17:0] Qcnt_one_18;
	wire [18:0] Qcnt_one_19;
	wire [19:0] Qcnt_one_20;
	wire [20:0] Qcnt_one_21;
	wire [21:0] Qcnt_one_22;
	wire [22:0] Qcnt_one_23;
	wire [23:0] Qcnt_one_24;
	wire [24:0] Qcnt_one_25;
	wire [25:0] Qcnt_one_26;
	wire [26:0] Qcnt_one_27;
	wire [27:0] Qcnt_one_28;
	wire [28:0] Qcnt_one_29;
	wire [29:0] Qcnt_one_30;
	wire [30:0] Qcnt_one_31;
	wire [31:0] Qcnt_one_32;
	wire [32:0] Qcnt_one_33;
	wire [33:0] Qcnt_one_34;
	wire [34:0] Qcnt_one_35;
	wire [35:0] Qcnt_one_36;
	wire [36:0] Qcnt_one_37;
	wire [37:0] Qcnt_one_38;
	wire [38:0] Qcnt_one_39;
	wire [39:0] Qcnt_one_40;
	wire [40:0] Qcnt_one_41;
	wire [41:0] Qcnt_one_42;
	wire [42:0] Qcnt_one_43;
	wire [43:0] Qcnt_one_44;
	wire [44:0] Qcnt_one_45;
	wire [45:0] Qcnt_one_46;
	wire [46:0] Qcnt_one_47;
	wire [47:0] Qcnt_one_48;
	wire [48:0] Qcnt_one_49;
	wire [49:0] Qcnt_one_50;
	wire [50:0] Qcnt_one_51;
	wire [51:0] Qcnt_one_52;
	wire [52:0] Qcnt_one_53;
	wire [53:0] Qcnt_one_54;
	wire [54:0] Qcnt_one_55;
	wire [55:0] Qcnt_one_56;
	wire [56:0] Qcnt_one_57;
	wire [57:0] Qcnt_one_58;
	wire [58:0] Qcnt_one_59;
	wire [59:0] Qcnt_one_60;
	wire [1:0] Qcnt_two_0;
	wire [2:0] Qcnt_two_1;
	wire [4:0] Qcnt_two_2;
	wire [6:0] Qcnt_two_3;
	wire [8:0] Qcnt_two_4;
	wire [10:0] Qcnt_two_5;
	wire [12:0] Qcnt_two_6;
	wire [14:0] Qcnt_two_7;
	wire [16:0] Qcnt_two_8;
	wire [18:0] Qcnt_two_9;
	wire [20:0] Qcnt_two_10;
	wire [22:0] Qcnt_two_11;
	wire [24:0] Qcnt_two_12;
	wire [26:0] Qcnt_two_13;
	wire [28:0] Qcnt_two_14;
	wire [30:0] Qcnt_two_15;
	wire [32:0] Qcnt_two_16;
	wire [34:0] Qcnt_two_17;
	wire [36:0] Qcnt_two_18;
	wire [38:0] Qcnt_two_19;
	wire [40:0] Qcnt_two_20;
	wire [42:0] Qcnt_two_21;
	wire [44:0] Qcnt_two_22;
	wire [46:0] Qcnt_two_23;
	wire [48:0] Qcnt_two_24;
	wire [50:0] Qcnt_two_25;
	wire [52:0] Qcnt_two_26;
	wire [54:0] Qcnt_two_27;
	wire [56:0] Qcnt_two_28;
	wire [2:0] Qcnt_three_0;
	wire [4:0] Qcnt_three_1;
	wire [7:0] Qcnt_three_2;
	wire [10:0] Qcnt_three_3;
	wire [13:0] Qcnt_three_4;
	wire [16:0] Qcnt_three_5;
	wire [19:0] Qcnt_three_6;
	wire [22:0] Qcnt_three_7;
	wire [25:0] Qcnt_three_8;
	wire [28:0] Qcnt_three_9;
	wire [31:0] Qcnt_three_10;
	wire [34:0] Qcnt_three_11;
	wire [37:0] Qcnt_three_12;
	wire [40:0] Qcnt_three_13;
	wire [43:0] Qcnt_three_14;
	wire [46:0] Qcnt_three_15;
	wire [49:0] Qcnt_three_16;
	wire [52:0] Qcnt_three_17;
	wire [55:0] Qcnt_three_18;
	wire [58:0] Qcnt_three_19;
	wire [61:0] Qcnt_three_20;
	wire [3:0] Qcnt_four_0;
	wire [6:0] Qcnt_four_1;
	wire [10:0] Qcnt_four_2;
	wire [14:0] Qcnt_four_3;
	wire [18:0] Qcnt_four_4;
	wire [22:0] Qcnt_four_5;
	wire [26:0] Qcnt_four_6;
	wire [30:0] Qcnt_four_7;
	wire [34:0] Qcnt_four_8;
	wire [38:0] Qcnt_four_9;
	wire [42:0] Qcnt_four_10;
	wire [46:0] Qcnt_four_11;
	wire [50:0] Qcnt_four_12;
	wire [54:0] Qcnt_four_13;
	wire [58:0] Qcnt_four_14;
	wire [57:0] Sqrt_R0;
	reg [57:0] Sqrt_Q0;
	reg [57:0] Q_sqrt0;
	reg [57:0] Q_sqrt_com_0;
	wire [57:0] Sqrt_R1;
	reg [57:0] Sqrt_Q1;
	reg [57:0] Q_sqrt1;
	reg [57:0] Q_sqrt_com_1;
	wire [57:0] Sqrt_R2;
	reg [57:0] Sqrt_Q2;
	reg [57:0] Q_sqrt2;
	reg [57:0] Q_sqrt_com_2;
	wire [57:0] Sqrt_R3;
	reg [57:0] Sqrt_Q3;
	reg [57:0] Q_sqrt3;
	reg [57:0] Q_sqrt_com_3;
	wire [57:0] Sqrt_R4;
	reg [1:0] Sqrt_DI [3:0];
	wire [1:0] Sqrt_DO [3:0];
	wire Sqrt_carry_DO;
	wire [57:0] Iteration_cell_a_D [3:0];
	wire [57:0] Iteration_cell_b_D [3:0];
	wire [57:0] Iteration_cell_a_BMASK_D [3:0];
	wire [57:0] Iteration_cell_b_BMASK_D [3:0];
	wire Iteration_cell_carry_D [3:0];
	wire [57:0] Iteration_cell_sum_D [3:0];
	wire [57:0] Iteration_cell_sum_AMASK_D [3:0];
	reg [3:0] Sqrt_quotinent_S;
	always @(*)
		case (Format_sel_S)
			2'b00: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][28], ~Iteration_cell_sum_AMASK_D[1][28], ~Iteration_cell_sum_AMASK_D[2][28], ~Iteration_cell_sum_AMASK_D[3][28]};
				Q_sqrt_com_0 = {{29 {1'b0}}, ~Q_sqrt0[28:0]};
				Q_sqrt_com_1 = {{29 {1'b0}}, ~Q_sqrt1[28:0]};
				Q_sqrt_com_2 = {{29 {1'b0}}, ~Q_sqrt2[28:0]};
				Q_sqrt_com_3 = {{29 {1'b0}}, ~Q_sqrt3[28:0]};
			end
			2'b01: begin
				Sqrt_quotinent_S = {Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2], Iteration_cell_carry_D[3]};
				Q_sqrt_com_0 = ~Q_sqrt0;
				Q_sqrt_com_1 = ~Q_sqrt1;
				Q_sqrt_com_2 = ~Q_sqrt2;
				Q_sqrt_com_3 = ~Q_sqrt3;
			end
			2'b10: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][15], ~Iteration_cell_sum_AMASK_D[1][15], ~Iteration_cell_sum_AMASK_D[2][15], ~Iteration_cell_sum_AMASK_D[3][15]};
				Q_sqrt_com_0 = {{42 {1'b0}}, ~Q_sqrt0[15:0]};
				Q_sqrt_com_1 = {{42 {1'b0}}, ~Q_sqrt1[15:0]};
				Q_sqrt_com_2 = {{42 {1'b0}}, ~Q_sqrt2[15:0]};
				Q_sqrt_com_3 = {{42 {1'b0}}, ~Q_sqrt3[15:0]};
			end
			2'b11: begin
				Sqrt_quotinent_S = {~Iteration_cell_sum_AMASK_D[0][12], ~Iteration_cell_sum_AMASK_D[1][12], ~Iteration_cell_sum_AMASK_D[2][12], ~Iteration_cell_sum_AMASK_D[3][12]};
				Q_sqrt_com_0 = {{45 {1'b0}}, ~Q_sqrt0[12:0]};
				Q_sqrt_com_1 = {{45 {1'b0}}, ~Q_sqrt1[12:0]};
				Q_sqrt_com_2 = {{45 {1'b0}}, ~Q_sqrt2[12:0]};
				Q_sqrt_com_3 = {{45 {1'b0}}, ~Q_sqrt3[12:0]};
			end
		endcase
	assign Qcnt_one_0 = 1'b0;
	assign Qcnt_one_1 = {Quotient_DP[0]};
	assign Qcnt_one_2 = {Quotient_DP[1:0]};
	assign Qcnt_one_3 = {Quotient_DP[2:0]};
	assign Qcnt_one_4 = {Quotient_DP[3:0]};
	assign Qcnt_one_5 = {Quotient_DP[4:0]};
	assign Qcnt_one_6 = {Quotient_DP[5:0]};
	assign Qcnt_one_7 = {Quotient_DP[6:0]};
	assign Qcnt_one_8 = {Quotient_DP[7:0]};
	assign Qcnt_one_9 = {Quotient_DP[8:0]};
	assign Qcnt_one_10 = {Quotient_DP[9:0]};
	assign Qcnt_one_11 = {Quotient_DP[10:0]};
	assign Qcnt_one_12 = {Quotient_DP[11:0]};
	assign Qcnt_one_13 = {Quotient_DP[12:0]};
	assign Qcnt_one_14 = {Quotient_DP[13:0]};
	assign Qcnt_one_15 = {Quotient_DP[14:0]};
	assign Qcnt_one_16 = {Quotient_DP[15:0]};
	assign Qcnt_one_17 = {Quotient_DP[16:0]};
	assign Qcnt_one_18 = {Quotient_DP[17:0]};
	assign Qcnt_one_19 = {Quotient_DP[18:0]};
	assign Qcnt_one_20 = {Quotient_DP[19:0]};
	assign Qcnt_one_21 = {Quotient_DP[20:0]};
	assign Qcnt_one_22 = {Quotient_DP[21:0]};
	assign Qcnt_one_23 = {Quotient_DP[22:0]};
	assign Qcnt_one_24 = {Quotient_DP[23:0]};
	assign Qcnt_one_25 = {Quotient_DP[24:0]};
	assign Qcnt_one_26 = {Quotient_DP[25:0]};
	assign Qcnt_one_27 = {Quotient_DP[26:0]};
	assign Qcnt_one_28 = {Quotient_DP[27:0]};
	assign Qcnt_one_29 = {Quotient_DP[28:0]};
	assign Qcnt_one_30 = {Quotient_DP[29:0]};
	assign Qcnt_one_31 = {Quotient_DP[30:0]};
	assign Qcnt_one_32 = {Quotient_DP[31:0]};
	assign Qcnt_one_33 = {Quotient_DP[32:0]};
	assign Qcnt_one_34 = {Quotient_DP[33:0]};
	assign Qcnt_one_35 = {Quotient_DP[34:0]};
	assign Qcnt_one_36 = {Quotient_DP[35:0]};
	assign Qcnt_one_37 = {Quotient_DP[36:0]};
	assign Qcnt_one_38 = {Quotient_DP[37:0]};
	assign Qcnt_one_39 = {Quotient_DP[38:0]};
	assign Qcnt_one_40 = {Quotient_DP[39:0]};
	assign Qcnt_one_41 = {Quotient_DP[40:0]};
	assign Qcnt_one_42 = {Quotient_DP[41:0]};
	assign Qcnt_one_43 = {Quotient_DP[42:0]};
	assign Qcnt_one_44 = {Quotient_DP[43:0]};
	assign Qcnt_one_45 = {Quotient_DP[44:0]};
	assign Qcnt_one_46 = {Quotient_DP[45:0]};
	assign Qcnt_one_47 = {Quotient_DP[46:0]};
	assign Qcnt_one_48 = {Quotient_DP[47:0]};
	assign Qcnt_one_49 = {Quotient_DP[48:0]};
	assign Qcnt_one_50 = {Quotient_DP[49:0]};
	assign Qcnt_one_51 = {Quotient_DP[50:0]};
	assign Qcnt_one_52 = {Quotient_DP[51:0]};
	assign Qcnt_one_53 = {Quotient_DP[52:0]};
	assign Qcnt_one_54 = {Quotient_DP[53:0]};
	assign Qcnt_one_55 = {Quotient_DP[54:0]};
	assign Qcnt_one_56 = {Quotient_DP[55:0]};
	assign Qcnt_one_57 = {Quotient_DP[56:0]};
	assign Qcnt_two_0 = {1'b0, Sqrt_quotinent_S[3]};
	assign Qcnt_two_1 = {Quotient_DP[1:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_2 = {Quotient_DP[3:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_3 = {Quotient_DP[5:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_4 = {Quotient_DP[7:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_5 = {Quotient_DP[9:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_6 = {Quotient_DP[11:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_7 = {Quotient_DP[13:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_8 = {Quotient_DP[15:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_9 = {Quotient_DP[17:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_10 = {Quotient_DP[19:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_11 = {Quotient_DP[21:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_12 = {Quotient_DP[23:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_13 = {Quotient_DP[25:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_14 = {Quotient_DP[27:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_15 = {Quotient_DP[29:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_16 = {Quotient_DP[31:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_17 = {Quotient_DP[33:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_18 = {Quotient_DP[35:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_19 = {Quotient_DP[37:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_20 = {Quotient_DP[39:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_21 = {Quotient_DP[41:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_22 = {Quotient_DP[43:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_23 = {Quotient_DP[45:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_24 = {Quotient_DP[47:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_25 = {Quotient_DP[49:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_26 = {Quotient_DP[51:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_27 = {Quotient_DP[53:0], Sqrt_quotinent_S[3]};
	assign Qcnt_two_28 = {Quotient_DP[55:0], Sqrt_quotinent_S[3]};
	assign Qcnt_three_0 = {1'b0, Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_1 = {Quotient_DP[2:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_2 = {Quotient_DP[5:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_3 = {Quotient_DP[8:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_4 = {Quotient_DP[11:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_5 = {Quotient_DP[14:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_6 = {Quotient_DP[17:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_7 = {Quotient_DP[20:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_8 = {Quotient_DP[23:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_9 = {Quotient_DP[26:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_10 = {Quotient_DP[29:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_11 = {Quotient_DP[32:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_12 = {Quotient_DP[35:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_13 = {Quotient_DP[38:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_14 = {Quotient_DP[41:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_15 = {Quotient_DP[44:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_16 = {Quotient_DP[47:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_17 = {Quotient_DP[50:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_18 = {Quotient_DP[53:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_three_19 = {Quotient_DP[56:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2]};
	assign Qcnt_four_0 = {1'b0, Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_1 = {Quotient_DP[3:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_2 = {Quotient_DP[7:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_3 = {Quotient_DP[11:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_4 = {Quotient_DP[15:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_5 = {Quotient_DP[19:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_6 = {Quotient_DP[23:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_7 = {Quotient_DP[27:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_8 = {Quotient_DP[31:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_9 = {Quotient_DP[35:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_10 = {Quotient_DP[39:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_11 = {Quotient_DP[43:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_12 = {Quotient_DP[47:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_13 = {Quotient_DP[51:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	assign Qcnt_four_14 = {Quotient_DP[55:0], Sqrt_quotinent_S[3], Sqrt_quotinent_S[2], Sqrt_quotinent_S[1]};
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_one_0};
						Sqrt_Q0 = Q_sqrt_com_0;
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_one_1};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt0 = {{56 {1'b0}}, Qcnt_one_2};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt0 = {{55 {1'b0}}, Qcnt_one_3};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_one_4};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt0 = {{53 {1'b0}}, Qcnt_one_5};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_one_6};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt0 = {{51 {1'b0}}, Qcnt_one_7};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{50 {1'b0}}, Qcnt_one_8};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt0 = {{49 {1'b0}}, Qcnt_one_9};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_one_10};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt0 = {{47 {1'b0}}, Qcnt_one_11};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{46 {1'b0}}, Qcnt_one_12};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_one_13};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt0 = {{44 {1'b0}}, Qcnt_one_14};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b001111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt0 = {{43 {1'b0}}, Qcnt_one_15};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_one_16};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt0 = {{41 {1'b0}}, Qcnt_one_17};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{40 {1'b0}}, Qcnt_one_18};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt0 = {{39 {1'b0}}, Qcnt_one_19};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{38 {1'b0}}, Qcnt_one_20};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt0 = {{37 {1'b0}}, Qcnt_one_21};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_one_22};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b010111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt0 = {{35 {1'b0}}, Qcnt_one_23};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{34 {1'b0}}, Qcnt_one_24};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_one_25};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt0 = {{32 {1'b0}}, Qcnt_one_26};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{31 {1'b0}}, Qcnt_one_27};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_one_28};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{29 {1'b0}}, Qcnt_one_29};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{28 {1'b0}}, Qcnt_one_30};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b011111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{27 {1'b0}}, Qcnt_one_31};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{26 {1'b0}}, Qcnt_one_32};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{25 {1'b0}}, Qcnt_one_33};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_one_34};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{23 {1'b0}}, Qcnt_one_35};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{22 {1'b0}}, Qcnt_one_36};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_one_37};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{20 {1'b0}}, Qcnt_one_38};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b100111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{19 {1'b0}}, Qcnt_one_39};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_one_40};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{17 {1'b0}}, Qcnt_one_41};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{16 {1'b0}}, Qcnt_one_42};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{15 {1'b0}}, Qcnt_one_43};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{14 {1'b0}}, Qcnt_one_44};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{13 {1'b0}}, Qcnt_one_45};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_one_46};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b101111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{11 {1'b0}}, Qcnt_one_47};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{10 {1'b0}}, Qcnt_one_48};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_one_49};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{8 {1'b0}}, Qcnt_one_50};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{7 {1'b0}}, Qcnt_one_51};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_one_52};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{5 {1'b0}}, Qcnt_one_53};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{4 {1'b0}}, Qcnt_one_54};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b110111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{3 {1'b0}}, Qcnt_one_55};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					6'b111000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{2 {1'b0}}, Qcnt_one_56};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
					end
					default: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = 1'sb0;
						Sqrt_Q0 = 1'sb0;
					end
				endcase
			2'b01:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_two_0[1]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_two_0[1:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt0 = {{56 {1'b0}}, Qcnt_two_1[2:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt1 = {{55 {1'b0}}, Qcnt_two_1[2:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_two_2[4:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt1 = {{53 {1'b0}}, Qcnt_two_2[4:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_two_3[6:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt1 = {{51 {1'b0}}, Qcnt_two_3[6:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{50 {1'b0}}, Qcnt_two_4[8:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt1 = {{49 {1'b0}}, Qcnt_two_4[8:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_two_5[10:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt1 = {{47 {1'b0}}, Qcnt_two_5[10:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{46 {1'b0}}, Qcnt_two_6[12:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{45 {1'b0}}, Qcnt_two_6[12:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt0 = {{44 {1'b0}}, Qcnt_two_7[14:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt1 = {{43 {1'b0}}, Qcnt_two_7[14:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_two_8[16:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt1 = {{41 {1'b0}}, Qcnt_two_8[16:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{40 {1'b0}}, Qcnt_two_9[18:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt1 = {{39 {1'b0}}, Qcnt_two_9[18:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{38 {1'b0}}, Qcnt_two_10[20:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt1 = {{37 {1'b0}}, Qcnt_two_10[20:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_two_11[22:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt1 = {{35 {1'b0}}, Qcnt_two_11[22:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{34 {1'b0}}, Qcnt_two_12[24:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{33 {1'b0}}, Qcnt_two_12[24:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt0 = {{32 {1'b0}}, Qcnt_two_13[26:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{31 {1'b0}}, Qcnt_two_13[26:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_two_14[28:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{29 {1'b0}}, Qcnt_two_14[28:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b001111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{28 {1'b0}}, Qcnt_two_15[30:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{27 {1'b0}}, Qcnt_two_15[30:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{26 {1'b0}}, Qcnt_two_16[32:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{25 {1'b0}}, Qcnt_two_16[32:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_two_17[34:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{23 {1'b0}}, Qcnt_two_17[34:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{22 {1'b0}}, Qcnt_two_18[36:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{21 {1'b0}}, Qcnt_two_18[36:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{20 {1'b0}}, Qcnt_two_19[38:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{19 {1'b0}}, Qcnt_two_19[38:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_two_20[40:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{17 {1'b0}}, Qcnt_two_20[40:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{16 {1'b0}}, Qcnt_two_21[42:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{15 {1'b0}}, Qcnt_two_21[42:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{14 {1'b0}}, Qcnt_two_22[44:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{13 {1'b0}}, Qcnt_two_22[44:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b010111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_two_23[46:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{11 {1'b0}}, Qcnt_two_23[46:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{10 {1'b0}}, Qcnt_two_24[48:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{9 {1'b0}}, Qcnt_two_24[48:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{8 {1'b0}}, Qcnt_two_25[50:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{7 {1'b0}}, Qcnt_two_25[50:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_two_26[52:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{5 {1'b0}}, Qcnt_two_26[52:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{4 {1'b0}}, Qcnt_two_27[54:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{3 {1'b0}}, Qcnt_two_27[54:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					6'b011100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{2 {1'b0}}, Qcnt_two_28[56:1]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {1'b0, Qcnt_two_28[56:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_two_0[1]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_two_0[1:0]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
					end
				endcase
			2'b10:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_three_0[2]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_three_0[2:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_three_0[2:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt0 = {{54 {1'b0}}, Qcnt_three_1[4:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt1 = {{53 {1'b0}}, Qcnt_three_1[4:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt2 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_three_1[4:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt0 = {{51 {1'b0}}, Qcnt_three_2[7:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt1 = {{50 {1'b0}}, Qcnt_three_2[7:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt2 = {{49 {1'b0}}, Qcnt_three_2[7:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt0 = {{48 {1'b0}}, Qcnt_three_3[10:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt1 = {{47 {1'b0}}, Qcnt_three_3[10:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt2 = {{46 {1'b0}}, Qcnt_three_3[10:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_three_4[13:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{44 {1'b0}}, Qcnt_three_4[13:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt2 = {{43 {1'b0}}, Qcnt_three_4[13:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt0 = {{42 {1'b0}}, Qcnt_three_5[16:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt1 = {{41 {1'b0}}, Qcnt_three_5[16:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt2 = {{40 {1'b0}}, Qcnt_three_5[16:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt0 = {{39 {1'b0}}, Qcnt_three_6[19:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt1 = {{38 {1'b0}}, Qcnt_three_6[19:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt2 = {{37 {1'b0}}, Qcnt_three_6[19:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b000111: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt0 = {{36 {1'b0}}, Qcnt_three_7[22:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt1 = {{35 {1'b0}}, Qcnt_three_7[22:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt2 = {{34 {1'b0}}, Qcnt_three_7[22:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_three_8[25:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{32 {1'b0}}, Qcnt_three_8[25:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt2 = {{31 {1'b0}}, Qcnt_three_8[25:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{30 {1'b0}}, Qcnt_three_9[28:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{29 {1'b0}}, Qcnt_three_9[28:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{28 {1'b0}}, Qcnt_three_9[28:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{27 {1'b0}}, Qcnt_three_10[31:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{26 {1'b0}}, Qcnt_three_10[31:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{25 {1'b0}}, Qcnt_three_10[31:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{24 {1'b0}}, Qcnt_three_11[34:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{23 {1'b0}}, Qcnt_three_11[34:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{22 {1'b0}}, Qcnt_three_11[34:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_three_12[37:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{20 {1'b0}}, Qcnt_three_12[37:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{19 {1'b0}}, Qcnt_three_12[37:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{18 {1'b0}}, Qcnt_three_13[40:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{17 {1'b0}}, Qcnt_three_13[40:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{16 {1'b0}}, Qcnt_three_13[40:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001110: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{15 {1'b0}}, Qcnt_three_14[43:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{14 {1'b0}}, Qcnt_three_14[43:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{13 {1'b0}}, Qcnt_three_14[43:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b001111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{12 {1'b0}}, Qcnt_three_15[46:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{11 {1'b0}}, Qcnt_three_15[46:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{10 {1'b0}}, Qcnt_three_15[46:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_three_16[49:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{8 {1'b0}}, Qcnt_three_16[49:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{7 {1'b0}}, Qcnt_three_16[49:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{6 {1'b0}}, Qcnt_three_17[52:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{5 {1'b0}}, Qcnt_three_17[52:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{4 {1'b0}}, Qcnt_three_17[52:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					6'b010010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{3 {1'b0}}, Qcnt_three_18[55:2]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{2 {1'b0}}, Qcnt_three_18[55:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {1'b0, Qcnt_three_18[55:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_three_0[2]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_three_0[2:1]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_three_0[2:0]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
					end
				endcase
			2'b11:
				case (Crtl_cnt_S)
					6'b000000: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_four_0[3]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_four_0[3:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_four_0[3:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt3 = {{54 {1'b0}}, Qcnt_four_0[3:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000001: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[45:44];
						Q_sqrt0 = {{53 {1'b0}}, Qcnt_four_1[6:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[43:42];
						Q_sqrt1 = {{defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}, Qcnt_four_1[6:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[41:40];
						Q_sqrt2 = {{51 {1'b0}}, Qcnt_four_1[6:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[39:38];
						Q_sqrt3 = {{50 {1'b0}}, Qcnt_four_1[6:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000010: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[37:36];
						Q_sqrt0 = {{49 {1'b0}}, Qcnt_four_2[10:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[35:34];
						Q_sqrt1 = {{48 {1'b0}}, Qcnt_four_2[10:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[33:32];
						Q_sqrt2 = {{47 {1'b0}}, Qcnt_four_2[10:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[31:30];
						Q_sqrt3 = {{46 {1'b0}}, Qcnt_four_2[10:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000011: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[29:28];
						Q_sqrt0 = {{45 {1'b0}}, Qcnt_four_3[14:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[27:26];
						Q_sqrt1 = {{44 {1'b0}}, Qcnt_four_3[14:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[25:24];
						Q_sqrt2 = {{43 {1'b0}}, Qcnt_four_3[14:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[23:22];
						Q_sqrt3 = {{42 {1'b0}}, Qcnt_four_3[14:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000100: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[21:20];
						Q_sqrt0 = {{41 {1'b0}}, Qcnt_four_4[18:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[19:18];
						Q_sqrt1 = {{40 {1'b0}}, Qcnt_four_4[18:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[17:16];
						Q_sqrt2 = {{39 {1'b0}}, Qcnt_four_4[18:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[15:14];
						Q_sqrt3 = {{38 {1'b0}}, Qcnt_four_4[18:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000101: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[13:12];
						Q_sqrt0 = {{37 {1'b0}}, Qcnt_four_5[22:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[11:10];
						Q_sqrt1 = {{36 {1'b0}}, Qcnt_four_5[22:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[9:8];
						Q_sqrt2 = {{35 {1'b0}}, Qcnt_four_5[22:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[7:6];
						Q_sqrt3 = {{34 {1'b0}}, Qcnt_four_5[22:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000110: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[5:4];
						Q_sqrt0 = {{33 {1'b0}}, Qcnt_four_6[26:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = Mant_D_sqrt_Norm[3:2];
						Q_sqrt1 = {{32 {1'b0}}, Qcnt_four_6[26:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[1:0];
						Q_sqrt2 = {{31 {1'b0}}, Qcnt_four_6[26:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{30 {1'b0}}, Qcnt_four_6[26:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b000111: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{29 {1'b0}}, Qcnt_four_7[30:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{28 {1'b0}}, Qcnt_four_7[30:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{27 {1'b0}}, Qcnt_four_7[30:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{26 {1'b0}}, Qcnt_four_7[30:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001000: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{25 {1'b0}}, Qcnt_four_8[34:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{24 {1'b0}}, Qcnt_four_8[34:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{23 {1'b0}}, Qcnt_four_8[34:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{22 {1'b0}}, Qcnt_four_8[34:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001001: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{21 {1'b0}}, Qcnt_four_9[38:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{20 {1'b0}}, Qcnt_four_9[38:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{19 {1'b0}}, Qcnt_four_9[38:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{18 {1'b0}}, Qcnt_four_9[38:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001010: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{17 {1'b0}}, Qcnt_four_10[42:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{16 {1'b0}}, Qcnt_four_10[42:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{15 {1'b0}}, Qcnt_four_10[42:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{14 {1'b0}}, Qcnt_four_10[42:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001011: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{13 {1'b0}}, Qcnt_four_11[46:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{12 {1'b0}}, Qcnt_four_11[46:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{11 {1'b0}}, Qcnt_four_11[46:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{10 {1'b0}}, Qcnt_four_11[46:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001100: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{9 {1'b0}}, Qcnt_four_12[50:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{8 {1'b0}}, Qcnt_four_12[50:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{7 {1'b0}}, Qcnt_four_12[50:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{6 {1'b0}}, Qcnt_four_12[50:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					6'b001101: begin
						Sqrt_DI[0] = 2'b00;
						Q_sqrt0 = {{5 {1'b0}}, Qcnt_four_13[54:3]};
						Sqrt_Q0 = (Quotient_DP[0] ? Q_sqrt_com_0 : Q_sqrt0);
						Sqrt_DI[1] = 2'b00;
						Q_sqrt1 = {{4 {1'b0}}, Qcnt_four_13[54:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = 2'b00;
						Q_sqrt2 = {{3 {1'b0}}, Qcnt_four_13[54:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = 2'b00;
						Q_sqrt3 = {{2 {1'b0}}, Qcnt_four_13[54:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
					default: begin
						Sqrt_DI[0] = Mant_D_sqrt_Norm[53:defs_div_sqrt_mvp_C_MANT_FP64];
						Q_sqrt0 = {{57 {1'b0}}, Qcnt_four_0[3]};
						Sqrt_Q0 = Q_sqrt_com_0;
						Sqrt_DI[1] = Mant_D_sqrt_Norm[51:50];
						Q_sqrt1 = {{56 {1'b0}}, Qcnt_four_0[3:2]};
						Sqrt_Q1 = (Sqrt_quotinent_S[3] ? Q_sqrt_com_1 : Q_sqrt1);
						Sqrt_DI[2] = Mant_D_sqrt_Norm[49:48];
						Q_sqrt2 = {{55 {1'b0}}, Qcnt_four_0[3:1]};
						Sqrt_Q2 = (Sqrt_quotinent_S[2] ? Q_sqrt_com_2 : Q_sqrt2);
						Sqrt_DI[3] = Mant_D_sqrt_Norm[47:46];
						Q_sqrt3 = {{54 {1'b0}}, Qcnt_four_0[3:0]};
						Sqrt_Q3 = (Sqrt_quotinent_S[1] ? Q_sqrt_com_3 : Q_sqrt3);
					end
				endcase
		endcase
	assign Sqrt_R0 = (Sqrt_start_dly_S ? {58 {1'sb0}} : {Partial_remainder_DP[57:0]});
	assign Sqrt_R1 = {Iteration_cell_sum_AMASK_D[0][57], Iteration_cell_sum_AMASK_D[0][54:0], Sqrt_DO[0]};
	assign Sqrt_R2 = {Iteration_cell_sum_AMASK_D[1][57], Iteration_cell_sum_AMASK_D[1][54:0], Sqrt_DO[1]};
	assign Sqrt_R3 = {Iteration_cell_sum_AMASK_D[2][57], Iteration_cell_sum_AMASK_D[2][54:0], Sqrt_DO[2]};
	assign Sqrt_R4 = {Iteration_cell_sum_AMASK_D[3][57], Iteration_cell_sum_AMASK_D[3][54:0], Sqrt_DO[3]};
	wire [57:0] Denominator_se_format_DB;
	assign Denominator_se_format_DB = {Denominator_se_DB[53:45], {(FP16ALT_SO ? FP16ALT_SO : Denominator_se_DB[44])}, Denominator_se_DB[43:42], {(FP16_SO ? FP16_SO : Denominator_se_DB[41])}, Denominator_se_DB[40:29], {(FP32_SO ? FP32_SO : Denominator_se_DB[28])}, Denominator_se_DB[27:0], FP64_SO, 3'b000};
	wire [57:0] First_iteration_cell_div_a_D;
	wire [57:0] First_iteration_cell_div_b_D;
	wire Sel_b_for_first_S;
	assign First_iteration_cell_div_a_D = (Div_start_dly_S ? {Numerator_se_D[53:45], {(FP16ALT_SO ? FP16ALT_SO : Numerator_se_D[44])}, Numerator_se_D[43:42], {(FP16_SO ? FP16_SO : Numerator_se_D[41])}, Numerator_se_D[40:29], {(FP32_SO ? FP32_SO : Numerator_se_D[28])}, Numerator_se_D[27:0], FP64_SO, 3'b000} : {Partial_remainder_DP[56:48], {(FP16ALT_SO ? Quotient_DP[0] : Partial_remainder_DP[47])}, Partial_remainder_DP[46:45], {(FP16_SO ? Quotient_DP[0] : Partial_remainder_DP[44])}, Partial_remainder_DP[43:32], {(FP32_SO ? Quotient_DP[0] : Partial_remainder_DP[31])}, Partial_remainder_DP[30:3], FP64_SO && Quotient_DP[0], 3'b000});
	assign Sel_b_for_first_S = (Div_start_dly_S ? 1 : Quotient_DP[0]);
	assign First_iteration_cell_div_b_D = (Sel_b_for_first_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
	assign Iteration_cell_a_BMASK_D[0] = (Sqrt_enable_SO ? Sqrt_R0 : {First_iteration_cell_div_a_D});
	assign Iteration_cell_b_BMASK_D[0] = (Sqrt_enable_SO ? Sqrt_Q0 : {First_iteration_cell_div_b_D});
	wire [57:0] Sec_iteration_cell_div_a_D;
	wire [57:0] Sec_iteration_cell_div_b_D;
	wire Sel_b_for_sec_S;
	generate
		if (|defs_div_sqrt_mvp_Iteration_unit_num_S) begin : genblk1
			assign Sel_b_for_sec_S = ~Iteration_cell_sum_AMASK_D[0][57];
			assign Sec_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[0][56:48], {(FP16ALT_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][47])}, Iteration_cell_sum_AMASK_D[0][46:45], {(FP16_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][44])}, Iteration_cell_sum_AMASK_D[0][43:32], {(FP32_SO ? Sel_b_for_sec_S : Iteration_cell_sum_AMASK_D[0][31])}, Iteration_cell_sum_AMASK_D[0][30:3], FP64_SO && Sel_b_for_sec_S, 3'b000};
			assign Sec_iteration_cell_div_b_D = (Sel_b_for_sec_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[1] = (Sqrt_enable_SO ? Sqrt_R1 : {Sec_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[1] = (Sqrt_enable_SO ? Sqrt_Q1 : {Sec_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Thi_iteration_cell_div_a_D;
	wire [57:0] Thi_iteration_cell_div_b_D;
	wire Sel_b_for_thi_S;
	generate
		if ((defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b10) | (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b11)) begin : genblk2
			assign Sel_b_for_thi_S = ~Iteration_cell_sum_AMASK_D[1][57];
			assign Thi_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[1][56:48], {(FP16ALT_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][47])}, Iteration_cell_sum_AMASK_D[1][46:45], {(FP16_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][44])}, Iteration_cell_sum_AMASK_D[1][43:32], {(FP32_SO ? Sel_b_for_thi_S : Iteration_cell_sum_AMASK_D[1][31])}, Iteration_cell_sum_AMASK_D[1][30:3], FP64_SO && Sel_b_for_thi_S, 3'b000};
			assign Thi_iteration_cell_div_b_D = (Sel_b_for_thi_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[2] = (Sqrt_enable_SO ? Sqrt_R2 : {Thi_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[2] = (Sqrt_enable_SO ? Sqrt_Q2 : {Thi_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Fou_iteration_cell_div_a_D;
	wire [57:0] Fou_iteration_cell_div_b_D;
	wire Sel_b_for_fou_S;
	generate
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b11) begin : genblk3
			assign Sel_b_for_fou_S = ~Iteration_cell_sum_AMASK_D[2][57];
			assign Fou_iteration_cell_div_a_D = {Iteration_cell_sum_AMASK_D[2][56:48], {(FP16ALT_SO ? Sel_b_for_fou_S : Iteration_cell_sum_AMASK_D[2][47])}, Iteration_cell_sum_AMASK_D[2][46:45], {(FP16_SO ? Sel_b_for_fou_S : Iteration_cell_sum_AMASK_D[2][44])}, Iteration_cell_sum_AMASK_D[2][43:32], {(FP32_SO ? Sel_b_for_fou_S : Iteration_cell_sum_AMASK_D[2][31])}, Iteration_cell_sum_AMASK_D[2][30:3], FP64_SO && Sel_b_for_fou_S, 3'b000};
			assign Fou_iteration_cell_div_b_D = (Sel_b_for_fou_S ? Denominator_se_format_DB : {Denominator_se_D, 4'b0000});
			assign Iteration_cell_a_BMASK_D[3] = (Sqrt_enable_SO ? Sqrt_R3 : {Fou_iteration_cell_div_a_D});
			assign Iteration_cell_b_BMASK_D[3] = (Sqrt_enable_SO ? Sqrt_Q3 : {Fou_iteration_cell_div_b_D});
		end
	endgenerate
	wire [57:0] Mask_bits_ctl_S;
	assign Mask_bits_ctl_S = 58'h3ffffffffffffff;
	wire Div_enable_SI [3:0];
	wire Div_start_dly_SI [3:0];
	wire Sqrt_enable_SI [3:0];
	genvar i;
	genvar j;
	generate
		for (i = 0; i <= defs_div_sqrt_mvp_Iteration_unit_num_S; i = i + 1) begin : genblk4
			for (j = 0; j <= 57; j = j + 1) begin : genblk1
				assign Iteration_cell_a_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_a_BMASK_D[i][j];
				assign Iteration_cell_b_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_b_BMASK_D[i][j];
				assign Iteration_cell_sum_AMASK_D[i][j] = Mask_bits_ctl_S[j] && Iteration_cell_sum_D[i][j];
			end
			assign Div_enable_SI[i] = Div_enable_SO;
			assign Div_start_dly_SI[i] = Div_start_dly_S;
			assign Sqrt_enable_SI[i] = Sqrt_enable_SO;
			iteration_div_sqrt_mvp #(.WIDTH(58)) iteration_div_sqrt(
				.A_DI(Iteration_cell_a_D[i]),
				.B_DI(Iteration_cell_b_D[i]),
				.Div_enable_SI(Div_enable_SI[i]),
				.Div_start_dly_SI(Div_start_dly_SI[i]),
				.Sqrt_enable_SI(Sqrt_enable_SI[i]),
				.D_DI(Sqrt_DI[i]),
				.D_DO(Sqrt_DO[i]),
				.Sum_DO(Iteration_cell_sum_D[i]),
				.Carry_out_DO(Iteration_cell_carry_D[i])
			);
		end
	endgenerate
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R1 : Iteration_cell_sum_AMASK_D[0]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b01:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R2 : Iteration_cell_sum_AMASK_D[1]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b10:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R3 : Iteration_cell_sum_AMASK_D[2]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
			2'b11:
				if (Fsm_enable_S)
					Partial_remainder_DN = (Sqrt_enable_SO ? Sqrt_R4 : Iteration_cell_sum_AMASK_D[3]);
				else
					Partial_remainder_DN = Partial_remainder_DP;
		endcase
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Partial_remainder_DP <= 1'sb0;
		else
			Partial_remainder_DP <= Partial_remainder_DN;
	reg [56:0] Quotient_DN;
	always @(*)
		case (defs_div_sqrt_mvp_Iteration_unit_num_S)
			2'b00:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[55:0], Sqrt_quotinent_S[3]} : {Quotient_DP[55:0], Iteration_cell_carry_D[0]});
				else
					Quotient_DN = Quotient_DP;
			2'b01:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[54:0], Sqrt_quotinent_S[3:2]} : {Quotient_DP[54:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1]});
				else
					Quotient_DN = Quotient_DP;
			2'b10:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[53:0], Sqrt_quotinent_S[3:1]} : {Quotient_DP[53:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2]});
				else
					Quotient_DN = Quotient_DP;
			2'b11:
				if (Fsm_enable_S)
					Quotient_DN = (Sqrt_enable_SO ? {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], Sqrt_quotinent_S} : {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], Iteration_cell_carry_D[0], Iteration_cell_carry_D[1], Iteration_cell_carry_D[2], Iteration_cell_carry_D[3]});
				else
					Quotient_DN = Quotient_DP;
		endcase
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Quotient_DP <= 1'sb0;
		else
			Quotient_DP <= Quotient_DN;
	generate
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b00) begin : genblk5
			always @(*)
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
							6'h17: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
							6'h16: Mant_result_prenorm_DO = {Quotient_DP[22:0], {34 {1'b0}}};
							6'h15: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
							6'h14: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
							6'h13: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
							6'h12: Mant_result_prenorm_DO = {Quotient_DP[18:0], {38 {1'b0}}};
							6'h11: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h10: Mant_result_prenorm_DO = {Quotient_DP[16:0], {40 {1'b0}}};
							6'h0f: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
							6'h0e: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0d: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
							6'h0c: Mant_result_prenorm_DO = {Quotient_DP[12:0], {44 {1'b0}}};
							6'h0b: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h0a: Mant_result_prenorm_DO = {Quotient_DP[10:0], {46 {1'b0}}};
							6'h09: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
							6'h08: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = Quotient_DP[56:0];
							6'h34: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP64:0], {4 {1'b0}}};
							6'h33: Mant_result_prenorm_DO = {Quotient_DP[51:0], {5 {1'b0}}};
							6'h32: Mant_result_prenorm_DO = {Quotient_DP[50:0], {6 {1'b0}}};
							6'h31: Mant_result_prenorm_DO = {Quotient_DP[49:0], {7 {1'b0}}};
							6'h30: Mant_result_prenorm_DO = {Quotient_DP[48:0], {8 {1'b0}}};
							6'h2f: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
							6'h2e: Mant_result_prenorm_DO = {Quotient_DP[46:0], {10 {1'b0}}};
							6'h2d: Mant_result_prenorm_DO = {Quotient_DP[45:0], {11 {1'b0}}};
							6'h2c: Mant_result_prenorm_DO = {Quotient_DP[44:0], {12 {1'b0}}};
							6'h2b: Mant_result_prenorm_DO = {Quotient_DP[43:0], {13 {1'b0}}};
							6'h2a: Mant_result_prenorm_DO = {Quotient_DP[42:0], {14 {1'b0}}};
							6'h29: Mant_result_prenorm_DO = {Quotient_DP[41:0], {15 {1'b0}}};
							6'h28: Mant_result_prenorm_DO = {Quotient_DP[40:0], {16 {1'b0}}};
							6'h27: Mant_result_prenorm_DO = {Quotient_DP[39:0], {17 {1'b0}}};
							6'h26: Mant_result_prenorm_DO = {Quotient_DP[38:0], {18 {1'b0}}};
							6'h25: Mant_result_prenorm_DO = {Quotient_DP[37:0], {19 {1'b0}}};
							6'h24: Mant_result_prenorm_DO = {Quotient_DP[36:0], {20 {1'b0}}};
							6'h23: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
							6'h22: Mant_result_prenorm_DO = {Quotient_DP[34:0], {22 {1'b0}}};
							6'h21: Mant_result_prenorm_DO = {Quotient_DP[33:0], {23 {1'b0}}};
							6'h20: Mant_result_prenorm_DO = {Quotient_DP[32:0], {24 {1'b0}}};
							6'h1f: Mant_result_prenorm_DO = {Quotient_DP[31:0], {25 {1'b0}}};
							6'h1e: Mant_result_prenorm_DO = {Quotient_DP[30:0], {26 {1'b0}}};
							6'h1d: Mant_result_prenorm_DO = {Quotient_DP[29:0], {27 {1'b0}}};
							6'h1c: Mant_result_prenorm_DO = {Quotient_DP[28:0], {28 {1'b0}}};
							6'h1b: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
							6'h1a: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
							6'h19: Mant_result_prenorm_DO = {Quotient_DP[25:0], {31 {1'b0}}};
							6'h18: Mant_result_prenorm_DO = {Quotient_DP[24:0], {32 {1'b0}}};
							6'h17: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
							6'h16: Mant_result_prenorm_DO = {Quotient_DP[22:0], {34 {1'b0}}};
							6'h15: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
							6'h14: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
							6'h13: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
							6'h12: Mant_result_prenorm_DO = {Quotient_DP[18:0], {38 {1'b0}}};
							6'h11: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h10: Mant_result_prenorm_DO = {Quotient_DP[16:0], {40 {1'b0}}};
							6'h0f: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
							6'h0e: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0d: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
							6'h0c: Mant_result_prenorm_DO = {Quotient_DP[12:0], {44 {1'b0}}};
							6'h0b: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h0a: Mant_result_prenorm_DO = {Quotient_DP[10:0], {46 {1'b0}}};
							6'h09: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
							6'h08: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = Quotient_DP[56:0];
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0a: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16:0], {46 {1'b0}}};
							6'h09: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
							6'h08: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h07: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16ALT:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						endcase
				endcase
		end
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b01) begin : genblk6
			always @(*)
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
							6'h17, 6'h16: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
							6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
							6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
							6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h0f, 6'h0e: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
							6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
							6'h0b, 6'h0a: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
							6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
							6'h34: Mant_result_prenorm_DO = {Quotient_DP[53:1], {4 {1'b0}}};
							6'h33, 6'h32: Mant_result_prenorm_DO = {Quotient_DP[51:0], {5 {1'b0}}};
							6'h31, 6'h30: Mant_result_prenorm_DO = {Quotient_DP[49:0], {7 {1'b0}}};
							6'h2f, 6'h2e: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
							6'h2d, 6'h2c: Mant_result_prenorm_DO = {Quotient_DP[45:0], {11 {1'b0}}};
							6'h2b, 6'h2a: Mant_result_prenorm_DO = {Quotient_DP[43:0], {13 {1'b0}}};
							6'h29, 6'h28: Mant_result_prenorm_DO = {Quotient_DP[41:0], {15 {1'b0}}};
							6'h27, 6'h26: Mant_result_prenorm_DO = {Quotient_DP[39:0], {17 {1'b0}}};
							6'h25, 6'h24: Mant_result_prenorm_DO = {Quotient_DP[37:0], {19 {1'b0}}};
							6'h23, 6'h22: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
							6'h21, 6'h20: Mant_result_prenorm_DO = {Quotient_DP[33:0], {23 {1'b0}}};
							6'h1f, 6'h1e: Mant_result_prenorm_DO = {Quotient_DP[31:0], {25 {1'b0}}};
							6'h1d, 6'h1c: Mant_result_prenorm_DO = {Quotient_DP[29:0], {27 {1'b0}}};
							6'h1b, 6'h1a: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
							6'h19, 6'h18: Mant_result_prenorm_DO = {Quotient_DP[25:0], {31 {1'b0}}};
							6'h17, 6'h16: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
							6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[21:0], {35 {1'b0}}};
							6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
							6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h0f, 6'h0e: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
							6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
							6'h0b, 6'h0a: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
							6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[13:0], {43 {1'b0}}};
							6'h0a: Mant_result_prenorm_DO = {Quotient_DP[11:1], {46 {1'b0}}};
							6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[9:0], {47 {1'b0}}};
							6'h07: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h07: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16ALT:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						endcase
				endcase
		end
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b10) begin : genblk7
			always @(*)
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
							6'h17, 6'h16, 6'h15: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
							6'h14, 6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
							6'h11, 6'h10, 6'h0f: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0b, 6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = Quotient_DP[56:0];
							6'h34, 6'h33: Mant_result_prenorm_DO = {Quotient_DP[53:1], {4 {1'b0}}};
							6'h32, 6'h31, 6'h30: Mant_result_prenorm_DO = {Quotient_DP[50:0], {6 {1'b0}}};
							6'h2f, 6'h2e, 6'h2d: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
							6'h2c, 6'h2b, 6'h2a: Mant_result_prenorm_DO = {Quotient_DP[44:0], {12 {1'b0}}};
							6'h29, 6'h28, 6'h27: Mant_result_prenorm_DO = {Quotient_DP[41:0], {15 {1'b0}}};
							6'h26, 6'h25, 6'h24: Mant_result_prenorm_DO = {Quotient_DP[38:0], {18 {1'b0}}};
							6'h23, 6'h22, 6'h21: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
							6'h20, 6'h1f, 6'h1e: Mant_result_prenorm_DO = {Quotient_DP[32:0], {24 {1'b0}}};
							6'h1d, 6'h1c, 6'h1b: Mant_result_prenorm_DO = {Quotient_DP[29:0], {27 {1'b0}}};
							6'h1a, 6'h19, 6'h18: Mant_result_prenorm_DO = {Quotient_DP[26:0], {30 {1'b0}}};
							6'h17, 6'h16, 6'h15: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
							6'h14, 6'h13, 6'h12: Mant_result_prenorm_DO = {Quotient_DP[20:0], {36 {1'b0}}};
							6'h11, 6'h10, 6'h0f: Mant_result_prenorm_DO = {Quotient_DP[17:0], {39 {1'b0}}};
							6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0b, 6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							default: Mant_result_prenorm_DO = Quotient_DP[56:0];
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
							6'h0a, 6'h09: Mant_result_prenorm_DO = {Quotient_DP[11:1], {46 {1'b0}}};
							6'h08, 6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:0], {48 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[14:0], {42 {1'b0}}};
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[8:1], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						endcase
				endcase
		end
		if (defs_div_sqrt_mvp_Iteration_unit_num_S == 2'b11) begin : genblk8
			always @(*)
				case (Format_sel_S)
					2'b00:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
							6'h17, 6'h16, 6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP32:0], {33 {1'b0}}};
							6'h13, 6'h12, 6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
							6'h0f, 6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
							6'h0b, 6'h0a, 6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
						endcase
					2'b01:
						case (Precision_ctl_S)
							6'h00: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
							6'h34: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
							6'h33, 6'h32, 6'h31, 6'h30: Mant_result_prenorm_DO = {Quotient_DP[51:0], {5 {1'b0}}};
							6'h2f, 6'h2e, 6'h2d, 6'h2c: Mant_result_prenorm_DO = {Quotient_DP[47:0], {9 {1'b0}}};
							6'h2b, 6'h2a, 6'h29, 6'h28: Mant_result_prenorm_DO = {Quotient_DP[43:0], {13 {1'b0}}};
							6'h27, 6'h26, 6'h25, 6'h24: Mant_result_prenorm_DO = {Quotient_DP[39:0], {17 {1'b0}}};
							6'h23, 6'h22, 6'h21, 6'h20: Mant_result_prenorm_DO = {Quotient_DP[35:0], {21 {1'b0}}};
							6'h1f, 6'h1e, 6'h1d, 6'h1c: Mant_result_prenorm_DO = {Quotient_DP[31:0], {25 {1'b0}}};
							6'h1b, 6'h1a, 6'h19, 6'h18: Mant_result_prenorm_DO = {Quotient_DP[27:0], {29 {1'b0}}};
							6'h17, 6'h16, 6'h15, 6'h14: Mant_result_prenorm_DO = {Quotient_DP[23:0], {33 {1'b0}}};
							6'h13, 6'h12, 6'h11, 6'h10: Mant_result_prenorm_DO = {Quotient_DP[19:0], {37 {1'b0}}};
							6'h0f, 6'h0e, 6'h0d, 6'h0c: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
							6'h0b, 6'h0a, 6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[55:0], 1'b0};
						endcase
					2'b10:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
							6'h0a, 6'h09, 6'h08: Mant_result_prenorm_DO = {Quotient_DP[11:1], {46 {1'b0}}};
							6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[7:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[15:0], {41 {1'b0}}};
						endcase
					2'b11:
						case (Precision_ctl_S)
							6'b000000: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
							6'h07, 6'h06: Mant_result_prenorm_DO = {Quotient_DP[defs_div_sqrt_mvp_C_MANT_FP16ALT:0], {49 {1'b0}}};
							default: Mant_result_prenorm_DO = {Quotient_DP[11:0], {45 {1'b0}}};
						endcase
				endcase
		end
	endgenerate
	wire [12:0] Exp_result_prenorm_DN;
	reg [12:0] Exp_result_prenorm_DP;
	wire [12:0] Exp_add_a_D;
	wire [12:0] Exp_add_b_D;
	wire [12:0] Exp_add_c_D;
	integer C_BIAS_AONE;
	integer C_HALF_BIAS;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP16 = 5'h10;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP16ALT = 8'h80;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP32 = 8'h80;
	localparam defs_div_sqrt_mvp_C_BIAS_AONE_FP64 = 11'h400;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP16 = 7;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP16ALT = 63;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP32 = 63;
	localparam defs_div_sqrt_mvp_C_HALF_BIAS_FP64 = 511;
	always @(*)
		case (Format_sel_S)
			2'b00: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP32;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP32;
			end
			2'b01: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP64;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP64;
			end
			2'b10: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP16;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP16;
			end
			2'b11: begin
				C_BIAS_AONE = defs_div_sqrt_mvp_C_BIAS_AONE_FP16ALT;
				C_HALF_BIAS = defs_div_sqrt_mvp_C_HALF_BIAS_FP16ALT;
			end
		endcase
	assign Exp_add_a_D = {(Sqrt_start_dly_S ? {Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64:1]} : {Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI[defs_div_sqrt_mvp_C_EXP_FP64], Exp_num_DI})};
	localparam defs_div_sqrt_mvp_C_EXP_ZERO_FP64 = 11'h000;
	assign Exp_add_b_D = {(Sqrt_start_dly_S ? {1'b0, {defs_div_sqrt_mvp_C_EXP_ZERO_FP64}, Exp_num_DI[0]} : {~Exp_den_DI[defs_div_sqrt_mvp_C_EXP_FP64], ~Exp_den_DI[defs_div_sqrt_mvp_C_EXP_FP64], ~Exp_den_DI})};
	assign Exp_add_c_D = {(Div_start_dly_S ? {C_BIAS_AONE} : {C_HALF_BIAS})};
	assign Exp_result_prenorm_DN = (Start_dly_S ? {(Exp_add_a_D + Exp_add_b_D) + Exp_add_c_D} : Exp_result_prenorm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_result_prenorm_DP <= 1'sb0;
		else
			Exp_result_prenorm_DP <= Exp_result_prenorm_DN;
	assign Exp_result_prenorm_DO = Exp_result_prenorm_DP;
endmodule
module div_sqrt_top_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Operand_a_DI,
	Operand_b_DI,
	RM_SI,
	Precision_ctl_SI,
	Format_sel_SI,
	Kill_SI,
	Result_DO,
	Fflags_SO,
	Ready_SO,
	Done_SO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	localparam defs_div_sqrt_mvp_C_OP_FP64 = 64;
	input wire [63:0] Operand_a_DI;
	input wire [63:0] Operand_b_DI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	localparam defs_div_sqrt_mvp_C_FS = 2;
	input wire [1:0] Format_sel_SI;
	input wire Kill_SI;
	output wire [63:0] Result_DO;
	output wire [4:0] Fflags_SO;
	output wire Ready_SO;
	output wire Done_SO;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_D;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_D;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_D;
	wire [12:0] Exp_z_D;
	wire [56:0] Mant_z_D;
	wire Sign_z_D;
	wire Start_S;
	wire [2:0] RM_dly_S;
	wire Div_enable_S;
	wire Sqrt_enable_S;
	wire Inf_a_S;
	wire Inf_b_S;
	wire Zero_a_S;
	wire Zero_b_S;
	wire NaN_a_S;
	wire NaN_b_S;
	wire SNaN_S;
	wire Special_case_SB;
	wire Special_case_dly_SB;
	wire Full_precision_S;
	wire FP32_S;
	wire FP64_S;
	wire FP16_S;
	wire FP16ALT_S;
	preprocess_mvp preprocess_U0(
		.Clk_CI(Clk_CI),
		.Rst_RBI(Rst_RBI),
		.Div_start_SI(Div_start_SI),
		.Sqrt_start_SI(Sqrt_start_SI),
		.Ready_SI(Ready_SO),
		.Operand_a_DI(Operand_a_DI),
		.Operand_b_DI(Operand_b_DI),
		.RM_SI(RM_SI),
		.Format_sel_SI(Format_sel_SI),
		.Start_SO(Start_S),
		.Exp_a_DO_norm(Exp_a_D),
		.Exp_b_DO_norm(Exp_b_D),
		.Mant_a_DO_norm(Mant_a_D),
		.Mant_b_DO_norm(Mant_b_D),
		.RM_dly_SO(RM_dly_S),
		.Sign_z_DO(Sign_z_D),
		.Inf_a_SO(Inf_a_S),
		.Inf_b_SO(Inf_b_S),
		.Zero_a_SO(Zero_a_S),
		.Zero_b_SO(Zero_b_S),
		.NaN_a_SO(NaN_a_S),
		.NaN_b_SO(NaN_b_S),
		.SNaN_SO(SNaN_S),
		.Special_case_SBO(Special_case_SB),
		.Special_case_dly_SBO(Special_case_dly_SB)
	);
	nrbd_nrsc_mvp nrbd_nrsc_U0(
		.Clk_CI(Clk_CI),
		.Rst_RBI(Rst_RBI),
		.Div_start_SI(Div_start_SI),
		.Sqrt_start_SI(Sqrt_start_SI),
		.Start_SI(Start_S),
		.Kill_SI(Kill_SI),
		.Special_case_SBI(Special_case_SB),
		.Special_case_dly_SBI(Special_case_dly_SB),
		.Div_enable_SO(Div_enable_S),
		.Sqrt_enable_SO(Sqrt_enable_S),
		.Precision_ctl_SI(Precision_ctl_SI),
		.Format_sel_SI(Format_sel_SI),
		.Exp_a_DI(Exp_a_D),
		.Exp_b_DI(Exp_b_D),
		.Mant_a_DI(Mant_a_D),
		.Mant_b_DI(Mant_b_D),
		.Full_precision_SO(Full_precision_S),
		.FP32_SO(FP32_S),
		.FP64_SO(FP64_S),
		.FP16_SO(FP16_S),
		.FP16ALT_SO(FP16ALT_S),
		.Ready_SO(Ready_SO),
		.Done_SO(Done_SO),
		.Exp_z_DO(Exp_z_D),
		.Mant_z_DO(Mant_z_D)
	);
	norm_div_sqrt_mvp fpu_norm_U0(
		.Mant_in_DI(Mant_z_D),
		.Exp_in_DI(Exp_z_D),
		.Sign_in_DI(Sign_z_D),
		.Div_enable_SI(Div_enable_S),
		.Sqrt_enable_SI(Sqrt_enable_S),
		.Inf_a_SI(Inf_a_S),
		.Inf_b_SI(Inf_b_S),
		.Zero_a_SI(Zero_a_S),
		.Zero_b_SI(Zero_b_S),
		.NaN_a_SI(NaN_a_S),
		.NaN_b_SI(NaN_b_S),
		.SNaN_SI(SNaN_S),
		.RM_SI(RM_dly_S),
		.Full_precision_SI(Full_precision_S),
		.FP32_SI(FP32_S),
		.FP64_SI(FP64_S),
		.FP16_SI(FP16_S),
		.FP16ALT_SI(FP16ALT_S),
		.Result_DO(Result_DO),
		.Fflags_SO(Fflags_SO)
	);
endmodule
module iteration_div_sqrt_mvp (
	A_DI,
	B_DI,
	Div_enable_SI,
	Div_start_dly_SI,
	Sqrt_enable_SI,
	D_DI,
	D_DO,
	Sum_DO,
	Carry_out_DO
);
	parameter WIDTH = 25;
	input wire [WIDTH - 1:0] A_DI;
	input wire [WIDTH - 1:0] B_DI;
	input wire Div_enable_SI;
	input wire Div_start_dly_SI;
	input wire Sqrt_enable_SI;
	input wire [1:0] D_DI;
	output wire [1:0] D_DO;
	output wire [WIDTH - 1:0] Sum_DO;
	output wire Carry_out_DO;
	wire D_carry_D;
	wire Sqrt_cin_D;
	wire Cin_D;
	assign D_DO[0] = ~D_DI[0];
	assign D_DO[1] = ~(D_DI[1] ^ D_DI[0]);
	assign D_carry_D = D_DI[1] | D_DI[0];
	assign Sqrt_cin_D = Sqrt_enable_SI && D_carry_D;
	assign Cin_D = (Div_enable_SI ? 1'b0 : Sqrt_cin_D);
	assign {Carry_out_DO, Sum_DO} = (A_DI + B_DI) + Cin_D;
endmodule
module norm_div_sqrt_mvp (
	Mant_in_DI,
	Exp_in_DI,
	Sign_in_DI,
	Div_enable_SI,
	Sqrt_enable_SI,
	Inf_a_SI,
	Inf_b_SI,
	Zero_a_SI,
	Zero_b_SI,
	NaN_a_SI,
	NaN_b_SI,
	SNaN_SI,
	RM_SI,
	Full_precision_SI,
	FP32_SI,
	FP64_SI,
	FP16_SI,
	FP16ALT_SI,
	Result_DO,
	Fflags_SO
);
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [56:0] Mant_in_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire signed [12:0] Exp_in_DI;
	input wire Sign_in_DI;
	input wire Div_enable_SI;
	input wire Sqrt_enable_SI;
	input wire Inf_a_SI;
	input wire Inf_b_SI;
	input wire Zero_a_SI;
	input wire Zero_b_SI;
	input wire NaN_a_SI;
	input wire NaN_b_SI;
	input wire SNaN_SI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	input wire Full_precision_SI;
	input wire FP32_SI;
	input wire FP64_SI;
	input wire FP16_SI;
	input wire FP16ALT_SI;
	output reg [63:0] Result_DO;
	output wire [4:0] Fflags_SO;
	reg Sign_res_D;
	reg NV_OP_S;
	reg Exp_OF_S;
	reg Exp_UF_S;
	reg Div_Zero_S;
	wire In_Exact_S;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_res_norm_D;
	reg [10:0] Exp_res_norm_D;
	wire [12:0] Exp_Max_RS_FP64_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP32 = 8;
	wire [9:0] Exp_Max_RS_FP32_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP16 = 5;
	wire [6:0] Exp_Max_RS_FP16_D;
	localparam defs_div_sqrt_mvp_C_EXP_FP16ALT = 8;
	wire [9:0] Exp_Max_RS_FP16ALT_D;
	assign Exp_Max_RS_FP64_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] + defs_div_sqrt_mvp_C_MANT_FP64) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	assign Exp_Max_RS_FP32_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP32:0] + defs_div_sqrt_mvp_C_MANT_FP32) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	assign Exp_Max_RS_FP16_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16:0] + defs_div_sqrt_mvp_C_MANT_FP16) + 1;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	assign Exp_Max_RS_FP16ALT_D = (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16ALT:0] + defs_div_sqrt_mvp_C_MANT_FP16ALT) + 1;
	wire [12:0] Num_RS_D;
	assign Num_RS_D = ~Exp_in_DI + 2;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_RS_D;
	wire [56:0] Mant_forsticky_D;
	assign {Mant_RS_D, Mant_forsticky_D} = {Mant_in_DI, {53 {1'b0}}} >> Num_RS_D;
	wire [12:0] Exp_subOne_D;
	assign Exp_subOne_D = Exp_in_DI - 1;
	reg [1:0] Mant_lower_D;
	reg Mant_sticky_bit_D;
	reg [56:0] Mant_forround_D;
	localparam defs_div_sqrt_mvp_C_EXP_ONE_FP64 = 13'h0001;
	localparam defs_div_sqrt_mvp_C_MANT_NAN_FP64 = 52'h8000000000000;
	always @(*)
		if (NaN_a_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = 1'b0;
			NV_OP_S = SNaN_SI;
		end
		else if (NaN_b_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = 1'b0;
			NV_OP_S = SNaN_SI;
		end
		else if (Inf_a_SI) begin
			if (Div_enable_SI && Inf_b_SI) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else if (Sqrt_enable_SI && Sign_in_DI) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Div_enable_SI && Inf_b_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b1;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = 1'sb0;
			Exp_res_norm_D = 1'sb0;
			Mant_forround_D = 1'sb0;
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Zero_a_SI) begin
			if (Div_enable_SI && Zero_b_SI) begin
				Div_Zero_S = 1'b1;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = 1'b0;
				NV_OP_S = 1'b1;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Div_enable_SI && Zero_b_SI) begin
			Div_Zero_S = 1'b1;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = 1'sb0;
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Sign_in_DI && Sqrt_enable_SI) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = {1'b0, defs_div_sqrt_mvp_C_MANT_NAN_FP64};
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = 1'b0;
			NV_OP_S = 1'b1;
		end
		else if (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] == {12 {1'sb0}}) begin
			if (Mant_in_DI != {57 {1'sb0}}) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b1;
				Mant_res_norm_D = {1'b0, Mant_in_DI[56:5]};
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = {Mant_in_DI[4:0], {defs_div_sqrt_mvp_C_MANT_FP64 {1'b0}}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb0;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if ((Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64:0] == defs_div_sqrt_mvp_C_EXP_ONE_FP64) && ~Mant_in_DI[56]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b1;
			Mant_res_norm_D = Mant_in_DI[56:4];
			Exp_res_norm_D = 1'sb0;
			Mant_forround_D = {Mant_in_DI[3:0], {53 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (Exp_in_DI[12]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b1;
			Mant_res_norm_D = {Mant_RS_D[defs_div_sqrt_mvp_C_MANT_FP64:0]};
			Exp_res_norm_D = 1'sb0;
			Mant_forround_D = {Mant_forsticky_D[56:0]};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if ((((Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP32] && FP32_SI) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP64] && FP64_SI)) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16] && FP16_SI)) | (Exp_in_DI[defs_div_sqrt_mvp_C_EXP_FP16ALT] && FP16ALT_SI)) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b1;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = 1'sb0;
			Exp_res_norm_D = 1'sb1;
			Mant_forround_D = 1'sb0;
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else if (((((Exp_in_DI[7:0] == {8 {1'sb1}}) && FP32_SI) | ((Exp_in_DI[10:0] == {11 {1'sb1}}) && FP64_SI)) | ((Exp_in_DI[4:0] == {5 {1'sb1}}) && FP16_SI)) | ((Exp_in_DI[7:0] == {8 {1'sb1}}) && FP16ALT_SI)) begin
			if (~Mant_in_DI[56]) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b0;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = Mant_in_DI[55:3];
				Exp_res_norm_D = Exp_subOne_D;
				Mant_forround_D = {Mant_in_DI[2:0], {54 {1'b0}}};
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else if (Mant_in_DI != {57 {1'sb0}}) begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
			else begin
				Div_Zero_S = 1'b0;
				Exp_OF_S = 1'b1;
				Exp_UF_S = 1'b0;
				Mant_res_norm_D = 1'sb0;
				Exp_res_norm_D = 1'sb1;
				Mant_forround_D = 1'sb0;
				Sign_res_D = Sign_in_DI;
				NV_OP_S = 1'b0;
			end
		end
		else if (Mant_in_DI[56]) begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = Mant_in_DI[56:4];
			Exp_res_norm_D = Exp_in_DI[10:0];
			Mant_forround_D = {Mant_in_DI[3:0], {53 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
		else begin
			Div_Zero_S = 1'b0;
			Exp_OF_S = 1'b0;
			Exp_UF_S = 1'b0;
			Mant_res_norm_D = Mant_in_DI[55:3];
			Exp_res_norm_D = Exp_subOne_D;
			Mant_forround_D = {Mant_in_DI[2:0], {54 {1'b0}}};
			Sign_res_D = Sign_in_DI;
			NV_OP_S = 1'b0;
		end
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_upper_D;
	wire [53:0] Mant_upperRounded_D;
	reg Mant_roundUp_S;
	wire Mant_rounded_S;
	always @(*)
		if (FP32_SI) begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:29], {29 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[28:27];
			Mant_sticky_bit_D = |Mant_res_norm_D[26:0];
		end
		else if (FP64_SI) begin
			Mant_upper_D = Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:0];
			Mant_lower_D = Mant_forround_D[56:55];
			Mant_sticky_bit_D = |Mant_forround_D[55:0];
		end
		else if (FP16_SI) begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:42], {42 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[41:40];
			Mant_sticky_bit_D = |Mant_res_norm_D[39:30];
		end
		else begin
			Mant_upper_D = {Mant_res_norm_D[defs_div_sqrt_mvp_C_MANT_FP64:45], {45 {1'b0}}};
			Mant_lower_D = Mant_res_norm_D[44:43];
			Mant_sticky_bit_D = |Mant_res_norm_D[42:30];
		end
	assign Mant_rounded_S = |Mant_lower_D | Mant_sticky_bit_D;
	localparam defs_div_sqrt_mvp_C_RM_MINUSINF = 3'h3;
	localparam defs_div_sqrt_mvp_C_RM_NEAREST = 3'h0;
	localparam defs_div_sqrt_mvp_C_RM_PLUSINF = 3'h2;
	localparam defs_div_sqrt_mvp_C_RM_TRUNC = 3'h1;
	always @(*) begin
		Mant_roundUp_S = 1'b0;
		case (RM_SI)
			defs_div_sqrt_mvp_C_RM_NEAREST: Mant_roundUp_S = Mant_lower_D[1] && ((Mant_lower_D[0] | Mant_sticky_bit_D) | ((((FP32_SI && Mant_upper_D[29]) | (FP64_SI && Mant_upper_D[0])) | (FP16_SI && Mant_upper_D[42])) | (FP16ALT_SI && Mant_upper_D[45])));
			defs_div_sqrt_mvp_C_RM_TRUNC: Mant_roundUp_S = 0;
			defs_div_sqrt_mvp_C_RM_PLUSINF: Mant_roundUp_S = Mant_rounded_S & ~Sign_in_DI;
			defs_div_sqrt_mvp_C_RM_MINUSINF: Mant_roundUp_S = Mant_rounded_S & Sign_in_DI;
			default: Mant_roundUp_S = 0;
		endcase
	end
	wire Mant_renorm_S;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_roundUp_Vector_S;
	assign Mant_roundUp_Vector_S = {7'h00, FP16ALT_SI && Mant_roundUp_S, 2'h0, FP16_SI && Mant_roundUp_S, 12'h000, FP32_SI && Mant_roundUp_S, 28'h0000000, FP64_SI && Mant_roundUp_S};
	assign Mant_upperRounded_D = Mant_upper_D + Mant_roundUp_Vector_S;
	assign Mant_renorm_S = Mant_upperRounded_D[53];
	wire [51:0] Mant_res_round_D;
	wire [10:0] Exp_res_round_D;
	assign Mant_res_round_D = (Mant_renorm_S ? Mant_upperRounded_D[defs_div_sqrt_mvp_C_MANT_FP64:1] : Mant_upperRounded_D[51:0]);
	assign Exp_res_round_D = Exp_res_norm_D + Mant_renorm_S;
	wire [51:0] Mant_before_format_ctl_D;
	wire [10:0] Exp_before_format_ctl_D;
	assign Mant_before_format_ctl_D = (Full_precision_SI ? Mant_res_round_D : Mant_res_norm_D);
	assign Exp_before_format_ctl_D = (Full_precision_SI ? Exp_res_round_D : Exp_res_norm_D);
	always @(*)
		if (FP32_SI)
			Result_DO = {32'hffffffff, Sign_res_D, Exp_before_format_ctl_D[7:0], Mant_before_format_ctl_D[51:29]};
		else if (FP64_SI)
			Result_DO = {Sign_res_D, Exp_before_format_ctl_D[10:0], Mant_before_format_ctl_D[51:0]};
		else if (FP16_SI)
			Result_DO = {48'hffffffffffff, Sign_res_D, Exp_before_format_ctl_D[4:0], Mant_before_format_ctl_D[51:42]};
		else
			Result_DO = {48'hffffffffffff, Sign_res_D, Exp_before_format_ctl_D[7:0], Mant_before_format_ctl_D[51:45]};
	assign In_Exact_S = ~Full_precision_SI | Mant_rounded_S;
	assign Fflags_SO = {NV_OP_S, Div_Zero_S, Exp_OF_S, Exp_UF_S, In_Exact_S};
endmodule
module nrbd_nrsc_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Start_SI,
	Kill_SI,
	Special_case_SBI,
	Special_case_dly_SBI,
	Precision_ctl_SI,
	Format_sel_SI,
	Mant_a_DI,
	Mant_b_DI,
	Exp_a_DI,
	Exp_b_DI,
	Div_enable_SO,
	Sqrt_enable_SO,
	Full_precision_SO,
	FP32_SO,
	FP64_SO,
	FP16_SO,
	FP16ALT_SO,
	Ready_SO,
	Done_SO,
	Mant_z_DO,
	Exp_z_DO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Start_SI;
	input wire Kill_SI;
	input wire Special_case_SBI;
	input wire Special_case_dly_SBI;
	localparam defs_div_sqrt_mvp_C_PC = 6;
	input wire [5:0] Precision_ctl_SI;
	input wire [1:0] Format_sel_SI;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_DI;
	input wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_DI;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_DI;
	input wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_DI;
	output wire Div_enable_SO;
	output wire Sqrt_enable_SO;
	output wire Full_precision_SO;
	output wire FP32_SO;
	output wire FP64_SO;
	output wire FP16_SO;
	output wire FP16ALT_SO;
	output wire Ready_SO;
	output wire Done_SO;
	output wire [56:0] Mant_z_DO;
	output wire [12:0] Exp_z_DO;
	wire Div_start_dly_S;
	wire Sqrt_start_dly_S;
	control_mvp control_U0(
		.Clk_CI(Clk_CI),
		.Rst_RBI(Rst_RBI),
		.Div_start_SI(Div_start_SI),
		.Sqrt_start_SI(Sqrt_start_SI),
		.Start_SI(Start_SI),
		.Kill_SI(Kill_SI),
		.Special_case_SBI(Special_case_SBI),
		.Special_case_dly_SBI(Special_case_dly_SBI),
		.Precision_ctl_SI(Precision_ctl_SI),
		.Format_sel_SI(Format_sel_SI),
		.Numerator_DI(Mant_a_DI),
		.Exp_num_DI(Exp_a_DI),
		.Denominator_DI(Mant_b_DI),
		.Exp_den_DI(Exp_b_DI),
		.Div_start_dly_SO(Div_start_dly_S),
		.Sqrt_start_dly_SO(Sqrt_start_dly_S),
		.Div_enable_SO(Div_enable_SO),
		.Sqrt_enable_SO(Sqrt_enable_SO),
		.Full_precision_SO(Full_precision_SO),
		.FP32_SO(FP32_SO),
		.FP64_SO(FP64_SO),
		.FP16_SO(FP16_SO),
		.FP16ALT_SO(FP16ALT_SO),
		.Ready_SO(Ready_SO),
		.Done_SO(Done_SO),
		.Mant_result_prenorm_DO(Mant_z_DO),
		.Exp_result_prenorm_DO(Exp_z_DO)
	);
endmodule
module preprocess_mvp (
	Clk_CI,
	Rst_RBI,
	Div_start_SI,
	Sqrt_start_SI,
	Ready_SI,
	Operand_a_DI,
	Operand_b_DI,
	RM_SI,
	Format_sel_SI,
	Start_SO,
	Exp_a_DO_norm,
	Exp_b_DO_norm,
	Mant_a_DO_norm,
	Mant_b_DO_norm,
	RM_dly_SO,
	Sign_z_DO,
	Inf_a_SO,
	Inf_b_SO,
	Zero_a_SO,
	Zero_b_SO,
	NaN_a_SO,
	NaN_b_SO,
	SNaN_SO,
	Special_case_SBO,
	Special_case_dly_SBO
);
	input wire Clk_CI;
	input wire Rst_RBI;
	input wire Div_start_SI;
	input wire Sqrt_start_SI;
	input wire Ready_SI;
	localparam defs_div_sqrt_mvp_C_OP_FP64 = 64;
	input wire [63:0] Operand_a_DI;
	input wire [63:0] Operand_b_DI;
	localparam defs_div_sqrt_mvp_C_RM = 3;
	input wire [2:0] RM_SI;
	localparam defs_div_sqrt_mvp_C_FS = 2;
	input wire [1:0] Format_sel_SI;
	output wire Start_SO;
	localparam defs_div_sqrt_mvp_C_EXP_FP64 = 11;
	output wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_DO_norm;
	output wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_DO_norm;
	localparam defs_div_sqrt_mvp_C_MANT_FP64 = 52;
	output wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_DO_norm;
	output wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_DO_norm;
	output wire [2:0] RM_dly_SO;
	output wire Sign_z_DO;
	output wire Inf_a_SO;
	output wire Inf_b_SO;
	output wire Zero_a_SO;
	output wire Zero_b_SO;
	output wire NaN_a_SO;
	output wire NaN_b_SO;
	output wire SNaN_SO;
	output wire Special_case_SBO;
	output reg Special_case_dly_SBO;
	wire Hb_a_D;
	wire Hb_b_D;
	reg [10:0] Exp_a_D;
	reg [10:0] Exp_b_D;
	reg [51:0] Mant_a_NonH_D;
	reg [51:0] Mant_b_NonH_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_D;
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_D;
	reg Sign_a_D;
	reg Sign_b_D;
	wire Start_S;
	localparam defs_div_sqrt_mvp_C_MANT_FP16 = 10;
	localparam defs_div_sqrt_mvp_C_MANT_FP16ALT = 7;
	localparam defs_div_sqrt_mvp_C_MANT_FP32 = 23;
	localparam defs_div_sqrt_mvp_C_OP_FP16 = 16;
	localparam defs_div_sqrt_mvp_C_OP_FP16ALT = 16;
	localparam defs_div_sqrt_mvp_C_OP_FP32 = 32;
	always @(*)
		case (Format_sel_SI)
			2'b00: begin
				Sign_a_D = Operand_a_DI[31];
				Sign_b_D = Operand_b_DI[31];
				Exp_a_D = {3'h0, Operand_a_DI[30:defs_div_sqrt_mvp_C_MANT_FP32]};
				Exp_b_D = {3'h0, Operand_b_DI[30:defs_div_sqrt_mvp_C_MANT_FP32]};
				Mant_a_NonH_D = {Operand_a_DI[22:0], 29'h00000000};
				Mant_b_NonH_D = {Operand_b_DI[22:0], 29'h00000000};
			end
			2'b01: begin
				Sign_a_D = Operand_a_DI[63];
				Sign_b_D = Operand_b_DI[63];
				Exp_a_D = Operand_a_DI[62:defs_div_sqrt_mvp_C_MANT_FP64];
				Exp_b_D = Operand_b_DI[62:defs_div_sqrt_mvp_C_MANT_FP64];
				Mant_a_NonH_D = Operand_a_DI[51:0];
				Mant_b_NonH_D = Operand_b_DI[51:0];
			end
			2'b10: begin
				Sign_a_D = Operand_a_DI[15];
				Sign_b_D = Operand_b_DI[15];
				Exp_a_D = {6'h00, Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16]};
				Exp_b_D = {6'h00, Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16]};
				Mant_a_NonH_D = {Operand_a_DI[9:0], 42'h00000000000};
				Mant_b_NonH_D = {Operand_b_DI[9:0], 42'h00000000000};
			end
			2'b11: begin
				Sign_a_D = Operand_a_DI[15];
				Sign_b_D = Operand_b_DI[15];
				Exp_a_D = {3'h0, Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT]};
				Exp_b_D = {3'h0, Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT]};
				Mant_a_NonH_D = {Operand_a_DI[6:0], 45'h000000000000};
				Mant_b_NonH_D = {Operand_b_DI[6:0], 45'h000000000000};
			end
		endcase
	assign Mant_a_D = {Hb_a_D, Mant_a_NonH_D};
	assign Mant_b_D = {Hb_b_D, Mant_b_NonH_D};
	assign Hb_a_D = |Exp_a_D;
	assign Hb_b_D = |Exp_b_D;
	assign Start_S = Div_start_SI | Sqrt_start_SI;
	reg Mant_a_prenorm_zero_S;
	reg Mant_b_prenorm_zero_S;
	wire Exp_a_prenorm_zero_S;
	wire Exp_b_prenorm_zero_S;
	assign Exp_a_prenorm_zero_S = ~Hb_a_D;
	assign Exp_b_prenorm_zero_S = ~Hb_b_D;
	reg Exp_a_prenorm_Inf_NaN_S;
	reg Exp_b_prenorm_Inf_NaN_S;
	wire Mant_a_prenorm_QNaN_S;
	wire Mant_a_prenorm_SNaN_S;
	wire Mant_b_prenorm_QNaN_S;
	wire Mant_b_prenorm_SNaN_S;
	assign Mant_a_prenorm_QNaN_S = Mant_a_NonH_D[51] && ~(|Mant_a_NonH_D[50:0]);
	assign Mant_a_prenorm_SNaN_S = ~Mant_a_NonH_D[51] && |Mant_a_NonH_D[50:0];
	assign Mant_b_prenorm_QNaN_S = Mant_b_NonH_D[51] && ~(|Mant_b_NonH_D[50:0]);
	assign Mant_b_prenorm_SNaN_S = ~Mant_b_NonH_D[51] && |Mant_b_NonH_D[50:0];
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP16 = 5'h1f;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP16ALT = 8'hff;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP32 = 8'hff;
	localparam defs_div_sqrt_mvp_C_EXP_INF_FP64 = 11'h7ff;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP16 = 10'h000;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT = 7'h00;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP32 = 23'h000000;
	localparam defs_div_sqrt_mvp_C_MANT_ZERO_FP64 = 52'h0000000000000;
	always @(*)
		case (Format_sel_SI)
			2'b00: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[22:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP32;
				Mant_b_prenorm_zero_S = Operand_b_DI[22:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP32;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[30:defs_div_sqrt_mvp_C_MANT_FP32] == defs_div_sqrt_mvp_C_EXP_INF_FP32;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[30:defs_div_sqrt_mvp_C_MANT_FP32] == defs_div_sqrt_mvp_C_EXP_INF_FP32;
			end
			2'b01: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[51:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP64;
				Mant_b_prenorm_zero_S = Operand_b_DI[51:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP64;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[62:defs_div_sqrt_mvp_C_MANT_FP64] == defs_div_sqrt_mvp_C_EXP_INF_FP64;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[62:defs_div_sqrt_mvp_C_MANT_FP64] == defs_div_sqrt_mvp_C_EXP_INF_FP64;
			end
			2'b10: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[9:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16;
				Mant_b_prenorm_zero_S = Operand_b_DI[9:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16] == defs_div_sqrt_mvp_C_EXP_INF_FP16;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16] == defs_div_sqrt_mvp_C_EXP_INF_FP16;
			end
			2'b11: begin
				Mant_a_prenorm_zero_S = Operand_a_DI[6:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT;
				Mant_b_prenorm_zero_S = Operand_b_DI[6:0] == defs_div_sqrt_mvp_C_MANT_ZERO_FP16ALT;
				Exp_a_prenorm_Inf_NaN_S = Operand_a_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT] == defs_div_sqrt_mvp_C_EXP_INF_FP16ALT;
				Exp_b_prenorm_Inf_NaN_S = Operand_b_DI[14:defs_div_sqrt_mvp_C_MANT_FP16ALT] == defs_div_sqrt_mvp_C_EXP_INF_FP16ALT;
			end
		endcase
	wire Zero_a_SN;
	reg Zero_a_SP;
	wire Zero_b_SN;
	reg Zero_b_SP;
	wire Inf_a_SN;
	reg Inf_a_SP;
	wire Inf_b_SN;
	reg Inf_b_SP;
	wire NaN_a_SN;
	reg NaN_a_SP;
	wire NaN_b_SN;
	reg NaN_b_SP;
	wire SNaN_SN;
	reg SNaN_SP;
	assign Zero_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_zero_S && Mant_a_prenorm_zero_S : Zero_a_SP);
	assign Zero_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_zero_S && Mant_b_prenorm_zero_S : Zero_b_SP);
	assign Inf_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_Inf_NaN_S && Mant_a_prenorm_zero_S : Inf_a_SP);
	assign Inf_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_Inf_NaN_S && Mant_b_prenorm_zero_S : Inf_b_SP);
	assign NaN_a_SN = (Start_S && Ready_SI ? Exp_a_prenorm_Inf_NaN_S && ~Mant_a_prenorm_zero_S : NaN_a_SP);
	assign NaN_b_SN = (Start_S && Ready_SI ? Exp_b_prenorm_Inf_NaN_S && ~Mant_b_prenorm_zero_S : NaN_b_SP);
	assign SNaN_SN = (Start_S && Ready_SI ? (Mant_a_prenorm_SNaN_S && NaN_a_SN) | (Mant_b_prenorm_SNaN_S && NaN_b_SN) : SNaN_SP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI) begin
			Zero_a_SP <= 1'sb0;
			Zero_b_SP <= 1'sb0;
			Inf_a_SP <= 1'sb0;
			Inf_b_SP <= 1'sb0;
			NaN_a_SP <= 1'sb0;
			NaN_b_SP <= 1'sb0;
			SNaN_SP <= 1'sb0;
		end
		else begin
			Inf_a_SP <= Inf_a_SN;
			Inf_b_SP <= Inf_b_SN;
			Zero_a_SP <= Zero_a_SN;
			Zero_b_SP <= Zero_b_SN;
			NaN_a_SP <= NaN_a_SN;
			NaN_b_SP <= NaN_b_SN;
			SNaN_SP <= SNaN_SN;
		end
	assign Special_case_SBO = ~{(Div_start_SI ? ((((Zero_a_SN | Zero_b_SN) | Inf_a_SN) | Inf_b_SN) | NaN_a_SN) | NaN_b_SN : ((Zero_a_SN | Inf_a_SN) | NaN_a_SN) | Sign_a_D)} && (Start_S && Ready_SI);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Special_case_dly_SBO <= 1'sb0;
		else if (Start_S && Ready_SI)
			Special_case_dly_SBO <= Special_case_SBO;
		else if (Special_case_dly_SBO)
			Special_case_dly_SBO <= 1'b1;
		else
			Special_case_dly_SBO <= 1'sb0;
	reg Sign_z_DN;
	reg Sign_z_DP;
	always @(*)
		if (Div_start_SI && Ready_SI)
			Sign_z_DN = Sign_a_D ^ Sign_b_D;
		else if (Sqrt_start_SI && Ready_SI)
			Sign_z_DN = Sign_a_D;
		else
			Sign_z_DN = Sign_z_DP;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Sign_z_DP <= 1'sb0;
		else
			Sign_z_DP <= Sign_z_DN;
	reg [2:0] RM_DN;
	reg [2:0] RM_DP;
	always @(*)
		if (Start_S && Ready_SI)
			RM_DN = RM_SI;
		else
			RM_DN = RM_DP;
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			RM_DP <= 1'sb0;
		else
			RM_DP <= RM_DN;
	assign RM_dly_SO = RM_DP;
	wire [5:0] Mant_leadingOne_a;
	wire [5:0] Mant_leadingOne_b;
	wire Mant_zero_S_a;
	wire Mant_zero_S_b;
	lzc #(
		.WIDTH(53),
		.MODE(1)
	) LOD_Ua(
		.in_i(Mant_a_D),
		.cnt_o(Mant_leadingOne_a),
		.empty_o(Mant_zero_S_a)
	);
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_norm_DN;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_a_norm_DP;
	assign Mant_a_norm_DN = (Start_S && Ready_SI ? Mant_a_D << Mant_leadingOne_a : Mant_a_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Mant_a_norm_DP <= 1'sb0;
		else
			Mant_a_norm_DP <= Mant_a_norm_DN;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_norm_DN;
	reg [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_a_norm_DP;
	assign Exp_a_norm_DN = (Start_S && Ready_SI ? (Exp_a_D - Mant_leadingOne_a) + |Mant_leadingOne_a : Exp_a_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_a_norm_DP <= 1'sb0;
		else
			Exp_a_norm_DP <= Exp_a_norm_DN;
	lzc #(
		.WIDTH(53),
		.MODE(1)
	) LOD_Ub(
		.in_i(Mant_b_D),
		.cnt_o(Mant_leadingOne_b),
		.empty_o(Mant_zero_S_b)
	);
	wire [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_norm_DN;
	reg [defs_div_sqrt_mvp_C_MANT_FP64:0] Mant_b_norm_DP;
	assign Mant_b_norm_DN = (Start_S && Ready_SI ? Mant_b_D << Mant_leadingOne_b : Mant_b_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Mant_b_norm_DP <= 1'sb0;
		else
			Mant_b_norm_DP <= Mant_b_norm_DN;
	wire [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_norm_DN;
	reg [defs_div_sqrt_mvp_C_EXP_FP64:0] Exp_b_norm_DP;
	assign Exp_b_norm_DN = (Start_S && Ready_SI ? (Exp_b_D - Mant_leadingOne_b) + |Mant_leadingOne_b : Exp_b_norm_DP);
	always @(posedge Clk_CI or negedge Rst_RBI)
		if (~Rst_RBI)
			Exp_b_norm_DP <= 1'sb0;
		else
			Exp_b_norm_DP <= Exp_b_norm_DN;
	assign Start_SO = Start_S;
	assign Exp_a_DO_norm = Exp_a_norm_DP;
	assign Exp_b_DO_norm = Exp_b_norm_DP;
	assign Mant_a_DO_norm = Mant_a_norm_DP;
	assign Mant_b_DO_norm = Mant_b_norm_DP;
	assign Sign_z_DO = Sign_z_DP;
	assign Inf_a_SO = Inf_a_SP;
	assign Inf_b_SO = Inf_b_SP;
	assign Zero_a_SO = Zero_a_SP;
	assign Zero_b_SO = Zero_b_SP;
	assign NaN_a_SO = NaN_a_SP;
	assign NaN_b_SO = NaN_b_SP;
	assign SNaN_SO = SNaN_SP;
endmodule
module fpnew_cast_multi_BB75A_A18A7 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter [31:0] AuxType_AUX_BITS = 0;
	parameter signed [31:0] TagType_TagType_TagType_TagType_TAG_WIDTH = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	parameter [0:4] FpFmtConfig = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtConfig = 1'sb1;
	parameter [31:0] NumPipeRegs = 0;
	parameter [1:0] PipeConfig = 2'd0;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [2:0] sv2v_cast_31CED;
		input reg [2:0] inp;
		sv2v_cast_31CED = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:4] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_31CED(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	function automatic [1:0] sv2v_cast_179A3;
		input reg [1:0] inp;
		sv2v_cast_179A3 = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_int_width;
		input reg [1:0] ifmt;
		case (ifmt)
			sv2v_cast_179A3(0): fpnew_pkg_int_width = 8;
			sv2v_cast_179A3(1): fpnew_pkg_int_width = 16;
			sv2v_cast_179A3(2): fpnew_pkg_int_width = 32;
			sv2v_cast_179A3(3): fpnew_pkg_int_width = 64;
			default: begin
				fpnew_pkg_int_width = sv2v_cast_179A3(0);
			end
		endcase
	endfunction
	function automatic [31:0] fpnew_pkg_max_int_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_2
				reg signed [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					if (cfg[ifmt])
						res = fpnew_pkg_maximum(res, fpnew_pkg_int_width(sv2v_cast_179A3(ifmt)));
			end
			fpnew_pkg_max_int_width = res;
		end
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_maximum(fpnew_pkg_max_fp_width(FpFmtConfig), fpnew_pkg_max_int_width(IntFmtConfig));
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [WIDTH - 1:0] operands_i;
	input wire [4:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire [2:0] src_fmt_i;
	input wire [2:0] dst_fmt_i;
	input wire [1:0] int_fmt_i;
	input wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire [AuxType_AUX_BITS - 1:0] aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire [AuxType_AUX_BITS - 1:0] aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [31:0] NUM_INT_FORMATS = fpnew_pkg_NUM_INT_FORMATS;
	localparam [31:0] MAX_INT_WIDTH = fpnew_pkg_max_int_width(IntFmtConfig);
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [2:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32];
	endfunction
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [2:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32];
	endfunction
	function automatic [63:0] fpnew_pkg_super_format;
		input reg [0:4] cfg;
		reg [63:0] res;
		begin
			res = 1'sb0;
			begin : sv2v_autoblock_3
				reg [31:0] fmt;
				for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
					if (cfg[fmt]) begin
						res[63-:32] = $unsigned(fpnew_pkg_maximum(res[63-:32], fpnew_pkg_exp_bits(sv2v_cast_31CED(fmt))));
						res[31-:32] = $unsigned(fpnew_pkg_maximum(res[31-:32], fpnew_pkg_man_bits(sv2v_cast_31CED(fmt))));
					end
			end
			fpnew_pkg_super_format = res;
		end
	endfunction
	localparam [63:0] SUPER_FORMAT = fpnew_pkg_super_format(FpFmtConfig);
	localparam [31:0] SUPER_EXP_BITS = SUPER_FORMAT[63-:32];
	localparam [31:0] SUPER_MAN_BITS = SUPER_FORMAT[31-:32];
	localparam [31:0] SUPER_BIAS = (2 ** (SUPER_EXP_BITS - 1)) - 1;
	localparam [31:0] INT_MAN_WIDTH = fpnew_pkg_maximum(SUPER_MAN_BITS + 1, MAX_INT_WIDTH);
	localparam [31:0] LZC_RESULT_WIDTH = $clog2(INT_MAN_WIDTH);
	localparam [31:0] INT_EXP_WIDTH = fpnew_pkg_maximum($clog2(MAX_INT_WIDTH), fpnew_pkg_maximum(SUPER_EXP_BITS, $clog2(SUPER_BIAS + SUPER_MAN_BITS))) + 1;
	localparam NUM_INP_REGS = (PipeConfig == 2'd0 ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 1) / 3 : 0));
	localparam NUM_MID_REGS = (PipeConfig == 2'd2 ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 2) / 3 : 0));
	localparam NUM_OUT_REGS = (PipeConfig == 2'd1 ? NumPipeRegs : (PipeConfig == 2'd3 ? NumPipeRegs / 3 : 0));
	wire [WIDTH - 1:0] operands_q;
	wire [4:0] is_boxed_q;
	wire op_mod_q;
	wire [2:0] src_fmt_q;
	wire [2:0] dst_fmt_q;
	wire [1:0] int_fmt_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * WIDTH) + ((NUM_INP_REGS * WIDTH) - 1) : ((NUM_INP_REGS + 1) * WIDTH) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * WIDTH : 0)] inp_pipe_operands_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0)] inp_pipe_is_boxed_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	reg [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_src_fmt_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_dst_fmt_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_INT_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_INT_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_INT_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_INT_FORMAT_BITS : 0)] inp_pipe_int_fmt_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_INP_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] inp_pipe_tag_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * AuxType_AUX_BITS) + ((NUM_INP_REGS * AuxType_AUX_BITS) - 1) : ((NUM_INP_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * AuxType_AUX_BITS : 0)] inp_pipe_aux_q;
	reg [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	wire [WIDTH * 1:1] sv2v_tmp_6E45B;
	assign sv2v_tmp_6E45B = operands_i;
	always @(*) inp_pipe_operands_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * WIDTH+:WIDTH] = sv2v_tmp_6E45B;
	wire [5:1] sv2v_tmp_C47E1;
	assign sv2v_tmp_C47E1 = is_boxed_i;
	always @(*) inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS+:NUM_FORMATS] = sv2v_tmp_C47E1;
	wire [3:1] sv2v_tmp_45ED9;
	assign sv2v_tmp_45ED9 = rnd_mode_i;
	always @(*) inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = sv2v_tmp_45ED9;
	wire [4:1] sv2v_tmp_AD1FB;
	assign sv2v_tmp_AD1FB = op_i;
	always @(*) inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = sv2v_tmp_AD1FB;
	wire [1:1] sv2v_tmp_D1C37;
	assign sv2v_tmp_D1C37 = op_mod_i;
	always @(*) inp_pipe_op_mod_q[0] = sv2v_tmp_D1C37;
	wire [3:1] sv2v_tmp_CB295;
	assign sv2v_tmp_CB295 = src_fmt_i;
	always @(*) inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_CB295;
	wire [3:1] sv2v_tmp_6AF63;
	assign sv2v_tmp_6AF63 = dst_fmt_i;
	always @(*) inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_6AF63;
	wire [2:1] sv2v_tmp_CA55F;
	assign sv2v_tmp_CA55F = int_fmt_i;
	always @(*) inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] = sv2v_tmp_CA55F;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_18FC5;
	assign sv2v_tmp_18FC5 = tag_i;
	always @(*) inp_pipe_tag_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_18FC5;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_D4403;
	assign sv2v_tmp_D4403 = aux_i;
	always @(*) inp_pipe_aux_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_D4403;
	wire [1:1] sv2v_tmp_73AEA;
	assign sv2v_tmp_73AEA = in_valid_i;
	always @(*) inp_pipe_valid_q[0] = sv2v_tmp_73AEA;
	assign in_ready_o = inp_pipe_ready[0];
	genvar i;
	function automatic [3:0] sv2v_cast_70E1D;
		input reg [3:0] inp;
		sv2v_cast_70E1D = inp;
	endfunction
	function automatic [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] sv2v_cast_DF2F6;
		input reg [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] inp;
		sv2v_cast_DF2F6 = inp;
	endfunction
	function automatic [AuxType_AUX_BITS - 1:0] sv2v_cast_48620;
		input reg [AuxType_AUX_BITS - 1:0] inp;
		sv2v_cast_48620 = inp;
	endfunction
	generate
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_valid_q[i + 1] <= 1'b0;
				else
					inp_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (inp_pipe_ready[i] ? inp_pipe_valid_q[i] : inp_pipe_valid_q[i + 1]));
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_operands_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * WIDTH+:WIDTH] <= 1'sb0;
				else
					inp_pipe_operands_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * WIDTH+:WIDTH] <= (reg_ena ? inp_pipe_operands_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * WIDTH+:WIDTH] : inp_pipe_operands_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * WIDTH+:WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS+:NUM_FORMATS] <= 1'sb0;
				else
					inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS+:NUM_FORMATS] <= (reg_ena ? inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * NUM_FORMATS+:NUM_FORMATS] : inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS+:NUM_FORMATS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= (reg_ena ? inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3+:3] : inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= sv2v_cast_70E1D(0);
				else
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= (reg_ena ? inp_pipe_op_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] : inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_mod_q[i + 1] <= 1'sb0;
				else
					inp_pipe_op_mod_q[i + 1] <= (reg_ena ? inp_pipe_op_mod_q[i] : inp_pipe_op_mod_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_31CED(0);
				else
					inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_31CED(0);
				else
					inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] <= sv2v_cast_179A3(0);
				else
					inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] <= (reg_ena ? inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] : inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_DF2F6(1'sb0);
				else
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_48620(1'sb0);
				else
					inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign operands_q = inp_pipe_operands_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * WIDTH+:WIDTH];
	assign is_boxed_q = inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * NUM_FORMATS+:NUM_FORMATS];
	assign op_mod_q = inp_pipe_op_mod_q[NUM_INP_REGS];
	assign src_fmt_q = inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign dst_fmt_q = inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign int_fmt_q = inp_pipe_int_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS];
	wire src_is_int;
	wire dst_is_int;
	assign src_is_int = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] == sv2v_cast_70E1D(12);
	assign dst_is_int = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] == sv2v_cast_70E1D(11);
	wire [INT_MAN_WIDTH - 1:0] encoded_mant;
	wire [4:0] fmt_sign;
	wire signed [(NUM_FORMATS * INT_EXP_WIDTH) - 1:0] fmt_exponent;
	wire [(NUM_FORMATS * INT_MAN_WIDTH) - 1:0] fmt_mantissa;
	wire signed [(NUM_FORMATS * INT_EXP_WIDTH) - 1:0] fmt_shift_compensation;
	wire [39:0] info;
	reg [(NUM_INT_FORMATS * INT_MAN_WIDTH) - 1:0] ifmt_input_val;
	wire int_sign;
	wire [INT_MAN_WIDTH - 1:0] int_value;
	wire [INT_MAN_WIDTH - 1:0] int_mantissa;
	genvar fmt;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	function automatic signed [0:0] sv2v_cast_1_signed;
		input reg signed [0:0] inp;
		sv2v_cast_1_signed = inp;
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : fmt_init_inputs
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_31CED(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_31CED(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_31CED(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				fpnew_classifier #(
					.FpFormat(sv2v_cast_31CED(fmt)),
					.NumOperands(1)
				) i_fpnew_classifier(
					.operands_i(operands_q[FP_WIDTH - 1:0]),
					.is_boxed_i(is_boxed_q[fmt]),
					.info_o(info[fmt * 8+:8])
				);
				assign fmt_sign[fmt] = operands_q[FP_WIDTH - 1];
				assign fmt_exponent[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = $signed({1'b0, operands_q[MAN_BITS+:EXP_BITS]});
				assign fmt_mantissa[fmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = {info[(fmt * 8) + 7], operands_q[MAN_BITS - 1:0]};
				assign fmt_shift_compensation[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = $signed((INT_MAN_WIDTH - 1) - MAN_BITS);
			end
			else begin : inactive_format
				assign info[fmt * 8+:8] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_sign[fmt] = fpnew_pkg_DONT_CARE;
				assign fmt_exponent[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = {INT_EXP_WIDTH {sv2v_cast_1_signed(fpnew_pkg_DONT_CARE)}};
				assign fmt_mantissa[fmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = {INT_MAN_WIDTH {fpnew_pkg_DONT_CARE}};
				assign fmt_shift_compensation[fmt * INT_EXP_WIDTH+:INT_EXP_WIDTH] = {INT_EXP_WIDTH {sv2v_cast_1_signed(fpnew_pkg_DONT_CARE)}};
			end
		end
	endgenerate
	genvar ifmt;
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	generate
		for (ifmt = 0; ifmt < sv2v_cast_32_signed(NUM_INT_FORMATS); ifmt = ifmt + 1) begin : gen_sign_extend_int
			localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_179A3(ifmt));
			if (IntFmtConfig[ifmt]) begin : active_format
				always @(*) begin : sign_ext_input
					ifmt_input_val[ifmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = {INT_MAN_WIDTH {sv2v_cast_1(operands_q[INT_WIDTH - 1] & ~op_mod_q)}};
					ifmt_input_val[(ifmt * INT_MAN_WIDTH) + (INT_WIDTH - 1)-:INT_WIDTH] = operands_q[INT_WIDTH - 1:0];
				end
			end
			else begin : inactive_format
				wire [INT_MAN_WIDTH * 1:1] sv2v_tmp_5B946;
				assign sv2v_tmp_5B946 = {INT_MAN_WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) ifmt_input_val[ifmt * INT_MAN_WIDTH+:INT_MAN_WIDTH] = sv2v_tmp_5B946;
			end
		end
	endgenerate
	assign int_value = ifmt_input_val[int_fmt_q * INT_MAN_WIDTH+:INT_MAN_WIDTH];
	assign int_sign = int_value[INT_MAN_WIDTH - 1] & ~op_mod_q;
	assign int_mantissa = (int_sign ? $unsigned(-int_value) : int_value);
	assign encoded_mant = (src_is_int ? int_mantissa : fmt_mantissa[src_fmt_q * INT_MAN_WIDTH+:INT_MAN_WIDTH]);
	wire signed [INT_EXP_WIDTH - 1:0] src_bias;
	wire signed [INT_EXP_WIDTH - 1:0] src_exp;
	wire signed [INT_EXP_WIDTH - 1:0] src_subnormal;
	wire signed [INT_EXP_WIDTH - 1:0] src_offset;
	function automatic [31:0] fpnew_pkg_bias;
		input reg [2:0] fmt;
		fpnew_pkg_bias = $unsigned((2 ** (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] - 1)) - 1);
	endfunction
	assign src_bias = $signed(fpnew_pkg_bias(src_fmt_q));
	assign src_exp = fmt_exponent[src_fmt_q * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	assign src_subnormal = $signed({1'b0, info[(src_fmt_q * 8) + 6]});
	assign src_offset = fmt_shift_compensation[src_fmt_q * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	wire input_sign;
	wire signed [INT_EXP_WIDTH - 1:0] input_exp;
	wire [INT_MAN_WIDTH - 1:0] input_mant;
	wire mant_is_zero;
	wire signed [INT_EXP_WIDTH - 1:0] fp_input_exp;
	wire signed [INT_EXP_WIDTH - 1:0] int_input_exp;
	wire [LZC_RESULT_WIDTH - 1:0] renorm_shamt;
	wire [LZC_RESULT_WIDTH:0] renorm_shamt_sgn;
	lzc #(
		.WIDTH(INT_MAN_WIDTH),
		.MODE(1)
	) i_lzc(
		.in_i(encoded_mant),
		.cnt_o(renorm_shamt),
		.empty_o(mant_is_zero)
	);
	assign renorm_shamt_sgn = $signed({1'b0, renorm_shamt});
	assign input_sign = (src_is_int ? int_sign : fmt_sign[src_fmt_q]);
	assign input_mant = encoded_mant << renorm_shamt;
	assign fp_input_exp = $signed((((src_exp + src_subnormal) - src_bias) - renorm_shamt_sgn) + src_offset);
	assign int_input_exp = $signed((INT_MAN_WIDTH - 1) - renorm_shamt_sgn);
	assign input_exp = (src_is_int ? int_input_exp : fp_input_exp);
	wire signed [INT_EXP_WIDTH - 1:0] destination_exp;
	assign destination_exp = input_exp + $signed(fpnew_pkg_bias(dst_fmt_q));
	wire input_sign_q;
	wire signed [INT_EXP_WIDTH - 1:0] input_exp_q;
	wire [INT_MAN_WIDTH - 1:0] input_mant_q;
	wire signed [INT_EXP_WIDTH - 1:0] destination_exp_q;
	wire src_is_int_q;
	wire dst_is_int_q;
	wire [7:0] info_q;
	wire mant_is_zero_q;
	wire op_mod_q2;
	wire [2:0] rnd_mode_q;
	wire [2:0] src_fmt_q2;
	wire [2:0] dst_fmt_q2;
	wire [1:0] int_fmt_q2;
	reg [0:NUM_MID_REGS] mid_pipe_input_sign_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * INT_EXP_WIDTH) + ((NUM_MID_REGS * INT_EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * INT_EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * INT_EXP_WIDTH : 0)] mid_pipe_input_exp_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * INT_MAN_WIDTH) + ((NUM_MID_REGS * INT_MAN_WIDTH) - 1) : ((NUM_MID_REGS + 1) * INT_MAN_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * INT_MAN_WIDTH : 0)] mid_pipe_input_mant_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * INT_EXP_WIDTH) + ((NUM_MID_REGS * INT_EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * INT_EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * INT_EXP_WIDTH : 0)] mid_pipe_dest_exp_q;
	reg [0:NUM_MID_REGS] mid_pipe_src_is_int_q;
	reg [0:NUM_MID_REGS] mid_pipe_dst_is_int_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 8) + ((NUM_MID_REGS * 8) - 1) : ((NUM_MID_REGS + 1) * 8) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 8 : 0)] mid_pipe_info_q;
	reg [0:NUM_MID_REGS] mid_pipe_mant_zero_q;
	reg [0:NUM_MID_REGS] mid_pipe_op_mod_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 3) + ((NUM_MID_REGS * 3) - 1) : ((NUM_MID_REGS + 1) * 3) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 3 : 0)] mid_pipe_rnd_mode_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] mid_pipe_src_fmt_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] mid_pipe_dst_fmt_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_INT_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_INT_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_INT_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_INT_FORMAT_BITS : 0)] mid_pipe_int_fmt_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_MID_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_MID_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] mid_pipe_tag_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * AuxType_AUX_BITS) + ((NUM_MID_REGS * AuxType_AUX_BITS) - 1) : ((NUM_MID_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * AuxType_AUX_BITS : 0)] mid_pipe_aux_q;
	reg [0:NUM_MID_REGS] mid_pipe_valid_q;
	wire [0:NUM_MID_REGS] mid_pipe_ready;
	wire [1:1] sv2v_tmp_3DFAC;
	assign sv2v_tmp_3DFAC = input_sign;
	always @(*) mid_pipe_input_sign_q[0] = sv2v_tmp_3DFAC;
	wire [INT_EXP_WIDTH * 1:1] sv2v_tmp_9AB08;
	assign sv2v_tmp_9AB08 = input_exp;
	always @(*) mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH] = sv2v_tmp_9AB08;
	wire [INT_MAN_WIDTH * 1:1] sv2v_tmp_3BE44;
	assign sv2v_tmp_3BE44 = input_mant;
	always @(*) mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * INT_MAN_WIDTH+:INT_MAN_WIDTH] = sv2v_tmp_3BE44;
	wire [INT_EXP_WIDTH * 1:1] sv2v_tmp_F626F;
	assign sv2v_tmp_F626F = destination_exp;
	always @(*) mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH] = sv2v_tmp_F626F;
	wire [1:1] sv2v_tmp_3D9F8;
	assign sv2v_tmp_3D9F8 = src_is_int;
	always @(*) mid_pipe_src_is_int_q[0] = sv2v_tmp_3D9F8;
	wire [1:1] sv2v_tmp_4E95C;
	assign sv2v_tmp_4E95C = dst_is_int;
	always @(*) mid_pipe_dst_is_int_q[0] = sv2v_tmp_4E95C;
	wire [8:1] sv2v_tmp_48E57;
	assign sv2v_tmp_48E57 = info[src_fmt_q * 8+:8];
	always @(*) mid_pipe_info_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 8+:8] = sv2v_tmp_48E57;
	wire [1:1] sv2v_tmp_4351A;
	assign sv2v_tmp_4351A = mant_is_zero;
	always @(*) mid_pipe_mant_zero_q[0] = sv2v_tmp_4351A;
	wire [1:1] sv2v_tmp_88AB6;
	assign sv2v_tmp_88AB6 = op_mod_q;
	always @(*) mid_pipe_op_mod_q[0] = sv2v_tmp_88AB6;
	wire [3:1] sv2v_tmp_32E16;
	assign sv2v_tmp_32E16 = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	always @(*) mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 3+:3] = sv2v_tmp_32E16;
	wire [3:1] sv2v_tmp_DE9EA;
	assign sv2v_tmp_DE9EA = src_fmt_q;
	always @(*) mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_DE9EA;
	wire [3:1] sv2v_tmp_FC1E4;
	assign sv2v_tmp_FC1E4 = dst_fmt_q;
	always @(*) mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_FC1E4;
	wire [2:1] sv2v_tmp_2AE08;
	assign sv2v_tmp_2AE08 = int_fmt_q;
	always @(*) mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] = sv2v_tmp_2AE08;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_B46A2;
	assign sv2v_tmp_B46A2 = inp_pipe_tag_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	always @(*) mid_pipe_tag_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_B46A2;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_C23AE;
	assign sv2v_tmp_C23AE = inp_pipe_aux_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	always @(*) mid_pipe_aux_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_C23AE;
	wire [1:1] sv2v_tmp_CB10A;
	assign sv2v_tmp_CB10A = inp_pipe_valid_q[NUM_INP_REGS];
	always @(*) mid_pipe_valid_q[0] = sv2v_tmp_CB10A;
	assign inp_pipe_ready[NUM_INP_REGS] = mid_pipe_ready[0];
	generate
		for (i = 0; i < NUM_MID_REGS; i = i + 1) begin : gen_inside_pipeline
			wire reg_ena;
			assign mid_pipe_ready[i] = mid_pipe_ready[i + 1] | ~mid_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_valid_q[i + 1] <= 1'b0;
				else
					mid_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (mid_pipe_ready[i] ? mid_pipe_valid_q[i] : mid_pipe_valid_q[i + 1]));
			assign reg_ena = mid_pipe_ready[i] & mid_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_input_sign_q[i + 1] <= 1'sb0;
				else
					mid_pipe_input_sign_q[i + 1] <= (reg_ena ? mid_pipe_input_sign_q[i] : mid_pipe_input_sign_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_EXP_WIDTH+:INT_EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_EXP_WIDTH+:INT_EXP_WIDTH] <= (reg_ena ? mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * INT_EXP_WIDTH+:INT_EXP_WIDTH] : mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_EXP_WIDTH+:INT_EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_MAN_WIDTH+:INT_MAN_WIDTH] <= 1'sb0;
				else
					mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_MAN_WIDTH+:INT_MAN_WIDTH] <= (reg_ena ? mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * INT_MAN_WIDTH+:INT_MAN_WIDTH] : mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_MAN_WIDTH+:INT_MAN_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_EXP_WIDTH+:INT_EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_EXP_WIDTH+:INT_EXP_WIDTH] <= (reg_ena ? mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * INT_EXP_WIDTH+:INT_EXP_WIDTH] : mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * INT_EXP_WIDTH+:INT_EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_src_is_int_q[i + 1] <= 1'sb0;
				else
					mid_pipe_src_is_int_q[i + 1] <= (reg_ena ? mid_pipe_src_is_int_q[i] : mid_pipe_src_is_int_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_dst_is_int_q[i + 1] <= 1'sb0;
				else
					mid_pipe_dst_is_int_q[i + 1] <= (reg_ena ? mid_pipe_dst_is_int_q[i] : mid_pipe_dst_is_int_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_info_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 8+:8] <= 1'sb0;
				else
					mid_pipe_info_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 8+:8] <= (reg_ena ? mid_pipe_info_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * 8+:8] : mid_pipe_info_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 8+:8]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_mant_zero_q[i + 1] <= 1'sb0;
				else
					mid_pipe_mant_zero_q[i + 1] <= (reg_ena ? mid_pipe_mant_zero_q[i] : mid_pipe_mant_zero_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_op_mod_q[i + 1] <= 1'sb0;
				else
					mid_pipe_op_mod_q[i + 1] <= (reg_ena ? mid_pipe_op_mod_q[i] : mid_pipe_op_mod_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3] <= (reg_ena ? mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * 3+:3] : mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_31CED(0);
				else
					mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_31CED(0);
				else
					mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] <= sv2v_cast_179A3(0);
				else
					mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] <= (reg_ena ? mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS] : mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_DF2F6(1'sb0);
				else
					mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_48620(1'sb0);
				else
					mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign input_sign_q = mid_pipe_input_sign_q[NUM_MID_REGS];
	assign input_exp_q = mid_pipe_input_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	assign input_mant_q = mid_pipe_input_mant_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * INT_MAN_WIDTH+:INT_MAN_WIDTH];
	assign destination_exp_q = mid_pipe_dest_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * INT_EXP_WIDTH+:INT_EXP_WIDTH];
	assign src_is_int_q = mid_pipe_src_is_int_q[NUM_MID_REGS];
	assign dst_is_int_q = mid_pipe_dst_is_int_q[NUM_MID_REGS];
	assign info_q = mid_pipe_info_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 8+:8];
	assign mant_is_zero_q = mid_pipe_mant_zero_q[NUM_MID_REGS];
	assign op_mod_q2 = mid_pipe_op_mod_q[NUM_MID_REGS];
	assign rnd_mode_q = mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 3+:3];
	assign src_fmt_q2 = mid_pipe_src_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign dst_fmt_q2 = mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign int_fmt_q2 = mid_pipe_int_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_INT_FORMAT_BITS+:fpnew_pkg_INT_FORMAT_BITS];
	reg [INT_EXP_WIDTH - 1:0] final_exp;
	reg [2 * INT_MAN_WIDTH:0] preshift_mant;
	wire [2 * INT_MAN_WIDTH:0] destination_mant;
	wire [SUPER_MAN_BITS - 1:0] final_mant;
	wire [MAX_INT_WIDTH - 1:0] final_int;
	reg [$clog2(INT_MAN_WIDTH + 1) - 1:0] denorm_shamt;
	wire [1:0] fp_round_sticky_bits;
	wire [1:0] int_round_sticky_bits;
	wire [1:0] round_sticky_bits;
	reg of_before_round;
	reg uf_before_round;
	always @(*) begin : cast_value
		final_exp = $unsigned(destination_exp_q);
		preshift_mant = 1'sb0;
		denorm_shamt = SUPER_MAN_BITS - fpnew_pkg_man_bits(dst_fmt_q2);
		of_before_round = 1'b0;
		uf_before_round = 1'b0;
		preshift_mant = input_mant_q << (INT_MAN_WIDTH + 1);
		if (dst_is_int_q) begin
			denorm_shamt = $unsigned((MAX_INT_WIDTH - 1) - input_exp_q);
			if (input_exp_q >= $signed((fpnew_pkg_int_width(int_fmt_q2) - 1) + op_mod_q2)) begin
				denorm_shamt = 1'sb0;
				of_before_round = 1'b1;
			end
			else if (input_exp_q < -1) begin
				denorm_shamt = MAX_INT_WIDTH + 1;
				uf_before_round = 1'b1;
			end
		end
		else if ((destination_exp_q >= ($signed(2 ** fpnew_pkg_exp_bits(dst_fmt_q2)) - 1)) || (~src_is_int_q && info_q[4])) begin
			final_exp = $unsigned((2 ** fpnew_pkg_exp_bits(dst_fmt_q2)) - 2);
			preshift_mant = 1'sb1;
			of_before_round = 1'b1;
		end
		else if ((destination_exp_q < 1) && (destination_exp_q >= -$signed(fpnew_pkg_man_bits(dst_fmt_q2)))) begin
			final_exp = 1'sb0;
			denorm_shamt = $unsigned((denorm_shamt + 1) - destination_exp_q);
			uf_before_round = 1'b1;
		end
		else if (destination_exp_q < -$signed(fpnew_pkg_man_bits(dst_fmt_q2))) begin
			final_exp = 1'sb0;
			denorm_shamt = $unsigned((denorm_shamt + 2) + fpnew_pkg_man_bits(dst_fmt_q2));
			uf_before_round = 1'b1;
		end
	end
	localparam NUM_FP_STICKY = ((2 * INT_MAN_WIDTH) - SUPER_MAN_BITS) - 1;
	localparam NUM_INT_STICKY = (2 * INT_MAN_WIDTH) - MAX_INT_WIDTH;
	assign destination_mant = preshift_mant >> denorm_shamt;
	assign {final_mant, fp_round_sticky_bits[1]} = destination_mant[(2 * INT_MAN_WIDTH) - 1-:SUPER_MAN_BITS + 1];
	assign {final_int, int_round_sticky_bits[1]} = destination_mant[2 * INT_MAN_WIDTH-:MAX_INT_WIDTH + 1];
	assign fp_round_sticky_bits[0] = |{destination_mant[NUM_FP_STICKY - 1:0]};
	assign int_round_sticky_bits[0] = |{destination_mant[NUM_INT_STICKY - 1:0]};
	assign round_sticky_bits = (dst_is_int_q ? int_round_sticky_bits : fp_round_sticky_bits);
	wire [WIDTH - 1:0] pre_round_abs;
	wire of_after_round;
	wire uf_after_round;
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_pre_round_abs;
	reg [4:0] fmt_of_after_round;
	reg [4:0] fmt_uf_after_round;
	reg [(NUM_INT_FORMATS * WIDTH) - 1:0] ifmt_pre_round_abs;
	wire rounded_sign;
	wire [WIDTH - 1:0] rounded_abs;
	wire result_true_zero;
	wire [WIDTH - 1:0] rounded_int_res;
	wire rounded_int_res_zero;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_res_assemble
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_31CED(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_31CED(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : assemble_result
					fmt_pre_round_abs[fmt * WIDTH+:WIDTH] = {final_exp[EXP_BITS - 1:0], final_mant[MAN_BITS - 1:0]};
				end
			end
			else begin : inactive_format
				wire [WIDTH * 1:1] sv2v_tmp_C33E0;
				assign sv2v_tmp_C33E0 = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_pre_round_abs[fmt * WIDTH+:WIDTH] = sv2v_tmp_C33E0;
			end
		end
		for (ifmt = 0; ifmt < sv2v_cast_32_signed(NUM_INT_FORMATS); ifmt = ifmt + 1) begin : gen_int_res_sign_ext
			localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_179A3(ifmt));
			if (IntFmtConfig[ifmt]) begin : active_format
				always @(*) begin : assemble_result
					ifmt_pre_round_abs[ifmt * WIDTH+:WIDTH] = {WIDTH {final_int[INT_WIDTH - 1]}};
					ifmt_pre_round_abs[(ifmt * WIDTH) + (INT_WIDTH - 1)-:INT_WIDTH] = final_int[INT_WIDTH - 1:0];
				end
			end
			else begin : inactive_format
				wire [WIDTH * 1:1] sv2v_tmp_F6FA8;
				assign sv2v_tmp_F6FA8 = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) ifmt_pre_round_abs[ifmt * WIDTH+:WIDTH] = sv2v_tmp_F6FA8;
			end
		end
	endgenerate
	assign pre_round_abs = (dst_is_int_q ? ifmt_pre_round_abs[int_fmt_q2 * WIDTH+:WIDTH] : fmt_pre_round_abs[dst_fmt_q2 * WIDTH+:WIDTH]);
	fpnew_rounding #(.AbsWidth(WIDTH)) i_fpnew_rounding(
		.abs_value_i(pre_round_abs),
		.sign_i(input_sign_q),
		.round_sticky_bits_i(round_sticky_bits),
		.rnd_mode_i(rnd_mode_q),
		.effective_subtraction_i(1'b0),
		.abs_rounded_o(rounded_abs),
		.sign_o(rounded_sign),
		.exact_zero_o(result_true_zero)
	);
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_result;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_sign_inject
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_31CED(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_31CED(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_31CED(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : post_process
					fmt_uf_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) * 1 {1'sb0}};
					fmt_of_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) * 1 {1'sb1}};
					fmt_result[fmt * WIDTH+:WIDTH] = 1'sb1;
					fmt_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = (src_is_int_q & mant_is_zero_q ? {FP_WIDTH * 1 {1'sb0}} : {rounded_sign, rounded_abs[(EXP_BITS + MAN_BITS) - 1:0]});
				end
			end
			else begin : inactive_format
				wire [1:1] sv2v_tmp_4A747;
				assign sv2v_tmp_4A747 = fpnew_pkg_DONT_CARE;
				always @(*) fmt_uf_after_round[fmt] = sv2v_tmp_4A747;
				wire [1:1] sv2v_tmp_90681;
				assign sv2v_tmp_90681 = fpnew_pkg_DONT_CARE;
				always @(*) fmt_of_after_round[fmt] = sv2v_tmp_90681;
				wire [WIDTH * 1:1] sv2v_tmp_649FB;
				assign sv2v_tmp_649FB = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_649FB;
			end
		end
	endgenerate
	assign uf_after_round = fmt_uf_after_round[dst_fmt_q2];
	assign of_after_round = fmt_of_after_round[dst_fmt_q2];
	assign rounded_int_res = (rounded_sign ? $unsigned(-rounded_abs) : rounded_abs);
	assign rounded_int_res_zero = rounded_int_res == {WIDTH {1'sb0}};
	wire [WIDTH - 1:0] fp_special_result;
	wire [4:0] fp_special_status;
	wire fp_result_is_special;
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_special_result;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_special_results
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_31CED(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_31CED(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_31CED(fmt));
			localparam [EXP_BITS - 1:0] QNAN_EXPONENT = 1'sb1;
			localparam [MAN_BITS - 1:0] QNAN_MANTISSA = 2 ** (MAN_BITS - 1);
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : special_results
					reg [FP_WIDTH - 1:0] special_res;
					special_res = (info_q[5] ? input_sign_q << (FP_WIDTH - 1) : {1'b0, QNAN_EXPONENT, QNAN_MANTISSA});
					fmt_special_result[fmt * WIDTH+:WIDTH] = 1'sb1;
					fmt_special_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = special_res;
				end
			end
			else begin : inactive_format
				wire [WIDTH * 1:1] sv2v_tmp_B718F;
				assign sv2v_tmp_B718F = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_special_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_B718F;
			end
		end
	endgenerate
	assign fp_result_is_special = ~src_is_int_q & ((info_q[5] | info_q[3]) | ~info_q[0]);
	assign fp_special_status = {info_q[2], 1'b0, 1'b0, 1'b0, 1'b0};
	assign fp_special_result = fmt_special_result[dst_fmt_q2 * WIDTH+:WIDTH];
	wire [WIDTH - 1:0] int_special_result;
	wire [4:0] int_special_status;
	wire int_result_is_special;
	reg [(NUM_INT_FORMATS * WIDTH) - 1:0] ifmt_special_result;
	generate
		for (ifmt = 0; ifmt < sv2v_cast_32_signed(NUM_INT_FORMATS); ifmt = ifmt + 1) begin : gen_special_results_int
			localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_179A3(ifmt));
			if (IntFmtConfig[ifmt]) begin : active_format
				always @(*) begin : special_results
					reg [INT_WIDTH - 1:0] special_res;
					special_res[INT_WIDTH - 2:0] = 1'sb1;
					special_res[INT_WIDTH - 1] = op_mod_q2;
					if (input_sign_q && !info_q[3])
						special_res = ~special_res;
					ifmt_special_result[ifmt * WIDTH+:WIDTH] = {WIDTH {special_res[INT_WIDTH - 1]}};
					ifmt_special_result[(ifmt * WIDTH) + (INT_WIDTH - 1)-:INT_WIDTH] = special_res;
				end
			end
			else begin : inactive_format
				wire [WIDTH * 1:1] sv2v_tmp_99B6D;
				assign sv2v_tmp_99B6D = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) ifmt_special_result[ifmt * WIDTH+:WIDTH] = sv2v_tmp_99B6D;
			end
		end
	endgenerate
	assign int_result_is_special = (((info_q[3] | info_q[4]) | of_before_round) | ~info_q[0]) | ((input_sign_q & op_mod_q2) & ~rounded_int_res_zero);
	assign int_special_status = 5'b10000;
	assign int_special_result = ifmt_special_result[int_fmt_q2 * WIDTH+:WIDTH];
	wire [4:0] int_regular_status;
	wire [4:0] fp_regular_status;
	wire [WIDTH - 1:0] fp_result;
	wire [WIDTH - 1:0] int_result;
	wire [4:0] fp_status;
	wire [4:0] int_status;
	assign fp_regular_status[4] = src_is_int_q & (of_before_round | of_after_round);
	assign fp_regular_status[3] = 1'b0;
	assign fp_regular_status[2] = ~src_is_int_q & (~info_q[4] & (of_before_round | of_after_round));
	assign fp_regular_status[1] = uf_after_round & fp_regular_status[0];
	assign fp_regular_status[0] = (src_is_int_q ? |fp_round_sticky_bits : |fp_round_sticky_bits | (~info_q[4] & (of_before_round | of_after_round)));
	assign int_regular_status = {4'b0000, |int_round_sticky_bits};
	assign fp_result = (fp_result_is_special ? fp_special_result : fmt_result[dst_fmt_q2 * WIDTH+:WIDTH]);
	assign fp_status = (fp_result_is_special ? fp_special_status : fp_regular_status);
	assign int_result = (int_result_is_special ? int_special_result : rounded_int_res);
	assign int_status = (int_result_is_special ? int_special_status : int_regular_status);
	wire [WIDTH - 1:0] result_d;
	wire [4:0] status_d;
	wire extension_bit;
	assign result_d = (dst_is_int_q ? int_result : fp_result);
	assign status_d = (dst_is_int_q ? int_status : fp_status);
	assign extension_bit = (dst_is_int_q ? int_result[WIDTH - 1] : 1'b1);
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * WIDTH) + ((NUM_OUT_REGS * WIDTH) - 1) : ((NUM_OUT_REGS + 1) * WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * WIDTH : 0)] out_pipe_result_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	reg [0:NUM_OUT_REGS] out_pipe_ext_bit_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_OUT_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] out_pipe_tag_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * AuxType_AUX_BITS) + ((NUM_OUT_REGS * AuxType_AUX_BITS) - 1) : ((NUM_OUT_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * AuxType_AUX_BITS : 0)] out_pipe_aux_q;
	reg [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	wire [WIDTH * 1:1] sv2v_tmp_4086F;
	assign sv2v_tmp_4086F = result_d;
	always @(*) out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * WIDTH+:WIDTH] = sv2v_tmp_4086F;
	wire [5:1] sv2v_tmp_B7C45;
	assign sv2v_tmp_B7C45 = status_d;
	always @(*) out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = sv2v_tmp_B7C45;
	wire [1:1] sv2v_tmp_8F736;
	assign sv2v_tmp_8F736 = extension_bit;
	always @(*) out_pipe_ext_bit_q[0] = sv2v_tmp_8F736;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_03C65;
	assign sv2v_tmp_03C65 = mid_pipe_tag_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	always @(*) out_pipe_tag_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_03C65;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_14D79;
	assign sv2v_tmp_14D79 = mid_pipe_aux_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	always @(*) out_pipe_aux_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_14D79;
	wire [1:1] sv2v_tmp_25EE6;
	assign sv2v_tmp_25EE6 = mid_pipe_valid_q[NUM_MID_REGS];
	always @(*) out_pipe_valid_q[0] = sv2v_tmp_25EE6;
	assign mid_pipe_ready[NUM_MID_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_valid_q[i + 1] <= 1'b0;
				else
					out_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (out_pipe_ready[i] ? out_pipe_valid_q[i] : out_pipe_valid_q[i + 1]));
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH] <= 1'sb0;
				else
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH] <= (reg_ena ? out_pipe_result_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * WIDTH+:WIDTH] : out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= 1'sb0;
				else
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= (reg_ena ? out_pipe_status_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * 5+:5] : out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_ext_bit_q[i + 1] <= 1'sb0;
				else
					out_pipe_ext_bit_q[i + 1] <= (reg_ena ? out_pipe_ext_bit_q[i] : out_pipe_ext_bit_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_DF2F6(1'sb0);
				else
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_48620(1'sb0);
				else
					out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * WIDTH+:WIDTH];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = out_pipe_ext_bit_q[NUM_OUT_REGS];
	assign tag_o = out_pipe_tag_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	assign aux_o = out_pipe_aux_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, mid_pipe_valid_q, out_pipe_valid_q};
endmodule
module fpnew_classifier (
	operands_i,
	is_boxed_i,
	info_o
);
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	function automatic [2:0] sv2v_cast_C349C;
		input reg [2:0] inp;
		sv2v_cast_C349C = inp;
	endfunction
	parameter [2:0] FpFormat = sv2v_cast_C349C(0);
	parameter [31:0] NumOperands = 1;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_fp_width(FpFormat);
	input wire [(NumOperands * WIDTH) - 1:0] operands_i;
	input wire [NumOperands - 1:0] is_boxed_i;
	output reg [(NumOperands * 8) - 1:0] info_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [2:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32];
	endfunction
	localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [2:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32];
	endfunction
	localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(FpFormat);
	genvar op;
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (op = 0; op < sv2v_cast_32_signed(NumOperands); op = op + 1) begin : gen_num_values
			reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] value;
			reg is_boxed;
			reg is_normal;
			reg is_inf;
			reg is_nan;
			reg is_signalling;
			reg is_quiet;
			reg is_zero;
			reg is_subnormal;
			always @(*) begin : classify_input
				value = operands_i[op * WIDTH+:WIDTH];
				is_boxed = is_boxed_i[op];
				is_normal = (is_boxed && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)] != {((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1) * 1 {1'sb0}})) && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)] != {((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1) * 1 {1'sb1}});
				is_zero = (is_boxed && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1) * 1 {1'sb0}})) && (value[MAN_BITS - 1-:MAN_BITS] == {MAN_BITS * 1 {1'sb0}});
				is_subnormal = (is_boxed && (value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1) * 1 {1'sb0}})) && !is_zero;
				is_inf = is_boxed && ((value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1) * 1 {1'sb1}}) && (value[MAN_BITS - 1-:MAN_BITS] == {MAN_BITS * 1 {1'sb0}}));
				is_nan = !is_boxed || ((value[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)] == {((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1) * 1 {1'sb1}}) && (value[MAN_BITS - 1-:MAN_BITS] != {MAN_BITS * 1 {1'sb0}}));
				is_signalling = (is_boxed && is_nan) && (value[(MAN_BITS - 1) - ((MAN_BITS - 1) - (MAN_BITS - 1))] == 1'b0);
				is_quiet = is_nan && !is_signalling;
				info_o[(op * 8) + 7] = is_normal;
				info_o[(op * 8) + 6] = is_subnormal;
				info_o[(op * 8) + 5] = is_zero;
				info_o[(op * 8) + 4] = is_inf;
				info_o[(op * 8) + 3] = is_nan;
				info_o[(op * 8) + 2] = is_signalling;
				info_o[(op * 8) + 1] = is_quiet;
				info_o[op * 8] = is_boxed;
			end
		end
	endgenerate
endmodule
module fpnew_divsqrt_multi_1A2E7_2C16F (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	dst_fmt_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter [31:0] AuxType_AUX_BITS = 0;
	parameter signed [31:0] TagType_TagType_TagType_TagType_TAG_WIDTH = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	parameter [0:4] FpFmtConfig = 1'sb1;
	parameter [31:0] NumPipeRegs = 0;
	parameter [1:0] PipeConfig = 2'd1;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [2:0] sv2v_cast_911A2;
		input reg [2:0] inp;
		sv2v_cast_911A2 = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:4] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_911A2(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_max_fp_width(FpFmtConfig);
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [(2 * WIDTH) - 1:0] operands_i;
	input wire [9:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire [2:0] dst_fmt_i;
	input wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire [AuxType_AUX_BITS - 1:0] aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire [AuxType_AUX_BITS - 1:0] aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam NUM_INP_REGS = (PipeConfig == 2'd0 ? NumPipeRegs : (PipeConfig == 2'd3 ? NumPipeRegs / 2 : 0));
	localparam NUM_OUT_REGS = ((PipeConfig == 2'd1) || (PipeConfig == 2'd2) ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 1) / 2 : 0));
	wire [(2 * WIDTH) - 1:0] operands_q;
	wire [2:0] rnd_mode_q;
	wire [3:0] op_q;
	wire [2:0] dst_fmt_q;
	wire in_valid_q;
	reg [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH)] inp_pipe_operands_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_dst_fmt_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_INP_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] inp_pipe_tag_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * AuxType_AUX_BITS) + ((NUM_INP_REGS * AuxType_AUX_BITS) - 1) : ((NUM_INP_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * AuxType_AUX_BITS : 0)] inp_pipe_aux_q;
	reg [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	wire [2 * WIDTH:1] sv2v_tmp_83757;
	assign sv2v_tmp_83757 = operands_i;
	always @(*) inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] = sv2v_tmp_83757;
	wire [3:1] sv2v_tmp_857E9;
	assign sv2v_tmp_857E9 = rnd_mode_i;
	always @(*) inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = sv2v_tmp_857E9;
	wire [4:1] sv2v_tmp_4BFFB;
	assign sv2v_tmp_4BFFB = op_i;
	always @(*) inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = sv2v_tmp_4BFFB;
	wire [3:1] sv2v_tmp_54055;
	assign sv2v_tmp_54055 = dst_fmt_i;
	always @(*) inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_54055;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_74963;
	assign sv2v_tmp_74963 = tag_i;
	always @(*) inp_pipe_tag_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_74963;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_22101;
	assign sv2v_tmp_22101 = aux_i;
	always @(*) inp_pipe_aux_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_22101;
	wire [1:1] sv2v_tmp_73AEA;
	assign sv2v_tmp_73AEA = in_valid_i;
	always @(*) inp_pipe_valid_q[0] = sv2v_tmp_73AEA;
	assign in_ready_o = inp_pipe_ready[0];
	genvar i;
	function automatic [3:0] sv2v_cast_B08F0;
		input reg [3:0] inp;
		sv2v_cast_B08F0 = inp;
	endfunction
	function automatic [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] sv2v_cast_23BD2;
		input reg [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] inp;
		sv2v_cast_23BD2 = inp;
	endfunction
	function automatic [AuxType_AUX_BITS - 1:0] sv2v_cast_C9290;
		input reg [AuxType_AUX_BITS - 1:0] inp;
		sv2v_cast_C9290 = inp;
	endfunction
	generate
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_valid_q[i + 1] <= 1'b0;
				else
					inp_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (inp_pipe_ready[i] ? inp_pipe_valid_q[i] : inp_pipe_valid_q[i + 1]));
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] <= 1'sb0;
				else
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] <= (reg_ena ? inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] : inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= (reg_ena ? inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3+:3] : inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= sv2v_cast_B08F0(0);
				else
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= (reg_ena ? inp_pipe_op_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] : inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_911A2(0);
				else
					inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_23BD2(1'sb0);
				else
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_C9290(1'sb0);
				else
					inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign operands_q = inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2];
	assign rnd_mode_q = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	assign op_q = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS];
	assign dst_fmt_q = inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign in_valid_q = inp_pipe_valid_q[NUM_INP_REGS];
	reg [1:0] divsqrt_fmt;
	reg [127:0] divsqrt_operands;
	reg input_is_fp8;
	always @(*) begin : translate_fmt
		case (dst_fmt_q)
			sv2v_cast_911A2('d0): divsqrt_fmt = 2'b00;
			sv2v_cast_911A2('d1): divsqrt_fmt = 2'b01;
			sv2v_cast_911A2('d2): divsqrt_fmt = 2'b10;
			sv2v_cast_911A2('d4): divsqrt_fmt = 2'b11;
			default: divsqrt_fmt = 2'b10;
		endcase
		input_is_fp8 = FpFmtConfig[sv2v_cast_911A2('d3)] & (dst_fmt_q == sv2v_cast_911A2('d3));
		divsqrt_operands[0+:64] = (input_is_fp8 ? operands_q[0+:WIDTH] << 8 : operands_q[0+:WIDTH]);
		divsqrt_operands[64+:64] = (input_is_fp8 ? operands_q[WIDTH+:WIDTH] << 8 : operands_q[WIDTH+:WIDTH]);
	end
	reg in_ready;
	wire div_valid;
	wire sqrt_valid;
	wire unit_ready;
	wire unit_done;
	wire op_starting;
	reg out_valid;
	wire out_ready;
	reg hold_result;
	reg data_is_held;
	reg unit_busy;
	reg [1:0] state_q;
	reg [1:0] state_d;
	assign inp_pipe_ready[NUM_INP_REGS] = in_ready;
	assign div_valid = ((in_valid_q & (op_q == sv2v_cast_B08F0(4))) & in_ready) & ~flush_i;
	assign sqrt_valid = ((in_valid_q & (op_q != sv2v_cast_B08F0(4))) & in_ready) & ~flush_i;
	assign op_starting = div_valid | sqrt_valid;
	always @(*) begin : flag_fsm
		in_ready = 1'b0;
		out_valid = 1'b0;
		hold_result = 1'b0;
		data_is_held = 1'b0;
		unit_busy = 1'b0;
		state_d = state_q;
		case (state_q)
			2'd0: begin
				in_ready = 1'b1;
				if (in_valid_q && unit_ready)
					state_d = 2'd1;
			end
			2'd1: begin
				unit_busy = 1'b1;
				if (unit_done) begin
					out_valid = 1'b1;
					if (out_ready) begin
						state_d = 2'd0;
						if (in_valid_q && unit_ready) begin
							in_ready = 1'b1;
							state_d = 2'd1;
						end
					end
					else begin
						hold_result = 1'b1;
						state_d = 2'd2;
					end
				end
			end
			2'd2: begin
				unit_busy = 1'b1;
				data_is_held = 1'b1;
				out_valid = 1'b1;
				if (out_ready) begin
					state_d = 2'd0;
					if (in_valid_q && unit_ready) begin
						in_ready = 1'b1;
						state_d = 2'd1;
					end
				end
			end
			default: state_d = 2'd0;
		endcase
		if (flush_i) begin
			unit_busy = 1'b0;
			out_valid = 1'b0;
			state_d = 2'd0;
		end
	end
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			state_q <= 2'd0;
		else
			state_q <= state_d;
	reg result_is_fp8_q;
	reg [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] result_tag_q;
	reg [AuxType_AUX_BITS - 1:0] result_aux_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			result_is_fp8_q <= 1'sb0;
		else
			result_is_fp8_q <= (op_starting ? input_is_fp8 : result_is_fp8_q);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			result_tag_q <= 1'sb0;
		else
			result_tag_q <= (op_starting ? inp_pipe_tag_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : result_tag_q);
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			result_aux_q <= 1'sb0;
		else
			result_aux_q <= (op_starting ? inp_pipe_aux_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : result_aux_q);
	wire [63:0] unit_result;
	wire [WIDTH - 1:0] adjusted_result;
	reg [WIDTH - 1:0] held_result_q;
	wire [4:0] unit_status;
	reg [4:0] held_status_q;
	localparam [5:0] sv2v_uu_i_divsqrt_lei_ext_Precision_ctl_SI_0 = 1'sb0;
	div_sqrt_top_mvp i_divsqrt_lei(
		.Clk_CI(clk_i),
		.Rst_RBI(rst_ni),
		.Div_start_SI(div_valid),
		.Sqrt_start_SI(sqrt_valid),
		.Operand_a_DI(divsqrt_operands[0+:64]),
		.Operand_b_DI(divsqrt_operands[64+:64]),
		.RM_SI(rnd_mode_q),
		.Precision_ctl_SI(sv2v_uu_i_divsqrt_lei_ext_Precision_ctl_SI_0),
		.Format_sel_SI(divsqrt_fmt),
		.Kill_SI(flush_i),
		.Result_DO(unit_result),
		.Fflags_SO(unit_status),
		.Ready_SO(unit_ready),
		.Done_SO(unit_done)
	);
	assign adjusted_result = (result_is_fp8_q ? unit_result >> 8 : unit_result);
	always @(posedge clk_i) held_result_q <= (hold_result ? adjusted_result : held_result_q);
	always @(posedge clk_i) held_status_q <= (hold_result ? unit_status : held_status_q);
	wire [WIDTH - 1:0] result_d;
	wire [4:0] status_d;
	assign result_d = (data_is_held ? held_result_q : adjusted_result);
	assign status_d = (data_is_held ? held_status_q : unit_status);
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * WIDTH) + ((NUM_OUT_REGS * WIDTH) - 1) : ((NUM_OUT_REGS + 1) * WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * WIDTH : 0)] out_pipe_result_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_OUT_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] out_pipe_tag_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * AuxType_AUX_BITS) + ((NUM_OUT_REGS * AuxType_AUX_BITS) - 1) : ((NUM_OUT_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * AuxType_AUX_BITS : 0)] out_pipe_aux_q;
	reg [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	wire [WIDTH * 1:1] sv2v_tmp_6C30D;
	assign sv2v_tmp_6C30D = result_d;
	always @(*) out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * WIDTH+:WIDTH] = sv2v_tmp_6C30D;
	wire [5:1] sv2v_tmp_2ED07;
	assign sv2v_tmp_2ED07 = status_d;
	always @(*) out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = sv2v_tmp_2ED07;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_20175;
	assign sv2v_tmp_20175 = result_tag_q;
	always @(*) out_pipe_tag_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_20175;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_2BF73;
	assign sv2v_tmp_2BF73 = result_aux_q;
	always @(*) out_pipe_aux_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_2BF73;
	wire [1:1] sv2v_tmp_D06FD;
	assign sv2v_tmp_D06FD = out_valid;
	always @(*) out_pipe_valid_q[0] = sv2v_tmp_D06FD;
	assign out_ready = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_valid_q[i + 1] <= 1'b0;
				else
					out_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (out_pipe_ready[i] ? out_pipe_valid_q[i] : out_pipe_valid_q[i + 1]));
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH] <= 1'sb0;
				else
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH] <= (reg_ena ? out_pipe_result_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * WIDTH+:WIDTH] : out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= 1'sb0;
				else
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= (reg_ena ? out_pipe_status_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * 5+:5] : out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_23BD2(1'sb0);
				else
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_C9290(1'sb0);
				else
					out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * WIDTH+:WIDTH];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = 1'b1;
	assign tag_o = out_pipe_tag_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	assign aux_o = out_pipe_aux_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, unit_busy, out_pipe_valid_q};
endmodule
module fpnew_fma_FC83A_5615B (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter signed [31:0] TagType_TagType_TagType_TagType_TAG_WIDTH = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	function automatic [2:0] sv2v_cast_8E4E1;
		input reg [2:0] inp;
		sv2v_cast_8E4E1 = inp;
	endfunction
	parameter [2:0] FpFormat = sv2v_cast_8E4E1(0);
	parameter [31:0] NumPipeRegs = 0;
	parameter [1:0] PipeConfig = 2'd0;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_fp_width(FpFormat);
	input wire clk_i;
	input wire rst_ni;
	input wire [(3 * WIDTH) - 1:0] operands_i;
	input wire [2:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [2:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32];
	endfunction
	localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [2:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32];
	endfunction
	localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_bias;
		input reg [2:0] fmt;
		fpnew_pkg_bias = $unsigned((2 ** (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] - 1)) - 1);
	endfunction
	localparam [31:0] BIAS = fpnew_pkg_bias(FpFormat);
	localparam [31:0] PRECISION_BITS = MAN_BITS + 1;
	localparam [31:0] LOWER_SUM_WIDTH = (2 * PRECISION_BITS) + 3;
	localparam [31:0] LZC_RESULT_WIDTH = $clog2(LOWER_SUM_WIDTH);
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	localparam [31:0] EXP_WIDTH = $unsigned(fpnew_pkg_maximum(EXP_BITS + 2, LZC_RESULT_WIDTH));
	localparam [31:0] SHIFT_AMOUNT_WIDTH = $clog2((3 * PRECISION_BITS) + 3);
	localparam NUM_INP_REGS = (PipeConfig == 2'd0 ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 1) / 3 : 0));
	localparam NUM_MID_REGS = (PipeConfig == 2'd2 ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 2) / 3 : 0));
	localparam NUM_OUT_REGS = (PipeConfig == 2'd1 ? NumPipeRegs : (PipeConfig == 2'd3 ? NumPipeRegs / 3 : 0));
	reg [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH)] inp_pipe_operands_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_is_boxed_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	reg [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_INP_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] inp_pipe_tag_q;
	reg [0:NUM_INP_REGS] inp_pipe_aux_q;
	reg [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	wire [3 * WIDTH:1] sv2v_tmp_BC8B9;
	assign sv2v_tmp_BC8B9 = operands_i;
	always @(*) inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] = sv2v_tmp_BC8B9;
	wire [3:1] sv2v_tmp_FE389;
	assign sv2v_tmp_FE389 = is_boxed_i;
	always @(*) inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = sv2v_tmp_FE389;
	wire [3:1] sv2v_tmp_E1339;
	assign sv2v_tmp_E1339 = rnd_mode_i;
	always @(*) inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = sv2v_tmp_E1339;
	wire [4:1] sv2v_tmp_CBA8F;
	assign sv2v_tmp_CBA8F = op_i;
	always @(*) inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = sv2v_tmp_CBA8F;
	wire [1:1] sv2v_tmp_D1C37;
	assign sv2v_tmp_D1C37 = op_mod_i;
	always @(*) inp_pipe_op_mod_q[0] = sv2v_tmp_D1C37;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_36387;
	assign sv2v_tmp_36387 = tag_i;
	always @(*) inp_pipe_tag_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_36387;
	wire [1:1] sv2v_tmp_8D189;
	assign sv2v_tmp_8D189 = aux_i;
	always @(*) inp_pipe_aux_q[0] = sv2v_tmp_8D189;
	wire [1:1] sv2v_tmp_73AEA;
	assign sv2v_tmp_73AEA = in_valid_i;
	always @(*) inp_pipe_valid_q[0] = sv2v_tmp_73AEA;
	assign in_ready_o = inp_pipe_ready[0];
	genvar i;
	function automatic [3:0] sv2v_cast_AA2D5;
		input reg [3:0] inp;
		sv2v_cast_AA2D5 = inp;
	endfunction
	function automatic [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] sv2v_cast_21219;
		input reg [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] inp;
		sv2v_cast_21219 = inp;
	endfunction
	generate
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_valid_q[i + 1] <= 1'b0;
				else
					inp_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (inp_pipe_ready[i] ? inp_pipe_valid_q[i] : inp_pipe_valid_q[i + 1]));
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] <= 1'sb0;
				else
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] <= (reg_ena ? inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] : inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= 1'sb0;
				else
					inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= (reg_ena ? inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3+:3] : inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= (reg_ena ? inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3+:3] : inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= sv2v_cast_AA2D5(0);
				else
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= (reg_ena ? inp_pipe_op_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] : inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_mod_q[i + 1] <= 1'sb0;
				else
					inp_pipe_op_mod_q[i + 1] <= (reg_ena ? inp_pipe_op_mod_q[i] : inp_pipe_op_mod_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_21219(1'sb0);
				else
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_aux_q[i + 1] <= 1'b0;
				else
					inp_pipe_aux_q[i + 1] <= (reg_ena ? inp_pipe_aux_q[i] : inp_pipe_aux_q[i + 1]);
		end
	endgenerate
	wire [23:0] info_q;
	fpnew_classifier #(
		.FpFormat(FpFormat),
		.NumOperands(3)
	) i_class_inputs(
		.operands_i(inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3]),
		.is_boxed_i(inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3]),
		.info_o(info_q)
	);
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_a;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_b;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_c;
	reg [7:0] info_a;
	reg [7:0] info_b;
	reg [7:0] info_c;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	function automatic [EXP_BITS - 1:0] sv2v_cast_F33EE;
		input reg [EXP_BITS - 1:0] inp;
		sv2v_cast_F33EE = inp;
	endfunction
	function automatic [MAN_BITS - 1:0] sv2v_cast_60B87;
		input reg [MAN_BITS - 1:0] inp;
		sv2v_cast_60B87 = inp;
	endfunction
	always @(*) begin : op_select
		operand_a = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1))) * WIDTH+:WIDTH];
		operand_b = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 1 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1))) * WIDTH+:WIDTH];
		operand_c = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1))) * WIDTH+:WIDTH];
		info_a = info_q[0+:8];
		info_b = info_q[8+:8];
		info_c = info_q[16+:8];
		operand_c[1 + (EXP_BITS + (MAN_BITS - 1))] = operand_c[1 + (EXP_BITS + (MAN_BITS - 1))] ^ inp_pipe_op_mod_q[NUM_INP_REGS];
		case (inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS])
			sv2v_cast_AA2D5(0):
				;
			sv2v_cast_AA2D5(1): operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] = ~operand_a[1 + (EXP_BITS + (MAN_BITS - 1))];
			sv2v_cast_AA2D5(2): begin
				operand_a = {1'b0, sv2v_cast_F33EE(BIAS), sv2v_cast_60B87(1'sb0)};
				info_a = 8'b10000001;
			end
			sv2v_cast_AA2D5(3): begin
				operand_c = {1'b1, sv2v_cast_F33EE(1'sb0), sv2v_cast_60B87(1'sb0)};
				info_c = 8'b00100001;
			end
			default: begin
				operand_a = {fpnew_pkg_DONT_CARE, sv2v_cast_F33EE(fpnew_pkg_DONT_CARE), sv2v_cast_60B87(fpnew_pkg_DONT_CARE)};
				operand_b = {fpnew_pkg_DONT_CARE, sv2v_cast_F33EE(fpnew_pkg_DONT_CARE), sv2v_cast_60B87(fpnew_pkg_DONT_CARE)};
				operand_c = {fpnew_pkg_DONT_CARE, sv2v_cast_F33EE(fpnew_pkg_DONT_CARE), sv2v_cast_60B87(fpnew_pkg_DONT_CARE)};
				info_a = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_b = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_c = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
			end
		endcase
	end
	wire any_operand_inf;
	wire any_operand_nan;
	wire signalling_nan;
	wire effective_subtraction;
	wire tentative_sign;
	assign any_operand_inf = |{info_a[4], info_b[4], info_c[4]};
	assign any_operand_nan = |{info_a[3], info_b[3], info_c[3]};
	assign signalling_nan = |{info_a[2], info_b[2], info_c[2]};
	assign effective_subtraction = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ^ operand_b[1 + (EXP_BITS + (MAN_BITS - 1))]) ^ operand_c[1 + (EXP_BITS + (MAN_BITS - 1))];
	assign tentative_sign = operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ^ operand_b[1 + (EXP_BITS + (MAN_BITS - 1))];
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] special_result;
	reg [4:0] special_status;
	reg result_is_special;
	always @(*) begin : special_cases
		special_result = {1'b0, sv2v_cast_F33EE(1'sb1), sv2v_cast_60B87(2 ** (MAN_BITS - 1))};
		special_status = 1'sb0;
		result_is_special = 1'b0;
		if ((info_a[4] && info_b[5]) || (info_a[5] && info_b[4])) begin
			result_is_special = 1'b1;
			special_status[4] = 1'b1;
		end
		else if (any_operand_nan) begin
			result_is_special = 1'b1;
			special_status[4] = signalling_nan;
		end
		else if (any_operand_inf) begin
			result_is_special = 1'b1;
			if (((info_a[4] || info_b[4]) && info_c[4]) && effective_subtraction)
				special_status[4] = 1'b1;
			else if (info_a[4] || info_b[4])
				special_result = {operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ^ operand_b[1 + (EXP_BITS + (MAN_BITS - 1))], sv2v_cast_F33EE(1'sb1), sv2v_cast_60B87(1'sb0)};
			else if (info_c[4])
				special_result = {operand_c[1 + (EXP_BITS + (MAN_BITS - 1))], sv2v_cast_F33EE(1'sb1), sv2v_cast_60B87(1'sb0)};
		end
	end
	wire signed [EXP_WIDTH - 1:0] exponent_a;
	wire signed [EXP_WIDTH - 1:0] exponent_b;
	wire signed [EXP_WIDTH - 1:0] exponent_c;
	wire signed [EXP_WIDTH - 1:0] exponent_addend;
	wire signed [EXP_WIDTH - 1:0] exponent_product;
	wire signed [EXP_WIDTH - 1:0] exponent_difference;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent;
	assign exponent_a = $signed({1'b0, operand_a[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)]});
	assign exponent_b = $signed({1'b0, operand_b[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)]});
	assign exponent_c = $signed({1'b0, operand_c[EXP_BITS + (MAN_BITS - 1)-:((EXP_BITS + (MAN_BITS - 1)) >= (MAN_BITS + 0) ? ((EXP_BITS + (MAN_BITS - 1)) - (MAN_BITS + 0)) + 1 : ((MAN_BITS + 0) - (EXP_BITS + (MAN_BITS - 1))) + 1)]});
	assign exponent_addend = $signed(exponent_c + $signed({1'b0, ~info_c[7]}));
	assign exponent_product = (info_a[5] || info_b[5] ? 2 - $signed(BIAS) : $signed((((exponent_a + info_a[6]) + exponent_b) + info_b[6]) - $signed(BIAS)));
	assign exponent_difference = exponent_addend - exponent_product;
	assign tentative_exponent = (exponent_difference > 0 ? exponent_addend : exponent_product);
	reg [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt;
	always @(*) begin : addend_shift_amount
		if (exponent_difference <= $signed((-2 * PRECISION_BITS) - 1))
			addend_shamt = (3 * PRECISION_BITS) + 4;
		else if (exponent_difference <= $signed(PRECISION_BITS + 2))
			addend_shamt = $unsigned(($signed(PRECISION_BITS) + 3) - exponent_difference);
		else
			addend_shamt = 0;
	end
	wire [PRECISION_BITS - 1:0] mantissa_a;
	wire [PRECISION_BITS - 1:0] mantissa_b;
	wire [PRECISION_BITS - 1:0] mantissa_c;
	wire [(2 * PRECISION_BITS) - 1:0] product;
	wire [(3 * PRECISION_BITS) + 3:0] product_shifted;
	assign mantissa_a = {info_a[7], operand_a[MAN_BITS - 1-:MAN_BITS]};
	assign mantissa_b = {info_b[7], operand_b[MAN_BITS - 1-:MAN_BITS]};
	assign mantissa_c = {info_c[7], operand_c[MAN_BITS - 1-:MAN_BITS]};
	assign product = mantissa_a * mantissa_b;
	assign product_shifted = product << 2;
	wire [(3 * PRECISION_BITS) + 3:0] addend_after_shift;
	wire [PRECISION_BITS - 1:0] addend_sticky_bits;
	wire sticky_before_add;
	wire [(3 * PRECISION_BITS) + 3:0] addend_shifted;
	wire inject_carry_in;
	assign {addend_after_shift, addend_sticky_bits} = (mantissa_c << ((3 * PRECISION_BITS) + 4)) >> addend_shamt;
	assign sticky_before_add = |addend_sticky_bits;
	assign addend_shifted = (effective_subtraction ? ~addend_after_shift : addend_after_shift);
	assign inject_carry_in = effective_subtraction & ~sticky_before_add;
	wire [(3 * PRECISION_BITS) + 4:0] sum_raw;
	wire sum_carry;
	wire [(3 * PRECISION_BITS) + 3:0] sum;
	wire final_sign;
	assign sum_raw = (product_shifted + addend_shifted) + inject_carry_in;
	assign sum_carry = sum_raw[(3 * PRECISION_BITS) + 4];
	assign sum = (effective_subtraction && ~sum_carry ? -sum_raw : sum_raw);
	assign final_sign = (effective_subtraction && (sum_carry == tentative_sign) ? 1'b1 : (effective_subtraction ? 1'b0 : tentative_sign));
	wire effective_subtraction_q;
	wire signed [EXP_WIDTH - 1:0] exponent_product_q;
	wire signed [EXP_WIDTH - 1:0] exponent_difference_q;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent_q;
	wire [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt_q;
	wire sticky_before_add_q;
	wire [(3 * PRECISION_BITS) + 3:0] sum_q;
	wire final_sign_q;
	wire [2:0] rnd_mode_q;
	wire result_is_special_q;
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] special_result_q;
	wire [4:0] special_status_q;
	reg [0:NUM_MID_REGS] mid_pipe_eff_sub_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_prod_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_diff_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_tent_exp_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH) + ((NUM_MID_REGS * SHIFT_AMOUNT_WIDTH) - 1) : ((NUM_MID_REGS + 1) * SHIFT_AMOUNT_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * SHIFT_AMOUNT_WIDTH : 0)] mid_pipe_add_shamt_q;
	reg [0:NUM_MID_REGS] mid_pipe_sticky_q;
	reg [(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? ((1 - NUM_MID_REGS) * ((3 * PRECISION_BITS) + 4)) + ((NUM_MID_REGS * ((3 * PRECISION_BITS) + 4)) - 1) : ((1 - NUM_MID_REGS) * (1 - ((3 * PRECISION_BITS) + 3))) + ((((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) - 1)) : (((3 * PRECISION_BITS) + 3) >= 0 ? ((NUM_MID_REGS + 1) * ((3 * PRECISION_BITS) + 4)) - 1 : ((NUM_MID_REGS + 1) * (1 - ((3 * PRECISION_BITS) + 3))) + ((3 * PRECISION_BITS) + 2))):(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? NUM_MID_REGS * ((3 * PRECISION_BITS) + 4) : ((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) : (((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3))] mid_pipe_sum_q;
	reg [0:NUM_MID_REGS] mid_pipe_final_sign_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 3) + ((NUM_MID_REGS * 3) - 1) : ((NUM_MID_REGS + 1) * 3) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 3 : 0)] mid_pipe_rnd_mode_q;
	reg [0:NUM_MID_REGS] mid_pipe_res_is_spec_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * ((1 + EXP_BITS) + MAN_BITS)) + ((NUM_MID_REGS * ((1 + EXP_BITS) + MAN_BITS)) - 1) : ((NUM_MID_REGS + 1) * ((1 + EXP_BITS) + MAN_BITS)) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * ((1 + EXP_BITS) + MAN_BITS) : 0)] mid_pipe_spec_res_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 5) + ((NUM_MID_REGS * 5) - 1) : ((NUM_MID_REGS + 1) * 5) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 5 : 0)] mid_pipe_spec_stat_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_MID_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_MID_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] mid_pipe_tag_q;
	reg [0:NUM_MID_REGS] mid_pipe_aux_q;
	reg [0:NUM_MID_REGS] mid_pipe_valid_q;
	wire [0:NUM_MID_REGS] mid_pipe_ready;
	wire [1:1] sv2v_tmp_56A72;
	assign sv2v_tmp_56A72 = effective_subtraction;
	always @(*) mid_pipe_eff_sub_q[0] = sv2v_tmp_56A72;
	wire [EXP_WIDTH * 1:1] sv2v_tmp_2D21E;
	assign sv2v_tmp_2D21E = exponent_product;
	always @(*) mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = sv2v_tmp_2D21E;
	wire [EXP_WIDTH * 1:1] sv2v_tmp_00793;
	assign sv2v_tmp_00793 = exponent_difference;
	always @(*) mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = sv2v_tmp_00793;
	wire [EXP_WIDTH * 1:1] sv2v_tmp_B4C85;
	assign sv2v_tmp_B4C85 = tentative_exponent;
	always @(*) mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = sv2v_tmp_B4C85;
	wire [SHIFT_AMOUNT_WIDTH * 1:1] sv2v_tmp_83404;
	assign sv2v_tmp_83404 = addend_shamt;
	always @(*) mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] = sv2v_tmp_83404;
	wire [1:1] sv2v_tmp_6F5F7;
	assign sv2v_tmp_6F5F7 = sticky_before_add;
	always @(*) mid_pipe_sticky_q[0] = sv2v_tmp_6F5F7;
	wire [(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)) * 1:1] sv2v_tmp_CEAB3;
	assign sv2v_tmp_CEAB3 = sum;
	always @(*) mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] = sv2v_tmp_CEAB3;
	wire [1:1] sv2v_tmp_D7BD0;
	assign sv2v_tmp_D7BD0 = final_sign;
	always @(*) mid_pipe_final_sign_q[0] = sv2v_tmp_D7BD0;
	wire [3:1] sv2v_tmp_A74E2;
	assign sv2v_tmp_A74E2 = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	always @(*) mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 3+:3] = sv2v_tmp_A74E2;
	wire [1:1] sv2v_tmp_7DEC5;
	assign sv2v_tmp_7DEC5 = result_is_special;
	always @(*) mid_pipe_res_is_spec_q[0] = sv2v_tmp_7DEC5;
	wire [((1 + EXP_BITS) + MAN_BITS) * 1:1] sv2v_tmp_4A83E;
	assign sv2v_tmp_4A83E = special_result;
	always @(*) mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] = sv2v_tmp_4A83E;
	wire [5:1] sv2v_tmp_EC01B;
	assign sv2v_tmp_EC01B = special_status;
	always @(*) mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 5+:5] = sv2v_tmp_EC01B;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_6DFE4;
	assign sv2v_tmp_6DFE4 = inp_pipe_tag_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	always @(*) mid_pipe_tag_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_6DFE4;
	wire [1:1] sv2v_tmp_CDA0E;
	assign sv2v_tmp_CDA0E = inp_pipe_aux_q[NUM_INP_REGS];
	always @(*) mid_pipe_aux_q[0] = sv2v_tmp_CDA0E;
	wire [1:1] sv2v_tmp_CB10A;
	assign sv2v_tmp_CB10A = inp_pipe_valid_q[NUM_INP_REGS];
	always @(*) mid_pipe_valid_q[0] = sv2v_tmp_CB10A;
	assign inp_pipe_ready[NUM_INP_REGS] = mid_pipe_ready[0];
	generate
		for (i = 0; i < NUM_MID_REGS; i = i + 1) begin : gen_inside_pipeline
			wire reg_ena;
			assign mid_pipe_ready[i] = mid_pipe_ready[i + 1] | ~mid_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_valid_q[i + 1] <= 1'b0;
				else
					mid_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (mid_pipe_ready[i] ? mid_pipe_valid_q[i] : mid_pipe_valid_q[i + 1]));
			assign reg_ena = mid_pipe_ready[i] & mid_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_eff_sub_q[i + 1] <= 1'sb0;
				else
					mid_pipe_eff_sub_q[i + 1] <= (reg_ena ? mid_pipe_eff_sub_q[i] : mid_pipe_eff_sub_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= (reg_ena ? mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * EXP_WIDTH+:EXP_WIDTH] : mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= (reg_ena ? mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * EXP_WIDTH+:EXP_WIDTH] : mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= (reg_ena ? mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * EXP_WIDTH+:EXP_WIDTH] : mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] <= 1'sb0;
				else
					mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] <= (reg_ena ? mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] : mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_sticky_q[i + 1] <= 1'sb0;
				else
					mid_pipe_sticky_q[i + 1] <= (reg_ena ? mid_pipe_sticky_q[i] : mid_pipe_sticky_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] <= 1'sb0;
				else
					mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] <= (reg_ena ? mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] : mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_final_sign_q[i + 1] <= 1'sb0;
				else
					mid_pipe_final_sign_q[i + 1] <= (reg_ena ? mid_pipe_final_sign_q[i] : mid_pipe_final_sign_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3] <= (reg_ena ? mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * 3+:3] : mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_res_is_spec_q[i + 1] <= 1'sb0;
				else
					mid_pipe_res_is_spec_q[i + 1] <= (reg_ena ? mid_pipe_res_is_spec_q[i] : mid_pipe_res_is_spec_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] <= 1'sb0;
				else
					mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] <= (reg_ena ? mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] : mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 5+:5] <= 1'sb0;
				else
					mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 5+:5] <= (reg_ena ? mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * 5+:5] : mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 5+:5]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_21219(1'sb0);
				else
					mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_aux_q[i + 1] <= 1'b0;
				else
					mid_pipe_aux_q[i + 1] <= (reg_ena ? mid_pipe_aux_q[i] : mid_pipe_aux_q[i + 1]);
		end
	endgenerate
	assign effective_subtraction_q = mid_pipe_eff_sub_q[NUM_MID_REGS];
	assign exponent_product_q = mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign exponent_difference_q = mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign tentative_exponent_q = mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign addend_shamt_q = mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH];
	assign sticky_before_add_q = mid_pipe_sticky_q[NUM_MID_REGS];
	assign sum_q = mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))];
	assign final_sign_q = mid_pipe_final_sign_q[NUM_MID_REGS];
	assign rnd_mode_q = mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 3+:3];
	assign result_is_special_q = mid_pipe_res_is_spec_q[NUM_MID_REGS];
	assign special_result_q = mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS];
	assign special_status_q = mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 5+:5];
	wire [LOWER_SUM_WIDTH - 1:0] sum_lower;
	wire [LZC_RESULT_WIDTH - 1:0] leading_zero_count;
	wire signed [LZC_RESULT_WIDTH:0] leading_zero_count_sgn;
	wire lzc_zeroes;
	reg [SHIFT_AMOUNT_WIDTH - 1:0] norm_shamt;
	reg signed [EXP_WIDTH - 1:0] normalized_exponent;
	wire [(3 * PRECISION_BITS) + 4:0] sum_shifted;
	reg [PRECISION_BITS:0] final_mantissa;
	reg [(2 * PRECISION_BITS) + 2:0] sum_sticky_bits;
	wire sticky_after_norm;
	reg signed [EXP_WIDTH - 1:0] final_exponent;
	assign sum_lower = sum_q[LOWER_SUM_WIDTH - 1:0];
	lzc #(
		.WIDTH(LOWER_SUM_WIDTH),
		.MODE(1)
	) i_lzc(
		.in_i(sum_lower),
		.cnt_o(leading_zero_count),
		.empty_o(lzc_zeroes)
	);
	assign leading_zero_count_sgn = $signed({1'b0, leading_zero_count});
	always @(*) begin : norm_shift_amount
		if ((exponent_difference_q <= 0) || (effective_subtraction_q && (exponent_difference_q <= 2))) begin
			if ((((exponent_product_q - leading_zero_count_sgn) + 1) >= 0) && !lzc_zeroes) begin
				norm_shamt = (PRECISION_BITS + 2) + leading_zero_count;
				normalized_exponent = (exponent_product_q - leading_zero_count_sgn) + 1;
			end
			else begin
				norm_shamt = $unsigned(($signed(PRECISION_BITS) + 2) + exponent_product_q);
				normalized_exponent = 0;
			end
		end
		else begin
			norm_shamt = addend_shamt_q;
			normalized_exponent = tentative_exponent_q;
		end
	end
	assign sum_shifted = sum_q << norm_shamt;
	always @(*) begin : small_norm
		{final_mantissa, sum_sticky_bits} = sum_shifted;
		final_exponent = normalized_exponent;
		if (sum_shifted[(3 * PRECISION_BITS) + 4]) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted >> 1;
			final_exponent = normalized_exponent + 1;
		end
		else if (sum_shifted[(3 * PRECISION_BITS) + 3])
			;
		else if (normalized_exponent > 1) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted << 1;
			final_exponent = normalized_exponent - 1;
		end
		else
			final_exponent = 1'sb0;
	end
	assign sticky_after_norm = |{sum_sticky_bits} | sticky_before_add_q;
	wire pre_round_sign;
	wire [EXP_BITS - 1:0] pre_round_exponent;
	wire [MAN_BITS - 1:0] pre_round_mantissa;
	wire [(EXP_BITS + MAN_BITS) - 1:0] pre_round_abs;
	wire [1:0] round_sticky_bits;
	wire of_before_round;
	wire of_after_round;
	wire uf_before_round;
	wire uf_after_round;
	wire result_zero;
	wire rounded_sign;
	wire [(EXP_BITS + MAN_BITS) - 1:0] rounded_abs;
	assign of_before_round = final_exponent >= ((2 ** EXP_BITS) - 1);
	assign uf_before_round = final_exponent == 0;
	assign pre_round_sign = final_sign_q;
	assign pre_round_exponent = (of_before_round ? (2 ** EXP_BITS) - 2 : $unsigned(final_exponent[EXP_BITS - 1:0]));
	assign pre_round_mantissa = (of_before_round ? {MAN_BITS {1'sb1}} : final_mantissa[MAN_BITS:1]);
	assign pre_round_abs = {pre_round_exponent, pre_round_mantissa};
	assign round_sticky_bits = (of_before_round ? 2'b11 : {final_mantissa[0], sticky_after_norm});
	fpnew_rounding #(.AbsWidth(EXP_BITS + MAN_BITS)) i_fpnew_rounding(
		.abs_value_i(pre_round_abs),
		.sign_i(pre_round_sign),
		.round_sticky_bits_i(round_sticky_bits),
		.rnd_mode_i(rnd_mode_q),
		.effective_subtraction_i(effective_subtraction_q),
		.abs_rounded_o(rounded_abs),
		.sign_o(rounded_sign),
		.exact_zero_o(result_zero)
	);
	assign uf_after_round = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) * 1 {1'sb0}};
	assign of_after_round = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) * 1 {1'sb1}};
	wire [WIDTH - 1:0] regular_result;
	wire [4:0] regular_status;
	assign regular_result = {rounded_sign, rounded_abs};
	assign regular_status[4] = 1'b0;
	assign regular_status[3] = 1'b0;
	assign regular_status[2] = of_before_round | of_after_round;
	assign regular_status[1] = uf_after_round & regular_status[0];
	assign regular_status[0] = (|round_sticky_bits | of_before_round) | of_after_round;
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] result_d;
	wire [4:0] status_d;
	assign result_d = (result_is_special_q ? special_result_q : regular_result);
	assign status_d = (result_is_special_q ? special_status_q : regular_status);
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)) + ((NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS)) - 1) : ((NUM_OUT_REGS + 1) * ((1 + EXP_BITS) + MAN_BITS)) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS) : 0)] out_pipe_result_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_OUT_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] out_pipe_tag_q;
	reg [0:NUM_OUT_REGS] out_pipe_aux_q;
	reg [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	wire [((1 + EXP_BITS) + MAN_BITS) * 1:1] sv2v_tmp_0252C;
	assign sv2v_tmp_0252C = result_d;
	always @(*) out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] = sv2v_tmp_0252C;
	wire [5:1] sv2v_tmp_2A843;
	assign sv2v_tmp_2A843 = status_d;
	always @(*) out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = sv2v_tmp_2A843;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_192AB;
	assign sv2v_tmp_192AB = mid_pipe_tag_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	always @(*) out_pipe_tag_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_192AB;
	wire [1:1] sv2v_tmp_9E262;
	assign sv2v_tmp_9E262 = mid_pipe_aux_q[NUM_MID_REGS];
	always @(*) out_pipe_aux_q[0] = sv2v_tmp_9E262;
	wire [1:1] sv2v_tmp_25EE6;
	assign sv2v_tmp_25EE6 = mid_pipe_valid_q[NUM_MID_REGS];
	always @(*) out_pipe_valid_q[0] = sv2v_tmp_25EE6;
	assign mid_pipe_ready[NUM_MID_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_valid_q[i + 1] <= 1'b0;
				else
					out_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (out_pipe_ready[i] ? out_pipe_valid_q[i] : out_pipe_valid_q[i + 1]));
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] <= 1'sb0;
				else
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] <= (reg_ena ? out_pipe_result_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] : out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= 1'sb0;
				else
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= (reg_ena ? out_pipe_status_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * 5+:5] : out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_21219(1'sb0);
				else
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_aux_q[i + 1] <= 1'b0;
				else
					out_pipe_aux_q[i + 1] <= (reg_ena ? out_pipe_aux_q[i] : out_pipe_aux_q[i + 1]);
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = 1'b1;
	assign tag_o = out_pipe_tag_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	assign aux_o = out_pipe_aux_q[NUM_OUT_REGS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, mid_pipe_valid_q, out_pipe_valid_q};
endmodule
module fpnew_fma_multi_41774_DE779 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter [31:0] AuxType_AUX_BITS = 0;
	parameter signed [31:0] TagType_TagType_TagType_TagType_TAG_WIDTH = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	parameter [0:4] FpFmtConfig = 1'sb1;
	parameter [31:0] NumPipeRegs = 0;
	parameter [1:0] PipeConfig = 2'd0;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [2:0] sv2v_cast_5B9B1;
		input reg [2:0] inp;
		sv2v_cast_5B9B1 = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:4] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_5B9B1(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_max_fp_width(FpFmtConfig);
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [(3 * WIDTH) - 1:0] operands_i;
	input wire [14:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire [2:0] src_fmt_i;
	input wire [2:0] dst_fmt_i;
	input wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire [AuxType_AUX_BITS - 1:0] aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire [AuxType_AUX_BITS - 1:0] aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [2:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32];
	endfunction
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [2:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32];
	endfunction
	function automatic [63:0] fpnew_pkg_super_format;
		input reg [0:4] cfg;
		reg [63:0] res;
		begin
			res = 1'sb0;
			begin : sv2v_autoblock_2
				reg [31:0] fmt;
				for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
					if (cfg[fmt]) begin
						res[63-:32] = $unsigned(fpnew_pkg_maximum(res[63-:32], fpnew_pkg_exp_bits(sv2v_cast_5B9B1(fmt))));
						res[31-:32] = $unsigned(fpnew_pkg_maximum(res[31-:32], fpnew_pkg_man_bits(sv2v_cast_5B9B1(fmt))));
					end
			end
			fpnew_pkg_super_format = res;
		end
	endfunction
	localparam [63:0] SUPER_FORMAT = fpnew_pkg_super_format(FpFmtConfig);
	localparam [31:0] SUPER_EXP_BITS = SUPER_FORMAT[63-:32];
	localparam [31:0] SUPER_MAN_BITS = SUPER_FORMAT[31-:32];
	localparam [31:0] PRECISION_BITS = SUPER_MAN_BITS + 1;
	localparam [31:0] LOWER_SUM_WIDTH = (2 * PRECISION_BITS) + 3;
	localparam [31:0] LZC_RESULT_WIDTH = $clog2(LOWER_SUM_WIDTH);
	localparam [31:0] EXP_WIDTH = fpnew_pkg_maximum(SUPER_EXP_BITS + 2, LZC_RESULT_WIDTH);
	localparam [31:0] SHIFT_AMOUNT_WIDTH = $clog2((3 * PRECISION_BITS) + 3);
	localparam NUM_INP_REGS = (PipeConfig == 2'd0 ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 1) / 3 : 0));
	localparam NUM_MID_REGS = (PipeConfig == 2'd2 ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 2) / 3 : 0));
	localparam NUM_OUT_REGS = (PipeConfig == 2'd1 ? NumPipeRegs : (PipeConfig == 2'd3 ? NumPipeRegs / 3 : 0));
	wire [(3 * WIDTH) - 1:0] operands_q;
	wire [2:0] src_fmt_q;
	wire [2:0] dst_fmt_q;
	reg [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) * WIDTH)] inp_pipe_operands_q;
	reg [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0)) + 1) * 3) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) * 3) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)) + 1) * 3) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) * 3) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) * 3 : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) * 3)] inp_pipe_is_boxed_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	reg [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_src_fmt_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] inp_pipe_dst_fmt_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_INP_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] inp_pipe_tag_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * AuxType_AUX_BITS) + ((NUM_INP_REGS * AuxType_AUX_BITS) - 1) : ((NUM_INP_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * AuxType_AUX_BITS : 0)] inp_pipe_aux_q;
	reg [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	wire [3 * WIDTH:1] sv2v_tmp_5DCC9;
	assign sv2v_tmp_5DCC9 = operands_i;
	always @(*) inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] = sv2v_tmp_5DCC9;
	wire [15:1] sv2v_tmp_7F60B;
	assign sv2v_tmp_7F60B = is_boxed_i;
	always @(*) inp_pipe_is_boxed_q[3 * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS) + 4) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * NUM_FORMATS) + 4) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)))+:15] = sv2v_tmp_7F60B;
	wire [3:1] sv2v_tmp_700C1;
	assign sv2v_tmp_700C1 = rnd_mode_i;
	always @(*) inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = sv2v_tmp_700C1;
	wire [4:1] sv2v_tmp_3923B;
	assign sv2v_tmp_3923B = op_i;
	always @(*) inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = sv2v_tmp_3923B;
	wire [1:1] sv2v_tmp_D1C37;
	assign sv2v_tmp_D1C37 = op_mod_i;
	always @(*) inp_pipe_op_mod_q[0] = sv2v_tmp_D1C37;
	wire [3:1] sv2v_tmp_6B115;
	assign sv2v_tmp_6B115 = src_fmt_i;
	always @(*) inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_6B115;
	wire [3:1] sv2v_tmp_B8677;
	assign sv2v_tmp_B8677 = dst_fmt_i;
	always @(*) inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_B8677;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_AEFB3;
	assign sv2v_tmp_AEFB3 = tag_i;
	always @(*) inp_pipe_tag_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_AEFB3;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_BB7D1;
	assign sv2v_tmp_BB7D1 = aux_i;
	always @(*) inp_pipe_aux_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_BB7D1;
	wire [1:1] sv2v_tmp_73AEA;
	assign sv2v_tmp_73AEA = in_valid_i;
	always @(*) inp_pipe_valid_q[0] = sv2v_tmp_73AEA;
	assign in_ready_o = inp_pipe_ready[0];
	genvar i;
	function automatic [3:0] sv2v_cast_92219;
		input reg [3:0] inp;
		sv2v_cast_92219 = inp;
	endfunction
	function automatic [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] sv2v_cast_693DA;
		input reg [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] inp;
		sv2v_cast_693DA = inp;
	endfunction
	function automatic [AuxType_AUX_BITS - 1:0] sv2v_cast_F0E88;
		input reg [AuxType_AUX_BITS - 1:0] inp;
		sv2v_cast_F0E88 = inp;
	endfunction
	generate
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_valid_q[i + 1] <= 1'b0;
				else
					inp_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (inp_pipe_ready[i] ? inp_pipe_valid_q[i] : inp_pipe_valid_q[i + 1]));
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] <= 1'sb0;
				else
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] <= (reg_ena ? inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3] : inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_is_boxed_q[3 * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS) + 4) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS) + 4) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)))+:15] <= 1'sb0;
				else
					inp_pipe_is_boxed_q[3 * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS) + 4) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS) + 4) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)))+:15] <= (reg_ena ? inp_pipe_is_boxed_q[3 * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * NUM_FORMATS) + 4) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * NUM_FORMATS) + 4) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)))+:15] : inp_pipe_is_boxed_q[3 * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS) + 4) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * NUM_FORMATS) + 4) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1)))+:15]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= (reg_ena ? inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3+:3] : inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= sv2v_cast_92219(0);
				else
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= (reg_ena ? inp_pipe_op_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] : inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_mod_q[i + 1] <= 1'sb0;
				else
					inp_pipe_op_mod_q[i + 1] <= (reg_ena ? inp_pipe_op_mod_q[i] : inp_pipe_op_mod_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_5B9B1(0);
				else
					inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_5B9B1(0);
				else
					inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_693DA(1'sb0);
				else
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_F0E88(1'sb0);
				else
					inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : inp_pipe_aux_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign operands_q = inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3) + 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1)))+:WIDTH * 3];
	assign src_fmt_q = inp_pipe_src_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign dst_fmt_q = inp_pipe_dst_fmt_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	wire [14:0] fmt_sign;
	wire signed [(15 * SUPER_EXP_BITS) - 1:0] fmt_exponent;
	wire [(15 * SUPER_MAN_BITS) - 1:0] fmt_mantissa;
	wire [119:0] info_q;
	genvar fmt;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	function automatic signed [SUPER_EXP_BITS - 1:0] sv2v_cast_705CC_signed;
		input reg signed [SUPER_EXP_BITS - 1:0] inp;
		sv2v_cast_705CC_signed = inp;
	endfunction
	function automatic [SUPER_MAN_BITS - 1:0] sv2v_cast_FC661;
		input reg [SUPER_MAN_BITS - 1:0] inp;
		sv2v_cast_FC661 = inp;
	endfunction
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : fmt_init_inputs
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_5B9B1(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_5B9B1(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_5B9B1(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				wire [(3 * FP_WIDTH) - 1:0] trimmed_ops;
				fpnew_classifier #(
					.FpFormat(sv2v_cast_5B9B1(fmt)),
					.NumOperands(3)
				) i_fpnew_classifier(
					.operands_i(trimmed_ops),
					.is_boxed_i(inp_pipe_is_boxed_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * NUM_FORMATS) + fmt : (0 >= NUM_INP_REGS ? NUM_INP_REGS * NUM_FORMATS : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * NUM_FORMATS) + fmt) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * NUM_FORMATS) + ((NUM_INP_REGS * NUM_FORMATS) - 1) : ((NUM_INP_REGS + 1) * NUM_FORMATS) - 1))) * 3+:3]),
					.info_o(info_q[8 * (fmt * 3)+:24])
				);
				genvar op;
				for (op = 0; op < 3; op = op + 1) begin : gen_operands
					assign trimmed_ops[op * fpnew_pkg_fp_width(sv2v_cast_5B9B1(fmt))+:fpnew_pkg_fp_width(sv2v_cast_5B9B1(fmt))] = operands_q[(op * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH];
					assign fmt_sign[(fmt * 3) + op] = operands_q[(op * WIDTH) + (FP_WIDTH - 1)];
					assign fmt_exponent[((fmt * 3) + op) * SUPER_EXP_BITS+:SUPER_EXP_BITS] = $signed({1'b0, operands_q[(op * WIDTH) + MAN_BITS+:EXP_BITS]});
					assign fmt_mantissa[((fmt * 3) + op) * SUPER_MAN_BITS+:SUPER_MAN_BITS] = {info_q[(((fmt * 3) + op) * 8) + 7], operands_q[(op * WIDTH) + (MAN_BITS - 1)-:MAN_BITS]} << (SUPER_MAN_BITS - MAN_BITS);
				end
			end
			else begin : inactive_format
				assign info_q[8 * (fmt * 3)+:24] = {3 {sv2v_cast_8(fpnew_pkg_DONT_CARE)}};
				assign fmt_sign[fmt * 3+:3] = fpnew_pkg_DONT_CARE;
				assign fmt_exponent[SUPER_EXP_BITS * (fmt * 3)+:SUPER_EXP_BITS * 3] = {3 {sv2v_cast_705CC_signed(fpnew_pkg_DONT_CARE)}};
				assign fmt_mantissa[SUPER_MAN_BITS * (fmt * 3)+:SUPER_MAN_BITS * 3] = {3 {sv2v_cast_FC661(fpnew_pkg_DONT_CARE)}};
			end
		end
	endgenerate
	reg [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] operand_a;
	reg [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] operand_b;
	reg [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] operand_c;
	reg [7:0] info_a;
	reg [7:0] info_b;
	reg [7:0] info_c;
	function automatic [31:0] fpnew_pkg_bias;
		input reg [2:0] fmt;
		fpnew_pkg_bias = $unsigned((2 ** (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] - 1)) - 1);
	endfunction
	function automatic [SUPER_EXP_BITS - 1:0] sv2v_cast_705CC;
		input reg [SUPER_EXP_BITS - 1:0] inp;
		sv2v_cast_705CC = inp;
	endfunction
	always @(*) begin : op_select
		operand_a = {fmt_sign[src_fmt_q * 3], fmt_exponent[(src_fmt_q * 3) * SUPER_EXP_BITS+:SUPER_EXP_BITS], fmt_mantissa[(src_fmt_q * 3) * SUPER_MAN_BITS+:SUPER_MAN_BITS]};
		operand_b = {fmt_sign[(src_fmt_q * 3) + 1], fmt_exponent[((src_fmt_q * 3) + 1) * SUPER_EXP_BITS+:SUPER_EXP_BITS], fmt_mantissa[((src_fmt_q * 3) + 1) * SUPER_MAN_BITS+:SUPER_MAN_BITS]};
		operand_c = {fmt_sign[(dst_fmt_q * 3) + 2], fmt_exponent[((dst_fmt_q * 3) + 2) * SUPER_EXP_BITS+:SUPER_EXP_BITS], fmt_mantissa[((dst_fmt_q * 3) + 2) * SUPER_MAN_BITS+:SUPER_MAN_BITS]};
		info_a = info_q[(src_fmt_q * 3) * 8+:8];
		info_b = info_q[((src_fmt_q * 3) + 1) * 8+:8];
		info_c = info_q[((dst_fmt_q * 3) + 2) * 8+:8];
		operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] = operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ inp_pipe_op_mod_q[NUM_INP_REGS];
		case (inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS])
			sv2v_cast_92219(0):
				;
			sv2v_cast_92219(1): operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] = ~operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))];
			sv2v_cast_92219(2): begin
				operand_a = {1'b0, sv2v_cast_705CC(fpnew_pkg_bias(src_fmt_q)), sv2v_cast_FC661(1'sb0)};
				info_a = 8'b10000001;
			end
			sv2v_cast_92219(3): begin
				operand_c = {1'b1, sv2v_cast_705CC(1'sb0), sv2v_cast_FC661(1'sb0)};
				info_c = 8'b00100001;
			end
			default: begin
				operand_a = {fpnew_pkg_DONT_CARE, sv2v_cast_705CC(fpnew_pkg_DONT_CARE), sv2v_cast_FC661(fpnew_pkg_DONT_CARE)};
				operand_b = {fpnew_pkg_DONT_CARE, sv2v_cast_705CC(fpnew_pkg_DONT_CARE), sv2v_cast_FC661(fpnew_pkg_DONT_CARE)};
				operand_c = {fpnew_pkg_DONT_CARE, sv2v_cast_705CC(fpnew_pkg_DONT_CARE), sv2v_cast_FC661(fpnew_pkg_DONT_CARE)};
				info_a = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_b = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				info_c = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
			end
		endcase
	end
	wire any_operand_inf;
	wire any_operand_nan;
	wire signalling_nan;
	wire effective_subtraction;
	wire tentative_sign;
	assign any_operand_inf = |{info_a[4], info_b[4], info_c[4]};
	assign any_operand_nan = |{info_a[3], info_b[3], info_c[3]};
	assign signalling_nan = |{info_a[2], info_b[2], info_c[2]};
	assign effective_subtraction = (operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ operand_b[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))]) ^ operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))];
	assign tentative_sign = operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ operand_b[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))];
	wire [WIDTH - 1:0] special_result;
	wire [4:0] special_status;
	wire result_is_special;
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_special_result;
	reg [24:0] fmt_special_status;
	reg [4:0] fmt_result_is_special;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_special_results
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_5B9B1(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_5B9B1(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_5B9B1(fmt));
			localparam [EXP_BITS - 1:0] QNAN_EXPONENT = 1'sb1;
			localparam [MAN_BITS - 1:0] QNAN_MANTISSA = 2 ** (MAN_BITS - 1);
			localparam [MAN_BITS - 1:0] ZERO_MANTISSA = 1'sb0;
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : special_results
					reg [FP_WIDTH - 1:0] special_res;
					special_res = {1'b0, QNAN_EXPONENT, QNAN_MANTISSA};
					fmt_special_status[fmt * 5+:5] = 1'sb0;
					fmt_result_is_special[fmt] = 1'b0;
					if ((info_a[4] && info_b[5]) || (info_a[5] && info_b[4])) begin
						fmt_result_is_special[fmt] = 1'b1;
						fmt_special_status[(fmt * 5) + 4] = 1'b1;
					end
					else if (any_operand_nan) begin
						fmt_result_is_special[fmt] = 1'b1;
						fmt_special_status[(fmt * 5) + 4] = signalling_nan;
					end
					else if (any_operand_inf) begin
						fmt_result_is_special[fmt] = 1'b1;
						if (((info_a[4] || info_b[4]) && info_c[4]) && effective_subtraction)
							fmt_special_status[(fmt * 5) + 4] = 1'b1;
						else if (info_a[4] || info_b[4])
							special_res = {operand_a[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))] ^ operand_b[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))], QNAN_EXPONENT, ZERO_MANTISSA};
						else if (info_c[4])
							special_res = {operand_c[1 + (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))], QNAN_EXPONENT, ZERO_MANTISSA};
					end
					fmt_special_result[fmt * WIDTH+:WIDTH] = 1'sb1;
					fmt_special_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = special_res;
				end
			end
			else begin : inactive_format
				wire [WIDTH * 1:1] sv2v_tmp_7740B;
				assign sv2v_tmp_7740B = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_special_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_7740B;
				wire [5:1] sv2v_tmp_899F4;
				assign sv2v_tmp_899F4 = 1'sb0;
				always @(*) fmt_special_status[fmt * 5+:5] = sv2v_tmp_899F4;
				wire [1:1] sv2v_tmp_77BE5;
				assign sv2v_tmp_77BE5 = 1'b0;
				always @(*) fmt_result_is_special[fmt] = sv2v_tmp_77BE5;
			end
		end
	endgenerate
	assign result_is_special = fmt_result_is_special[dst_fmt_q];
	assign special_status = fmt_special_status[dst_fmt_q * 5+:5];
	assign special_result = fmt_special_result[dst_fmt_q * WIDTH+:WIDTH];
	wire signed [EXP_WIDTH - 1:0] exponent_a;
	wire signed [EXP_WIDTH - 1:0] exponent_b;
	wire signed [EXP_WIDTH - 1:0] exponent_c;
	wire signed [EXP_WIDTH - 1:0] exponent_addend;
	wire signed [EXP_WIDTH - 1:0] exponent_product;
	wire signed [EXP_WIDTH - 1:0] exponent_difference;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent;
	assign exponent_a = $signed({1'b0, operand_a[SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)-:((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) >= (SUPER_MAN_BITS + 0) ? ((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) - (SUPER_MAN_BITS + 0)) + 1 : ((SUPER_MAN_BITS + 0) - (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))) + 1)]});
	assign exponent_b = $signed({1'b0, operand_b[SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)-:((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) >= (SUPER_MAN_BITS + 0) ? ((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) - (SUPER_MAN_BITS + 0)) + 1 : ((SUPER_MAN_BITS + 0) - (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))) + 1)]});
	assign exponent_c = $signed({1'b0, operand_c[SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)-:((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) >= (SUPER_MAN_BITS + 0) ? ((SUPER_EXP_BITS + (SUPER_MAN_BITS - 1)) - (SUPER_MAN_BITS + 0)) + 1 : ((SUPER_MAN_BITS + 0) - (SUPER_EXP_BITS + (SUPER_MAN_BITS - 1))) + 1)]});
	assign exponent_addend = $signed(exponent_c + $signed({1'b0, ~info_c[7]}));
	assign exponent_product = (info_a[5] || info_b[5] ? 2 - $signed(fpnew_pkg_bias(dst_fmt_q)) : $signed(((((exponent_a + info_a[6]) + exponent_b) + info_b[6]) - (2 * $signed(fpnew_pkg_bias(src_fmt_q)))) + $signed(fpnew_pkg_bias(dst_fmt_q))));
	assign exponent_difference = exponent_addend - exponent_product;
	assign tentative_exponent = (exponent_difference > 0 ? exponent_addend : exponent_product);
	reg [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt;
	always @(*) begin : addend_shift_amount
		if (exponent_difference <= $signed((-2 * PRECISION_BITS) - 1))
			addend_shamt = (3 * PRECISION_BITS) + 4;
		else if (exponent_difference <= $signed(PRECISION_BITS + 2))
			addend_shamt = $unsigned(($signed(PRECISION_BITS) + 3) - exponent_difference);
		else
			addend_shamt = 0;
	end
	wire [PRECISION_BITS - 1:0] mantissa_a;
	wire [PRECISION_BITS - 1:0] mantissa_b;
	wire [PRECISION_BITS - 1:0] mantissa_c;
	wire [(2 * PRECISION_BITS) - 1:0] product;
	wire [(3 * PRECISION_BITS) + 3:0] product_shifted;
	assign mantissa_a = {info_a[7], operand_a[SUPER_MAN_BITS - 1-:SUPER_MAN_BITS]};
	assign mantissa_b = {info_b[7], operand_b[SUPER_MAN_BITS - 1-:SUPER_MAN_BITS]};
	assign mantissa_c = {info_c[7], operand_c[SUPER_MAN_BITS - 1-:SUPER_MAN_BITS]};
	assign product = mantissa_a * mantissa_b;
	assign product_shifted = product << 2;
	wire [(3 * PRECISION_BITS) + 3:0] addend_after_shift;
	wire [PRECISION_BITS - 1:0] addend_sticky_bits;
	wire sticky_before_add;
	wire [(3 * PRECISION_BITS) + 3:0] addend_shifted;
	wire inject_carry_in;
	assign {addend_after_shift, addend_sticky_bits} = (mantissa_c << ((3 * PRECISION_BITS) + 4)) >> addend_shamt;
	assign sticky_before_add = |addend_sticky_bits;
	assign addend_shifted = (effective_subtraction ? ~addend_after_shift : addend_after_shift);
	assign inject_carry_in = effective_subtraction & ~sticky_before_add;
	wire [(3 * PRECISION_BITS) + 4:0] sum_raw;
	wire sum_carry;
	wire [(3 * PRECISION_BITS) + 3:0] sum;
	wire final_sign;
	assign sum_raw = (product_shifted + addend_shifted) + inject_carry_in;
	assign sum_carry = sum_raw[(3 * PRECISION_BITS) + 4];
	assign sum = (effective_subtraction && ~sum_carry ? -sum_raw : sum_raw);
	assign final_sign = (effective_subtraction && (sum_carry == tentative_sign) ? 1'b1 : (effective_subtraction ? 1'b0 : tentative_sign));
	wire effective_subtraction_q;
	wire signed [EXP_WIDTH - 1:0] exponent_product_q;
	wire signed [EXP_WIDTH - 1:0] exponent_difference_q;
	wire signed [EXP_WIDTH - 1:0] tentative_exponent_q;
	wire [SHIFT_AMOUNT_WIDTH - 1:0] addend_shamt_q;
	wire sticky_before_add_q;
	wire [(3 * PRECISION_BITS) + 3:0] sum_q;
	wire final_sign_q;
	wire [2:0] dst_fmt_q2;
	wire [2:0] rnd_mode_q;
	wire result_is_special_q;
	wire [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) - 1:0] special_result_q;
	wire [4:0] special_status_q;
	reg [0:NUM_MID_REGS] mid_pipe_eff_sub_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_prod_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_exp_diff_q;
	reg signed [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * EXP_WIDTH) + ((NUM_MID_REGS * EXP_WIDTH) - 1) : ((NUM_MID_REGS + 1) * EXP_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * EXP_WIDTH : 0)] mid_pipe_tent_exp_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH) + ((NUM_MID_REGS * SHIFT_AMOUNT_WIDTH) - 1) : ((NUM_MID_REGS + 1) * SHIFT_AMOUNT_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * SHIFT_AMOUNT_WIDTH : 0)] mid_pipe_add_shamt_q;
	reg [0:NUM_MID_REGS] mid_pipe_sticky_q;
	reg [(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? ((1 - NUM_MID_REGS) * ((3 * PRECISION_BITS) + 4)) + ((NUM_MID_REGS * ((3 * PRECISION_BITS) + 4)) - 1) : ((1 - NUM_MID_REGS) * (1 - ((3 * PRECISION_BITS) + 3))) + ((((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) - 1)) : (((3 * PRECISION_BITS) + 3) >= 0 ? ((NUM_MID_REGS + 1) * ((3 * PRECISION_BITS) + 4)) - 1 : ((NUM_MID_REGS + 1) * (1 - ((3 * PRECISION_BITS) + 3))) + ((3 * PRECISION_BITS) + 2))):(0 >= NUM_MID_REGS ? (((3 * PRECISION_BITS) + 3) >= 0 ? NUM_MID_REGS * ((3 * PRECISION_BITS) + 4) : ((3 * PRECISION_BITS) + 3) + (NUM_MID_REGS * (1 - ((3 * PRECISION_BITS) + 3)))) : (((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3))] mid_pipe_sum_q;
	reg [0:NUM_MID_REGS] mid_pipe_final_sign_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 3) + ((NUM_MID_REGS * 3) - 1) : ((NUM_MID_REGS + 1) * 3) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 3 : 0)] mid_pipe_rnd_mode_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS) + ((NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS) - 1) : ((NUM_MID_REGS + 1) * fpnew_pkg_FP_FORMAT_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * fpnew_pkg_FP_FORMAT_BITS : 0)] mid_pipe_dst_fmt_q;
	reg [0:NUM_MID_REGS] mid_pipe_res_is_spec_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)) + ((NUM_MID_REGS * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)) - 1) : ((NUM_MID_REGS + 1) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) : 0)] mid_pipe_spec_res_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * 5) + ((NUM_MID_REGS * 5) - 1) : ((NUM_MID_REGS + 1) * 5) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * 5 : 0)] mid_pipe_spec_stat_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_MID_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_MID_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] mid_pipe_tag_q;
	reg [(0 >= NUM_MID_REGS ? ((1 - NUM_MID_REGS) * AuxType_AUX_BITS) + ((NUM_MID_REGS * AuxType_AUX_BITS) - 1) : ((NUM_MID_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_MID_REGS ? NUM_MID_REGS * AuxType_AUX_BITS : 0)] mid_pipe_aux_q;
	reg [0:NUM_MID_REGS] mid_pipe_valid_q;
	wire [0:NUM_MID_REGS] mid_pipe_ready;
	wire [1:1] sv2v_tmp_56A72;
	assign sv2v_tmp_56A72 = effective_subtraction;
	always @(*) mid_pipe_eff_sub_q[0] = sv2v_tmp_56A72;
	wire [EXP_WIDTH * 1:1] sv2v_tmp_8565A;
	assign sv2v_tmp_8565A = exponent_product;
	always @(*) mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = sv2v_tmp_8565A;
	wire [EXP_WIDTH * 1:1] sv2v_tmp_F1167;
	assign sv2v_tmp_F1167 = exponent_difference;
	always @(*) mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = sv2v_tmp_F1167;
	wire [EXP_WIDTH * 1:1] sv2v_tmp_19629;
	assign sv2v_tmp_19629 = tentative_exponent;
	always @(*) mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH] = sv2v_tmp_19629;
	wire [SHIFT_AMOUNT_WIDTH * 1:1] sv2v_tmp_037F4;
	assign sv2v_tmp_037F4 = addend_shamt;
	always @(*) mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] = sv2v_tmp_037F4;
	wire [1:1] sv2v_tmp_6F5F7;
	assign sv2v_tmp_6F5F7 = sticky_before_add;
	always @(*) mid_pipe_sticky_q[0] = sv2v_tmp_6F5F7;
	wire [(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)) * 1:1] sv2v_tmp_74CB3;
	assign sv2v_tmp_74CB3 = sum;
	always @(*) mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] = sv2v_tmp_74CB3;
	wire [1:1] sv2v_tmp_D7BD0;
	assign sv2v_tmp_D7BD0 = final_sign;
	always @(*) mid_pipe_final_sign_q[0] = sv2v_tmp_D7BD0;
	wire [3:1] sv2v_tmp_2170E;
	assign sv2v_tmp_2170E = inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3];
	always @(*) mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 3+:3] = sv2v_tmp_2170E;
	wire [3:1] sv2v_tmp_8A4AE;
	assign sv2v_tmp_8A4AE = dst_fmt_q;
	always @(*) mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] = sv2v_tmp_8A4AE;
	wire [1:1] sv2v_tmp_7DEC5;
	assign sv2v_tmp_7DEC5 = result_is_special;
	always @(*) mid_pipe_res_is_spec_q[0] = sv2v_tmp_7DEC5;
	wire [((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS) * 1:1] sv2v_tmp_1ADE6;
	assign sv2v_tmp_1ADE6 = special_result;
	always @(*) mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS] = sv2v_tmp_1ADE6;
	wire [5:1] sv2v_tmp_1A1E3;
	assign sv2v_tmp_1A1E3 = special_status;
	always @(*) mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * 5+:5] = sv2v_tmp_1A1E3;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_F1BD6;
	assign sv2v_tmp_F1BD6 = inp_pipe_tag_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	always @(*) mid_pipe_tag_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_F1BD6;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_B1D3A;
	assign sv2v_tmp_B1D3A = inp_pipe_aux_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	always @(*) mid_pipe_aux_q[(0 >= NUM_MID_REGS ? 0 : NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_B1D3A;
	wire [1:1] sv2v_tmp_CB10A;
	assign sv2v_tmp_CB10A = inp_pipe_valid_q[NUM_INP_REGS];
	always @(*) mid_pipe_valid_q[0] = sv2v_tmp_CB10A;
	assign inp_pipe_ready[NUM_INP_REGS] = mid_pipe_ready[0];
	generate
		for (i = 0; i < NUM_MID_REGS; i = i + 1) begin : gen_inside_pipeline
			wire reg_ena;
			assign mid_pipe_ready[i] = mid_pipe_ready[i + 1] | ~mid_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_valid_q[i + 1] <= 1'b0;
				else
					mid_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (mid_pipe_ready[i] ? mid_pipe_valid_q[i] : mid_pipe_valid_q[i + 1]));
			assign reg_ena = mid_pipe_ready[i] & mid_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_eff_sub_q[i + 1] <= 1'sb0;
				else
					mid_pipe_eff_sub_q[i + 1] <= (reg_ena ? mid_pipe_eff_sub_q[i] : mid_pipe_eff_sub_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= (reg_ena ? mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * EXP_WIDTH+:EXP_WIDTH] : mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= (reg_ena ? mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * EXP_WIDTH+:EXP_WIDTH] : mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= 1'sb0;
				else
					mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH] <= (reg_ena ? mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * EXP_WIDTH+:EXP_WIDTH] : mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * EXP_WIDTH+:EXP_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] <= 1'sb0;
				else
					mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] <= (reg_ena ? mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH] : mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_sticky_q[i + 1] <= 1'sb0;
				else
					mid_pipe_sticky_q[i + 1] <= (reg_ena ? mid_pipe_sticky_q[i] : mid_pipe_sticky_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] <= 1'sb0;
				else
					mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] <= (reg_ena ? mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))] : mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_final_sign_q[i + 1] <= 1'sb0;
				else
					mid_pipe_final_sign_q[i + 1] <= (reg_ena ? mid_pipe_final_sign_q[i] : mid_pipe_final_sign_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3] <= (reg_ena ? mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * 3+:3] : mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= sv2v_cast_5B9B1(0);
				else
					mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] <= (reg_ena ? mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS] : mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_res_is_spec_q[i + 1] <= 1'sb0;
				else
					mid_pipe_res_is_spec_q[i + 1] <= (reg_ena ? mid_pipe_res_is_spec_q[i] : mid_pipe_res_is_spec_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS] <= 1'sb0;
				else
					mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS] <= (reg_ena ? mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS] : mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 5+:5] <= 1'sb0;
				else
					mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 5+:5] <= (reg_ena ? mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * 5+:5] : mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * 5+:5]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_693DA(1'sb0);
				else
					mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : mid_pipe_tag_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_F0E88(1'sb0);
				else
					mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i : NUM_MID_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : mid_pipe_aux_q[(0 >= NUM_MID_REGS ? i + 1 : NUM_MID_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign effective_subtraction_q = mid_pipe_eff_sub_q[NUM_MID_REGS];
	assign exponent_product_q = mid_pipe_exp_prod_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign exponent_difference_q = mid_pipe_exp_diff_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign tentative_exponent_q = mid_pipe_tent_exp_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * EXP_WIDTH+:EXP_WIDTH];
	assign addend_shamt_q = mid_pipe_add_shamt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * SHIFT_AMOUNT_WIDTH+:SHIFT_AMOUNT_WIDTH];
	assign sticky_before_add_q = mid_pipe_sticky_q[NUM_MID_REGS];
	assign sum_q = mid_pipe_sum_q[(((3 * PRECISION_BITS) + 3) >= 0 ? 0 : (3 * PRECISION_BITS) + 3) + ((0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * (((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3)))+:(((3 * PRECISION_BITS) + 3) >= 0 ? (3 * PRECISION_BITS) + 4 : 1 - ((3 * PRECISION_BITS) + 3))];
	assign final_sign_q = mid_pipe_final_sign_q[NUM_MID_REGS];
	assign rnd_mode_q = mid_pipe_rnd_mode_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 3+:3];
	assign dst_fmt_q2 = mid_pipe_dst_fmt_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * fpnew_pkg_FP_FORMAT_BITS+:fpnew_pkg_FP_FORMAT_BITS];
	assign result_is_special_q = mid_pipe_res_is_spec_q[NUM_MID_REGS];
	assign special_result_q = mid_pipe_spec_res_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * ((1 + SUPER_EXP_BITS) + SUPER_MAN_BITS)+:(1 + SUPER_EXP_BITS) + SUPER_MAN_BITS];
	assign special_status_q = mid_pipe_spec_stat_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * 5+:5];
	wire [LOWER_SUM_WIDTH - 1:0] sum_lower;
	wire [LZC_RESULT_WIDTH - 1:0] leading_zero_count;
	wire signed [LZC_RESULT_WIDTH:0] leading_zero_count_sgn;
	wire lzc_zeroes;
	reg [SHIFT_AMOUNT_WIDTH - 1:0] norm_shamt;
	reg signed [EXP_WIDTH - 1:0] normalized_exponent;
	wire [(3 * PRECISION_BITS) + 4:0] sum_shifted;
	reg [PRECISION_BITS:0] final_mantissa;
	reg [(2 * PRECISION_BITS) + 2:0] sum_sticky_bits;
	wire sticky_after_norm;
	reg signed [EXP_WIDTH - 1:0] final_exponent;
	assign sum_lower = sum_q[LOWER_SUM_WIDTH - 1:0];
	lzc #(
		.WIDTH(LOWER_SUM_WIDTH),
		.MODE(1)
	) i_lzc(
		.in_i(sum_lower),
		.cnt_o(leading_zero_count),
		.empty_o(lzc_zeroes)
	);
	assign leading_zero_count_sgn = $signed({1'b0, leading_zero_count});
	always @(*) begin : norm_shift_amount
		if ((exponent_difference_q <= 0) || (effective_subtraction_q && (exponent_difference_q <= 2))) begin
			if ((((exponent_product_q - leading_zero_count_sgn) + 1) >= 0) && !lzc_zeroes) begin
				norm_shamt = (PRECISION_BITS + 2) + leading_zero_count;
				normalized_exponent = (exponent_product_q - leading_zero_count_sgn) + 1;
			end
			else begin
				norm_shamt = $unsigned($signed((PRECISION_BITS + 2) + exponent_product_q));
				normalized_exponent = 0;
			end
		end
		else begin
			norm_shamt = addend_shamt_q;
			normalized_exponent = tentative_exponent_q;
		end
	end
	assign sum_shifted = sum_q << norm_shamt;
	always @(*) begin : small_norm
		{final_mantissa, sum_sticky_bits} = sum_shifted;
		final_exponent = normalized_exponent;
		if (sum_shifted[(3 * PRECISION_BITS) + 4]) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted >> 1;
			final_exponent = normalized_exponent + 1;
		end
		else if (sum_shifted[(3 * PRECISION_BITS) + 3])
			;
		else if (normalized_exponent > 1) begin
			{final_mantissa, sum_sticky_bits} = sum_shifted << 1;
			final_exponent = normalized_exponent - 1;
		end
		else
			final_exponent = 1'sb0;
	end
	assign sticky_after_norm = |{sum_sticky_bits} | sticky_before_add_q;
	wire pre_round_sign;
	wire [(SUPER_EXP_BITS + SUPER_MAN_BITS) - 1:0] pre_round_abs;
	wire [1:0] round_sticky_bits;
	wire of_before_round;
	wire of_after_round;
	wire uf_before_round;
	wire uf_after_round;
	wire [(NUM_FORMATS * (SUPER_EXP_BITS + SUPER_MAN_BITS)) - 1:0] fmt_pre_round_abs;
	wire [9:0] fmt_round_sticky_bits;
	reg [4:0] fmt_of_after_round;
	reg [4:0] fmt_uf_after_round;
	wire rounded_sign;
	wire [(SUPER_EXP_BITS + SUPER_MAN_BITS) - 1:0] rounded_abs;
	wire result_zero;
	assign of_before_round = final_exponent >= ((2 ** fpnew_pkg_exp_bits(dst_fmt_q2)) - 1);
	assign uf_before_round = final_exponent == 0;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_res_assemble
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_5B9B1(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_5B9B1(fmt));
			wire [EXP_BITS - 1:0] pre_round_exponent;
			wire [MAN_BITS - 1:0] pre_round_mantissa;
			if (FpFmtConfig[fmt]) begin : active_format
				assign pre_round_exponent = (of_before_round ? (2 ** EXP_BITS) - 2 : final_exponent[EXP_BITS - 1:0]);
				assign pre_round_mantissa = (of_before_round ? {fpnew_pkg_man_bits(sv2v_cast_5B9B1(fmt)) {1'sb1}} : final_mantissa[SUPER_MAN_BITS-:MAN_BITS]);
				assign fmt_pre_round_abs[fmt * (SUPER_EXP_BITS + SUPER_MAN_BITS)+:SUPER_EXP_BITS + SUPER_MAN_BITS] = {pre_round_exponent, pre_round_mantissa};
				assign fmt_round_sticky_bits[(fmt * 2) + 1] = final_mantissa[SUPER_MAN_BITS - MAN_BITS] | of_before_round;
				if (MAN_BITS < SUPER_MAN_BITS) begin : narrow_sticky
					assign fmt_round_sticky_bits[fmt * 2] = (|final_mantissa[(SUPER_MAN_BITS - MAN_BITS) - 1:0] | sticky_after_norm) | of_before_round;
				end
				else begin : normal_sticky
					assign fmt_round_sticky_bits[fmt * 2] = sticky_after_norm | of_before_round;
				end
			end
			else begin : inactive_format
				assign fmt_pre_round_abs[fmt * (SUPER_EXP_BITS + SUPER_MAN_BITS)+:SUPER_EXP_BITS + SUPER_MAN_BITS] = {SUPER_EXP_BITS + SUPER_MAN_BITS {fpnew_pkg_DONT_CARE}};
				assign fmt_round_sticky_bits[fmt * 2+:2] = {2 {fpnew_pkg_DONT_CARE}};
			end
		end
	endgenerate
	assign pre_round_sign = final_sign_q;
	assign pre_round_abs = fmt_pre_round_abs[dst_fmt_q2 * (SUPER_EXP_BITS + SUPER_MAN_BITS)+:SUPER_EXP_BITS + SUPER_MAN_BITS];
	assign round_sticky_bits = fmt_round_sticky_bits[dst_fmt_q2 * 2+:2];
	fpnew_rounding #(.AbsWidth(SUPER_EXP_BITS + SUPER_MAN_BITS)) i_fpnew_rounding(
		.abs_value_i(pre_round_abs),
		.sign_i(pre_round_sign),
		.round_sticky_bits_i(round_sticky_bits),
		.rnd_mode_i(rnd_mode_q),
		.effective_subtraction_i(effective_subtraction_q),
		.abs_rounded_o(rounded_abs),
		.sign_o(rounded_sign),
		.exact_zero_o(result_zero)
	);
	reg [(NUM_FORMATS * WIDTH) - 1:0] fmt_result;
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_sign_inject
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_5B9B1(fmt));
			localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(sv2v_cast_5B9B1(fmt));
			localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(sv2v_cast_5B9B1(fmt));
			if (FpFmtConfig[fmt]) begin : active_format
				always @(*) begin : post_process
					fmt_uf_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) * 1 {1'sb0}};
					fmt_of_after_round[fmt] = rounded_abs[(EXP_BITS + MAN_BITS) - 1:MAN_BITS] == {(((EXP_BITS + MAN_BITS) - 1) >= MAN_BITS ? (((EXP_BITS + MAN_BITS) - 1) - MAN_BITS) + 1 : (MAN_BITS - ((EXP_BITS + MAN_BITS) - 1)) + 1) * 1 {1'sb1}};
					fmt_result[fmt * WIDTH+:WIDTH] = 1'sb1;
					fmt_result[(fmt * WIDTH) + (FP_WIDTH - 1)-:FP_WIDTH] = {rounded_sign, rounded_abs[(EXP_BITS + MAN_BITS) - 1:0]};
				end
			end
			else begin : inactive_format
				wire [1:1] sv2v_tmp_4A747;
				assign sv2v_tmp_4A747 = fpnew_pkg_DONT_CARE;
				always @(*) fmt_uf_after_round[fmt] = sv2v_tmp_4A747;
				wire [1:1] sv2v_tmp_90681;
				assign sv2v_tmp_90681 = fpnew_pkg_DONT_CARE;
				always @(*) fmt_of_after_round[fmt] = sv2v_tmp_90681;
				wire [WIDTH * 1:1] sv2v_tmp_143A7;
				assign sv2v_tmp_143A7 = {WIDTH {fpnew_pkg_DONT_CARE}};
				always @(*) fmt_result[fmt * WIDTH+:WIDTH] = sv2v_tmp_143A7;
			end
		end
	endgenerate
	assign uf_after_round = fmt_uf_after_round[dst_fmt_q2];
	assign of_after_round = fmt_of_after_round[dst_fmt_q2];
	wire [WIDTH - 1:0] regular_result;
	wire [4:0] regular_status;
	assign regular_result = fmt_result[dst_fmt_q2 * WIDTH+:WIDTH];
	assign regular_status[4] = 1'b0;
	assign regular_status[3] = 1'b0;
	assign regular_status[2] = of_before_round | of_after_round;
	assign regular_status[1] = uf_after_round & regular_status[0];
	assign regular_status[0] = (|round_sticky_bits | of_before_round) | of_after_round;
	wire [WIDTH - 1:0] result_d;
	wire [4:0] status_d;
	assign result_d = (result_is_special_q ? special_result_q : regular_result);
	assign status_d = (result_is_special_q ? special_status_q : regular_status);
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * WIDTH) + ((NUM_OUT_REGS * WIDTH) - 1) : ((NUM_OUT_REGS + 1) * WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * WIDTH : 0)] out_pipe_result_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_OUT_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] out_pipe_tag_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * AuxType_AUX_BITS) + ((NUM_OUT_REGS * AuxType_AUX_BITS) - 1) : ((NUM_OUT_REGS + 1) * AuxType_AUX_BITS) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * AuxType_AUX_BITS : 0)] out_pipe_aux_q;
	reg [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	wire [WIDTH * 1:1] sv2v_tmp_1212D;
	assign sv2v_tmp_1212D = result_d;
	always @(*) out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * WIDTH+:WIDTH] = sv2v_tmp_1212D;
	wire [5:1] sv2v_tmp_F691B;
	assign sv2v_tmp_F691B = status_d;
	always @(*) out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = sv2v_tmp_F691B;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_11E81;
	assign sv2v_tmp_11E81 = mid_pipe_tag_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	always @(*) out_pipe_tag_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_11E81;
	wire [AuxType_AUX_BITS * 1:1] sv2v_tmp_E3795;
	assign sv2v_tmp_E3795 = mid_pipe_aux_q[(0 >= NUM_MID_REGS ? NUM_MID_REGS : NUM_MID_REGS - NUM_MID_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	always @(*) out_pipe_aux_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS] = sv2v_tmp_E3795;
	wire [1:1] sv2v_tmp_25EE6;
	assign sv2v_tmp_25EE6 = mid_pipe_valid_q[NUM_MID_REGS];
	always @(*) out_pipe_valid_q[0] = sv2v_tmp_25EE6;
	assign mid_pipe_ready[NUM_MID_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_valid_q[i + 1] <= 1'b0;
				else
					out_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (out_pipe_ready[i] ? out_pipe_valid_q[i] : out_pipe_valid_q[i + 1]));
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH] <= 1'sb0;
				else
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH] <= (reg_ena ? out_pipe_result_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * WIDTH+:WIDTH] : out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * WIDTH+:WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= 1'sb0;
				else
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= (reg_ena ? out_pipe_status_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * 5+:5] : out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_693DA(1'sb0);
				else
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= sv2v_cast_F0E88(1'sb0);
				else
					out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS] <= (reg_ena ? out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * AuxType_AUX_BITS+:AuxType_AUX_BITS] : out_pipe_aux_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * AuxType_AUX_BITS+:AuxType_AUX_BITS]);
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * WIDTH+:WIDTH];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = 1'b1;
	assign tag_o = out_pipe_tag_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	assign aux_o = out_pipe_aux_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * AuxType_AUX_BITS+:AuxType_AUX_BITS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, mid_pipe_valid_q, out_pipe_valid_q};
endmodule
module fpnew_noncomp_8EF6A_8033C (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	tag_i,
	aux_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	class_mask_o,
	is_class_o,
	tag_o,
	aux_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter signed [31:0] TagType_TagType_TagType_TagType_TAG_WIDTH = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	function automatic [2:0] sv2v_cast_8C4B1;
		input reg [2:0] inp;
		sv2v_cast_8C4B1 = inp;
	endfunction
	parameter [2:0] FpFormat = sv2v_cast_8C4B1(0);
	parameter [31:0] NumPipeRegs = 0;
	parameter [1:0] PipeConfig = 2'd0;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] WIDTH = fpnew_pkg_fp_width(FpFormat);
	input wire clk_i;
	input wire rst_ni;
	input wire [(2 * WIDTH) - 1:0] operands_i;
	input wire [1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire aux_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire [9:0] class_mask_o;
	output wire is_class_o;
	output wire [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire aux_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	function automatic [31:0] fpnew_pkg_exp_bits;
		input reg [2:0] fmt;
		fpnew_pkg_exp_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32];
	endfunction
	localparam [31:0] EXP_BITS = fpnew_pkg_exp_bits(FpFormat);
	function automatic [31:0] fpnew_pkg_man_bits;
		input reg [2:0] fmt;
		fpnew_pkg_man_bits = fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32];
	endfunction
	localparam [31:0] MAN_BITS = fpnew_pkg_man_bits(FpFormat);
	localparam NUM_INP_REGS = ((PipeConfig == 2'd0) || (PipeConfig == 2'd2) ? NumPipeRegs : (PipeConfig == 2'd3 ? (NumPipeRegs + 1) / 2 : 0));
	localparam NUM_OUT_REGS = (PipeConfig == 2'd1 ? NumPipeRegs : (PipeConfig == 2'd3 ? NumPipeRegs / 2 : 0));
	reg [((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) - (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH) - 1) : ((((0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)) + 1) * WIDTH) + (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH) - 1)):((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) * WIDTH : (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) * WIDTH)] inp_pipe_operands_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0)] inp_pipe_is_boxed_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 3) + ((NUM_INP_REGS * 3) - 1) : ((NUM_INP_REGS + 1) * 3) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * 3 : 0)] inp_pipe_rnd_mode_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * fpnew_pkg_OP_BITS) + ((NUM_INP_REGS * fpnew_pkg_OP_BITS) - 1) : ((NUM_INP_REGS + 1) * fpnew_pkg_OP_BITS) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * fpnew_pkg_OP_BITS : 0)] inp_pipe_op_q;
	reg [0:NUM_INP_REGS] inp_pipe_op_mod_q;
	reg [(0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_INP_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_INP_REGS ? NUM_INP_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] inp_pipe_tag_q;
	reg [0:NUM_INP_REGS] inp_pipe_aux_q;
	reg [0:NUM_INP_REGS] inp_pipe_valid_q;
	wire [0:NUM_INP_REGS] inp_pipe_ready;
	wire [2 * WIDTH:1] sv2v_tmp_D1067;
	assign sv2v_tmp_D1067 = operands_i;
	always @(*) inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] = sv2v_tmp_D1067;
	wire [2:1] sv2v_tmp_86D63;
	assign sv2v_tmp_86D63 = is_boxed_i;
	always @(*) inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 2+:2] = sv2v_tmp_86D63;
	wire [3:1] sv2v_tmp_62109;
	assign sv2v_tmp_62109 = rnd_mode_i;
	always @(*) inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * 3+:3] = sv2v_tmp_62109;
	wire [4:1] sv2v_tmp_0B797;
	assign sv2v_tmp_0B797 = op_i;
	always @(*) inp_pipe_op_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] = sv2v_tmp_0B797;
	wire [1:1] sv2v_tmp_D1C37;
	assign sv2v_tmp_D1C37 = op_mod_i;
	always @(*) inp_pipe_op_mod_q[0] = sv2v_tmp_D1C37;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_488B7;
	assign sv2v_tmp_488B7 = tag_i;
	always @(*) inp_pipe_tag_q[(0 >= NUM_INP_REGS ? 0 : NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_488B7;
	wire [1:1] sv2v_tmp_8D189;
	assign sv2v_tmp_8D189 = aux_i;
	always @(*) inp_pipe_aux_q[0] = sv2v_tmp_8D189;
	wire [1:1] sv2v_tmp_73AEA;
	assign sv2v_tmp_73AEA = in_valid_i;
	always @(*) inp_pipe_valid_q[0] = sv2v_tmp_73AEA;
	assign in_ready_o = inp_pipe_ready[0];
	genvar i;
	function automatic [3:0] sv2v_cast_5336D;
		input reg [3:0] inp;
		sv2v_cast_5336D = inp;
	endfunction
	function automatic [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] sv2v_cast_8DDC8;
		input reg [TagType_TagType_TagType_TagType_TAG_WIDTH - 1:0] inp;
		sv2v_cast_8DDC8 = inp;
	endfunction
	generate
		for (i = 0; i < NUM_INP_REGS; i = i + 1) begin : gen_input_pipeline
			wire reg_ena;
			assign inp_pipe_ready[i] = inp_pipe_ready[i + 1] | ~inp_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_valid_q[i + 1] <= 1'b0;
				else
					inp_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (inp_pipe_ready[i] ? inp_pipe_valid_q[i] : inp_pipe_valid_q[i + 1]));
			assign reg_ena = inp_pipe_ready[i] & inp_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] <= 1'sb0;
				else
					inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] <= (reg_ena ? inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2 : ((0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2] : inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2 : ((0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2+:2] <= 1'sb0;
				else
					inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2+:2] <= (reg_ena ? inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 2+:2] : inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 2+:2]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= 3'b000;
				else
					inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3] <= (reg_ena ? inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * 3+:3] : inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * 3+:3]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= sv2v_cast_5336D(0);
				else
					inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] <= (reg_ena ? inp_pipe_op_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] : inp_pipe_op_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_op_mod_q[i + 1] <= 1'sb0;
				else
					inp_pipe_op_mod_q[i + 1] <= (reg_ena ? inp_pipe_op_mod_q[i] : inp_pipe_op_mod_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_8DDC8(1'sb0);
				else
					inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i : NUM_INP_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : inp_pipe_tag_q[(0 >= NUM_INP_REGS ? i + 1 : NUM_INP_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					inp_pipe_aux_q[i + 1] <= 1'b0;
				else
					inp_pipe_aux_q[i + 1] <= (reg_ena ? inp_pipe_aux_q[i] : inp_pipe_aux_q[i + 1]);
		end
	endgenerate
	wire [15:0] info_q;
	fpnew_classifier #(
		.FpFormat(FpFormat),
		.NumOperands(2)
	) i_class_a(
		.operands_i(inp_pipe_operands_q[WIDTH * ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1)))+:WIDTH * 2]),
		.is_boxed_i(inp_pipe_is_boxed_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2+:2]),
		.info_o(info_q)
	);
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_a;
	wire [((1 + EXP_BITS) + MAN_BITS) - 1:0] operand_b;
	wire [7:0] info_a;
	wire [7:0] info_b;
	assign operand_a = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? (0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - (((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1))) * WIDTH+:WIDTH];
	assign operand_b = inp_pipe_operands_q[((0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1) >= (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) ? ((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1 : (0 >= NUM_INP_REGS ? NUM_INP_REGS * 2 : 0) - ((((0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 2) + 1) - (0 >= NUM_INP_REGS ? ((1 - NUM_INP_REGS) * 2) + ((NUM_INP_REGS * 2) - 1) : ((NUM_INP_REGS + 1) * 2) - 1))) * WIDTH+:WIDTH];
	assign info_a = info_q[0+:8];
	assign info_b = info_q[8+:8];
	wire any_operand_inf;
	wire any_operand_nan;
	wire signalling_nan;
	assign any_operand_inf = |{info_a[4], info_b[4]};
	assign any_operand_nan = |{info_a[3], info_b[3]};
	assign signalling_nan = |{info_a[2], info_b[2]};
	wire operands_equal;
	wire operand_a_smaller;
	assign operands_equal = (operand_a == operand_b) || (info_a[5] && info_b[5]);
	assign operand_a_smaller = (operand_a < operand_b) ^ (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] || operand_b[1 + (EXP_BITS + (MAN_BITS - 1))]);
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] sgnj_result;
	wire [4:0] sgnj_status;
	wire sgnj_extension_bit;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	function automatic [EXP_BITS - 1:0] sv2v_cast_F2D56;
		input reg [EXP_BITS - 1:0] inp;
		sv2v_cast_F2D56 = inp;
	endfunction
	function automatic [MAN_BITS - 1:0] sv2v_cast_AA557;
		input reg [MAN_BITS - 1:0] inp;
		sv2v_cast_AA557 = inp;
	endfunction
	always @(*) begin : sign_injections
		reg sign_a;
		reg sign_b;
		sgnj_result = operand_a;
		if (!info_a[0])
			sgnj_result = {1'b0, sv2v_cast_F2D56(1'sb1), sv2v_cast_AA557(2 ** (MAN_BITS - 1))};
		sign_a = operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] & info_a[0];
		sign_b = operand_b[1 + (EXP_BITS + (MAN_BITS - 1))] & info_b[0];
		case (inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3])
			3'b000: sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] = sign_b;
			3'b001: sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] = ~sign_b;
			3'b010: sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] = sign_a ^ sign_b;
			3'b011: sgnj_result = operand_a;
			default: sgnj_result = {fpnew_pkg_DONT_CARE, sv2v_cast_F2D56(fpnew_pkg_DONT_CARE), sv2v_cast_AA557(fpnew_pkg_DONT_CARE)};
		endcase
	end
	assign sgnj_status = 1'sb0;
	assign sgnj_extension_bit = (inp_pipe_op_mod_q[NUM_INP_REGS] ? sgnj_result[1 + (EXP_BITS + (MAN_BITS - 1))] : 1'b1);
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] minmax_result;
	reg [4:0] minmax_status;
	wire minmax_extension_bit;
	always @(*) begin : min_max
		minmax_status = 1'sb0;
		minmax_status[4] = signalling_nan;
		if (info_a[3] && info_b[3])
			minmax_result = {1'b0, sv2v_cast_F2D56(1'sb1), sv2v_cast_AA557(2 ** (MAN_BITS - 1))};
		else if (info_a[3])
			minmax_result = operand_b;
		else if (info_b[3])
			minmax_result = operand_a;
		else
			case (inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3])
				3'b000: minmax_result = (operand_a_smaller ? operand_a : operand_b);
				3'b001: minmax_result = (operand_a_smaller ? operand_b : operand_a);
				default: minmax_result = {fpnew_pkg_DONT_CARE, sv2v_cast_F2D56(fpnew_pkg_DONT_CARE), sv2v_cast_AA557(fpnew_pkg_DONT_CARE)};
			endcase
	end
	assign minmax_extension_bit = 1'b1;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] cmp_result;
	reg [4:0] cmp_status;
	wire cmp_extension_bit;
	always @(*) begin : comparisons
		cmp_result = 1'sb0;
		cmp_status = 1'sb0;
		if (signalling_nan)
			cmp_status[4] = 1'b1;
		else
			case (inp_pipe_rnd_mode_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * 3+:3])
				3'b000:
					if (any_operand_nan)
						cmp_status[4] = 1'b1;
					else
						cmp_result = (operand_a_smaller | operands_equal) ^ inp_pipe_op_mod_q[NUM_INP_REGS];
				3'b001:
					if (any_operand_nan)
						cmp_status[4] = 1'b1;
					else
						cmp_result = (operand_a_smaller & ~operands_equal) ^ inp_pipe_op_mod_q[NUM_INP_REGS];
				3'b010:
					if (any_operand_nan)
						cmp_result = inp_pipe_op_mod_q[NUM_INP_REGS];
					else
						cmp_result = operands_equal ^ inp_pipe_op_mod_q[NUM_INP_REGS];
				default: cmp_result = {fpnew_pkg_DONT_CARE, sv2v_cast_F2D56(fpnew_pkg_DONT_CARE), sv2v_cast_AA557(fpnew_pkg_DONT_CARE)};
			endcase
	end
	assign cmp_extension_bit = 1'b0;
	wire [4:0] class_status;
	wire class_extension_bit;
	reg [9:0] class_mask_d;
	always @(*) begin : classify
		if (info_a[7])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? 10'b0000000010 : 10'b0001000000);
		else if (info_a[6])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? 10'b0000000100 : 10'b0000100000);
		else if (info_a[5])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? 10'b0000001000 : 10'b0000010000);
		else if (info_a[4])
			class_mask_d = (operand_a[1 + (EXP_BITS + (MAN_BITS - 1))] ? 10'b0000000001 : 10'b0010000000);
		else if (info_a[3])
			class_mask_d = (info_a[2] ? 10'b0100000000 : 10'b1000000000);
		else
			class_mask_d = 10'b1000000000;
	end
	assign class_status = 1'sb0;
	assign class_extension_bit = 1'b0;
	reg [((1 + EXP_BITS) + MAN_BITS) - 1:0] result_d;
	reg [4:0] status_d;
	reg extension_bit_d;
	wire is_class_d;
	always @(*) begin : select_result
		case (inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS])
			sv2v_cast_5336D(6): begin
				result_d = sgnj_result;
				status_d = sgnj_status;
				extension_bit_d = sgnj_extension_bit;
			end
			sv2v_cast_5336D(7): begin
				result_d = minmax_result;
				status_d = minmax_status;
				extension_bit_d = minmax_extension_bit;
			end
			sv2v_cast_5336D(8): begin
				result_d = cmp_result;
				status_d = cmp_status;
				extension_bit_d = cmp_extension_bit;
			end
			sv2v_cast_5336D(9): begin
				result_d = {fpnew_pkg_DONT_CARE, sv2v_cast_F2D56(fpnew_pkg_DONT_CARE), sv2v_cast_AA557(fpnew_pkg_DONT_CARE)};
				status_d = class_status;
				extension_bit_d = class_extension_bit;
			end
			default: begin
				result_d = {fpnew_pkg_DONT_CARE, sv2v_cast_F2D56(fpnew_pkg_DONT_CARE), sv2v_cast_AA557(fpnew_pkg_DONT_CARE)};
				status_d = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				extension_bit_d = fpnew_pkg_DONT_CARE;
			end
		endcase
	end
	assign is_class_d = inp_pipe_op_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * fpnew_pkg_OP_BITS+:fpnew_pkg_OP_BITS] == sv2v_cast_5336D(9);
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)) + ((NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS)) - 1) : ((NUM_OUT_REGS + 1) * ((1 + EXP_BITS) + MAN_BITS)) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * ((1 + EXP_BITS) + MAN_BITS) : 0)] out_pipe_result_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 5) + ((NUM_OUT_REGS * 5) - 1) : ((NUM_OUT_REGS + 1) * 5) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 5 : 0)] out_pipe_status_q;
	reg [0:NUM_OUT_REGS] out_pipe_extension_bit_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * 10) + ((NUM_OUT_REGS * 10) - 1) : ((NUM_OUT_REGS + 1) * 10) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * 10 : 0)] out_pipe_class_mask_q;
	reg [0:NUM_OUT_REGS] out_pipe_is_class_q;
	reg [(0 >= NUM_OUT_REGS ? ((1 - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH) + ((NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1) : ((NUM_OUT_REGS + 1) * TagType_TagType_TagType_TagType_TAG_WIDTH) - 1):(0 >= NUM_OUT_REGS ? NUM_OUT_REGS * TagType_TagType_TagType_TagType_TAG_WIDTH : 0)] out_pipe_tag_q;
	reg [0:NUM_OUT_REGS] out_pipe_aux_q;
	reg [0:NUM_OUT_REGS] out_pipe_valid_q;
	wire [0:NUM_OUT_REGS] out_pipe_ready;
	wire [((1 + EXP_BITS) + MAN_BITS) * 1:1] sv2v_tmp_07494;
	assign sv2v_tmp_07494 = result_d;
	always @(*) out_pipe_result_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] = sv2v_tmp_07494;
	wire [5:1] sv2v_tmp_CCE43;
	assign sv2v_tmp_CCE43 = status_d;
	always @(*) out_pipe_status_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 5+:5] = sv2v_tmp_CCE43;
	wire [1:1] sv2v_tmp_8E9A9;
	assign sv2v_tmp_8E9A9 = extension_bit_d;
	always @(*) out_pipe_extension_bit_q[0] = sv2v_tmp_8E9A9;
	wire [10:1] sv2v_tmp_94259;
	assign sv2v_tmp_94259 = class_mask_d;
	always @(*) out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * 10+:10] = sv2v_tmp_94259;
	wire [1:1] sv2v_tmp_7DF01;
	assign sv2v_tmp_7DF01 = is_class_d;
	always @(*) out_pipe_is_class_q[0] = sv2v_tmp_7DF01;
	wire [TagType_TagType_TagType_TagType_TAG_WIDTH * 1:1] sv2v_tmp_93CB4;
	assign sv2v_tmp_93CB4 = inp_pipe_tag_q[(0 >= NUM_INP_REGS ? NUM_INP_REGS : NUM_INP_REGS - NUM_INP_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	always @(*) out_pipe_tag_q[(0 >= NUM_OUT_REGS ? 0 : NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] = sv2v_tmp_93CB4;
	wire [1:1] sv2v_tmp_FA930;
	assign sv2v_tmp_FA930 = inp_pipe_aux_q[NUM_INP_REGS];
	always @(*) out_pipe_aux_q[0] = sv2v_tmp_FA930;
	wire [1:1] sv2v_tmp_2CB8C;
	assign sv2v_tmp_2CB8C = inp_pipe_valid_q[NUM_INP_REGS];
	always @(*) out_pipe_valid_q[0] = sv2v_tmp_2CB8C;
	assign inp_pipe_ready[NUM_INP_REGS] = out_pipe_ready[0];
	generate
		for (i = 0; i < NUM_OUT_REGS; i = i + 1) begin : gen_output_pipeline
			wire reg_ena;
			assign out_pipe_ready[i] = out_pipe_ready[i + 1] | ~out_pipe_valid_q[i + 1];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_valid_q[i + 1] <= 1'b0;
				else
					out_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (out_pipe_ready[i] ? out_pipe_valid_q[i] : out_pipe_valid_q[i + 1]));
			assign reg_ena = out_pipe_ready[i] & out_pipe_valid_q[i];
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] <= 1'sb0;
				else
					out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] <= (reg_ena ? out_pipe_result_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS] : out_pipe_result_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= 1'sb0;
				else
					out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5] <= (reg_ena ? out_pipe_status_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * 5+:5] : out_pipe_status_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 5+:5]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_extension_bit_q[i + 1] <= 1'sb0;
				else
					out_pipe_extension_bit_q[i + 1] <= (reg_ena ? out_pipe_extension_bit_q[i] : out_pipe_extension_bit_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 10+:10] <= 10'b1000000000;
				else
					out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 10+:10] <= (reg_ena ? out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * 10+:10] : out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * 10+:10]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_is_class_q[i + 1] <= 1'sb0;
				else
					out_pipe_is_class_q[i + 1] <= (reg_ena ? out_pipe_is_class_q[i] : out_pipe_is_class_q[i + 1]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= sv2v_cast_8DDC8(1'sb0);
				else
					out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] <= (reg_ena ? out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i : NUM_OUT_REGS - i) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH] : out_pipe_tag_q[(0 >= NUM_OUT_REGS ? i + 1 : NUM_OUT_REGS - (i + 1)) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH]);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					out_pipe_aux_q[i + 1] <= 1'b0;
				else
					out_pipe_aux_q[i + 1] <= (reg_ena ? out_pipe_aux_q[i] : out_pipe_aux_q[i + 1]);
		end
	endgenerate
	assign out_pipe_ready[NUM_OUT_REGS] = out_ready_i;
	assign result_o = out_pipe_result_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * ((1 + EXP_BITS) + MAN_BITS)+:(1 + EXP_BITS) + MAN_BITS];
	assign status_o = out_pipe_status_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 5+:5];
	assign extension_bit_o = out_pipe_extension_bit_q[NUM_OUT_REGS];
	assign class_mask_o = out_pipe_class_mask_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * 10+:10];
	assign is_class_o = out_pipe_is_class_q[NUM_OUT_REGS];
	assign tag_o = out_pipe_tag_q[(0 >= NUM_OUT_REGS ? NUM_OUT_REGS : NUM_OUT_REGS - NUM_OUT_REGS) * TagType_TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TagType_TAG_WIDTH];
	assign aux_o = out_pipe_aux_q[NUM_OUT_REGS];
	assign out_valid_o = out_pipe_valid_q[NUM_OUT_REGS];
	assign busy_o = |{inp_pipe_valid_q, out_pipe_valid_q};
endmodule
module fpnew_opgroup_block_A94B6_B7406 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter signed [31:0] TagType_TagType_TAG_WIDTH = 0;
	parameter [1:0] OpGroup = 2'd0;
	parameter [31:0] Width = 32;
	parameter [0:0] EnableVectors = 1'b1;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	parameter [0:4] FpFmtMask = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtMask = 1'sb1;
	parameter [159:0] FmtPipeRegs = {fpnew_pkg_NUM_FP_FORMATS {32'd0}};
	parameter [9:0] FmtUnitTypes = {fpnew_pkg_NUM_FP_FORMATS {2'd1}};
	parameter [1:0] PipeConfig = 2'd0;
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			2'd0: fpnew_pkg_num_operands = 3;
			2'd1: fpnew_pkg_num_operands = 2;
			2'd2: fpnew_pkg_num_operands = 2;
			2'd3: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	input wire [2:0] src_fmt_i;
	input wire [2:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire [TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [Width - 1:0] result_o;
	output wire [4:0] status_o;
	output wire extension_bit_o;
	output wire [TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	wire [4:0] fmt_in_ready;
	wire [4:0] fmt_out_valid;
	wire [4:0] fmt_out_ready;
	wire [4:0] fmt_busy;
	wire [(5 * ((Width + 6) + TagType_TagType_TAG_WIDTH)) - 1:0] fmt_outputs;
	assign in_ready_o = in_valid_i & fmt_in_ready[dst_fmt_i];
	genvar fmt;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	function automatic fpnew_pkg_any_enabled_multi;
		input reg [9:0] types;
		input reg [0:4] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(4 - i) * 2+:2] == 2'd2)) begin
							fpnew_pkg_any_enabled_multi = 1'b1;
							_sv2v_jump = 2'b11;
						end
					end
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_any_enabled_multi = 1'b0;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic [2:0] sv2v_cast_ED77B;
		input reg [2:0] inp;
		sv2v_cast_ED77B = inp;
	endfunction
	function automatic [2:0] fpnew_pkg_get_first_enabled_multi;
		input reg [9:0] types;
		input reg [0:4] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_2
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(4 - i) * 2+:2] == 2'd2)) begin
							fpnew_pkg_get_first_enabled_multi = sv2v_cast_ED77B(i);
							_sv2v_jump = 2'b11;
						end
					end
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_get_first_enabled_multi = sv2v_cast_ED77B(0);
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic fpnew_pkg_is_first_enabled_multi;
		input reg [2:0] fmt;
		input reg [9:0] types;
		input reg [0:4] cfg;
		reg [0:1] _sv2v_jump;
		begin
			_sv2v_jump = 2'b00;
			begin : sv2v_autoblock_3
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (_sv2v_jump < 2'b10) begin
						_sv2v_jump = 2'b00;
						if (cfg[i] && (types[(4 - i) * 2+:2] == 2'd2)) begin
							fpnew_pkg_is_first_enabled_multi = sv2v_cast_ED77B(i) == fmt;
							_sv2v_jump = 2'b11;
						end
					end
				if (_sv2v_jump != 2'b11)
					_sv2v_jump = 2'b00;
			end
			if (_sv2v_jump == 2'b00) begin
				fpnew_pkg_is_first_enabled_multi = 1'b0;
				_sv2v_jump = 2'b11;
			end
		end
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	function automatic [TagType_TagType_TAG_WIDTH - 1:0] sv2v_cast_3C72E;
		input reg [TagType_TagType_TAG_WIDTH - 1:0] inp;
		sv2v_cast_3C72E = inp;
	endfunction
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_parallel_slices
			localparam [0:0] ANY_MERGED = fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask);
			localparam [0:0] IS_FIRST_MERGED = fpnew_pkg_is_first_enabled_multi(sv2v_cast_ED77B(fmt), FmtUnitTypes, FpFmtMask);
			if (FpFmtMask[fmt] && (FmtUnitTypes[(4 - fmt) * 2+:2] == 2'd1)) begin : active_format
				wire in_valid;
				assign in_valid = in_valid_i & (dst_fmt_i == fmt);
				fpnew_opgroup_fmt_slice_E368D_75924 #(
					.TagType_TagType_TagType_TAG_WIDTH(TagType_TagType_TAG_WIDTH),
					.OpGroup(OpGroup),
					.FpFormat(sv2v_cast_ED77B(fmt)),
					.Width(Width),
					.EnableVectors(EnableVectors),
					.NumPipeRegs(FmtPipeRegs[(4 - fmt) * 32+:32]),
					.PipeConfig(PipeConfig)
				) i_fmt_slice(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.operands_i(operands_i),
					.is_boxed_i(is_boxed_i[fmt * NUM_OPERANDS+:NUM_OPERANDS]),
					.rnd_mode_i(rnd_mode_i),
					.op_i(op_i),
					.op_mod_i(op_mod_i),
					.vectorial_op_i(vectorial_op_i),
					.tag_i(tag_i),
					.in_valid_i(in_valid),
					.in_ready_o(fmt_in_ready[fmt]),
					.flush_i(flush_i),
					.result_o(fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (Width + (TagType_TagType_TAG_WIDTH + 5))-:((Width + (TagType_TagType_TAG_WIDTH + 5)) >= (6 + (TagType_TagType_TAG_WIDTH + 0)) ? ((Width + (TagType_TagType_TAG_WIDTH + 5)) - (6 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((6 + (TagType_TagType_TAG_WIDTH + 0)) - (Width + (TagType_TagType_TAG_WIDTH + 5))) + 1)]),
					.status_o(fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 5)-:((TagType_TagType_TAG_WIDTH + 5) >= (1 + (TagType_TagType_TAG_WIDTH + 0)) ? ((TagType_TagType_TAG_WIDTH + 5) - (1 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((1 + (TagType_TagType_TAG_WIDTH + 0)) - (TagType_TagType_TAG_WIDTH + 5)) + 1)]),
					.extension_bit_o(fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 0)]),
					.tag_o(fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH - 1)-:TagType_TagType_TAG_WIDTH]),
					.out_valid_o(fmt_out_valid[fmt]),
					.out_ready_i(fmt_out_ready[fmt]),
					.busy_o(fmt_busy[fmt])
				);
			end
			else if ((FpFmtMask[fmt] && ANY_MERGED) && !IS_FIRST_MERGED) begin : merged_unused
				localparam FMT = fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask);
				assign fmt_in_ready[fmt] = fmt_in_ready[sv2v_cast_32_signed(FMT)];
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (Width + (TagType_TagType_TAG_WIDTH + 5))-:((Width + (TagType_TagType_TAG_WIDTH + 5)) >= (6 + (TagType_TagType_TAG_WIDTH + 0)) ? ((Width + (TagType_TagType_TAG_WIDTH + 5)) - (6 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((6 + (TagType_TagType_TAG_WIDTH + 0)) - (Width + (TagType_TagType_TAG_WIDTH + 5))) + 1)] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 5)-:((TagType_TagType_TAG_WIDTH + 5) >= (1 + (TagType_TagType_TAG_WIDTH + 0)) ? ((TagType_TagType_TAG_WIDTH + 5) - (1 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((1 + (TagType_TagType_TAG_WIDTH + 0)) - (TagType_TagType_TAG_WIDTH + 5)) + 1)] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 0)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH - 1)-:TagType_TagType_TAG_WIDTH] = sv2v_cast_3C72E(fpnew_pkg_DONT_CARE);
			end
			else if (!FpFmtMask[fmt] || (FmtUnitTypes[(4 - fmt) * 2+:2] == 2'd0)) begin : disable_fmt
				assign fmt_in_ready[fmt] = 1'b0;
				assign fmt_out_valid[fmt] = 1'b0;
				assign fmt_busy[fmt] = 1'b0;
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (Width + (TagType_TagType_TAG_WIDTH + 5))-:((Width + (TagType_TagType_TAG_WIDTH + 5)) >= (6 + (TagType_TagType_TAG_WIDTH + 0)) ? ((Width + (TagType_TagType_TAG_WIDTH + 5)) - (6 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((6 + (TagType_TagType_TAG_WIDTH + 0)) - (Width + (TagType_TagType_TAG_WIDTH + 5))) + 1)] = {Width {fpnew_pkg_DONT_CARE}};
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 5)-:((TagType_TagType_TAG_WIDTH + 5) >= (1 + (TagType_TagType_TAG_WIDTH + 0)) ? ((TagType_TagType_TAG_WIDTH + 5) - (1 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((1 + (TagType_TagType_TAG_WIDTH + 0)) - (TagType_TagType_TAG_WIDTH + 5)) + 1)] = {fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE, fpnew_pkg_DONT_CARE};
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 0)] = fpnew_pkg_DONT_CARE;
				assign fmt_outputs[(fmt * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH - 1)-:TagType_TagType_TAG_WIDTH] = sv2v_cast_3C72E(fpnew_pkg_DONT_CARE);
			end
		end
	endgenerate
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [31:0] fpnew_pkg_get_num_regs_multi;
		input reg [159:0] regs;
		input reg [9:0] types;
		input reg [0:4] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_4
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i] && (types[(4 - i) * 2+:2] == 2'd2))
						res = fpnew_pkg_maximum(res, regs[(4 - i) * 32+:32]);
			end
			fpnew_pkg_get_num_regs_multi = res;
		end
	endfunction
	generate
		if (fpnew_pkg_any_enabled_multi(FmtUnitTypes, FpFmtMask)) begin : gen_merged_slice
			localparam FMT = fpnew_pkg_get_first_enabled_multi(FmtUnitTypes, FpFmtMask);
			localparam REG = fpnew_pkg_get_num_regs_multi(FmtPipeRegs, FmtUnitTypes, FpFmtMask);
			wire in_valid;
			assign in_valid = in_valid_i & (FmtUnitTypes[(4 - dst_fmt_i) * 2+:2] == 2'd2);
			fpnew_opgroup_multifmt_slice_607F1_85D30 #(
				.TagType_TagType_TagType_TAG_WIDTH(TagType_TagType_TAG_WIDTH),
				.OpGroup(OpGroup),
				.Width(Width),
				.FpFmtConfig(FpFmtMask),
				.IntFmtConfig(IntFmtMask),
				.EnableVectors(EnableVectors),
				.NumPipeRegs(REG),
				.PipeConfig(PipeConfig)
			) i_multifmt_slice(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(operands_i),
				.is_boxed_i(is_boxed_i),
				.rnd_mode_i(rnd_mode_i),
				.op_i(op_i),
				.op_mod_i(op_mod_i),
				.src_fmt_i(src_fmt_i),
				.dst_fmt_i(dst_fmt_i),
				.int_fmt_i(int_fmt_i),
				.vectorial_op_i(vectorial_op_i),
				.tag_i(tag_i),
				.in_valid_i(in_valid),
				.in_ready_o(fmt_in_ready[FMT]),
				.flush_i(flush_i),
				.result_o(fmt_outputs[(FMT * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (Width + (TagType_TagType_TAG_WIDTH + 5))-:((Width + (TagType_TagType_TAG_WIDTH + 5)) >= (6 + (TagType_TagType_TAG_WIDTH + 0)) ? ((Width + (TagType_TagType_TAG_WIDTH + 5)) - (6 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((6 + (TagType_TagType_TAG_WIDTH + 0)) - (Width + (TagType_TagType_TAG_WIDTH + 5))) + 1)]),
				.status_o(fmt_outputs[(FMT * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 5)-:((TagType_TagType_TAG_WIDTH + 5) >= (1 + (TagType_TagType_TAG_WIDTH + 0)) ? ((TagType_TagType_TAG_WIDTH + 5) - (1 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((1 + (TagType_TagType_TAG_WIDTH + 0)) - (TagType_TagType_TAG_WIDTH + 5)) + 1)]),
				.extension_bit_o(fmt_outputs[(FMT * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH + 0)]),
				.tag_o(fmt_outputs[(FMT * ((Width + 6) + TagType_TagType_TAG_WIDTH)) + (TagType_TagType_TAG_WIDTH - 1)-:TagType_TagType_TAG_WIDTH]),
				.out_valid_o(fmt_out_valid[FMT]),
				.out_ready_i(fmt_out_ready[FMT]),
				.busy_o(fmt_busy[FMT])
			);
		end
	endgenerate
	wire [((Width + 6) + TagType_TagType_TAG_WIDTH) - 1:0] arbiter_output;
	localparam [31:0] sv2v_uu_i_arbiter_NumIn = NUM_FORMATS;
	localparam [31:0] sv2v_uu_i_arbiter_IdxWidth = (sv2v_uu_i_arbiter_NumIn > 32'd1 ? $unsigned(3) : 32'd1);
	localparam [sv2v_uu_i_arbiter_IdxWidth - 1:0] sv2v_uu_i_arbiter_ext_rr_i_0 = 1'sb0;
	rr_arb_tree_52163_F264E #(
		.DataType_TagType_TagType_TAG_WIDTH(TagType_TagType_TAG_WIDTH),
		.DataType_Width(Width),
		.NumIn(NUM_FORMATS),
		.AxiVldRdy(1'b1)
	) i_arbiter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i(sv2v_uu_i_arbiter_ext_rr_i_0),
		.req_i(fmt_out_valid),
		.gnt_o(fmt_out_ready),
		.data_i(fmt_outputs),
		.gnt_i(out_ready_i),
		.req_o(out_valid_o),
		.data_o(arbiter_output)
	);
	assign result_o = arbiter_output[Width + (TagType_TagType_TAG_WIDTH + 5)-:((Width + (TagType_TagType_TAG_WIDTH + 5)) >= (6 + (TagType_TagType_TAG_WIDTH + 0)) ? ((Width + (TagType_TagType_TAG_WIDTH + 5)) - (6 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((6 + (TagType_TagType_TAG_WIDTH + 0)) - (Width + (TagType_TagType_TAG_WIDTH + 5))) + 1)];
	assign status_o = arbiter_output[TagType_TagType_TAG_WIDTH + 5-:((TagType_TagType_TAG_WIDTH + 5) >= (1 + (TagType_TagType_TAG_WIDTH + 0)) ? ((TagType_TagType_TAG_WIDTH + 5) - (1 + (TagType_TagType_TAG_WIDTH + 0))) + 1 : ((1 + (TagType_TagType_TAG_WIDTH + 0)) - (TagType_TagType_TAG_WIDTH + 5)) + 1)];
	assign extension_bit_o = arbiter_output[TagType_TagType_TAG_WIDTH + 0];
	assign tag_o = arbiter_output[TagType_TagType_TAG_WIDTH - 1-:TagType_TagType_TAG_WIDTH];
	assign busy_o = |fmt_busy;
endmodule
module fpnew_opgroup_fmt_slice_E368D_75924 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter signed [31:0] TagType_TagType_TagType_TAG_WIDTH = 0;
	parameter [1:0] OpGroup = 2'd0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	function automatic [2:0] sv2v_cast_BCF4E;
		input reg [2:0] inp;
		sv2v_cast_BCF4E = inp;
	endfunction
	parameter [2:0] FpFormat = sv2v_cast_BCF4E(0);
	parameter [31:0] Width = 32;
	parameter [0:0] EnableVectors = 1'b1;
	parameter [31:0] NumPipeRegs = 0;
	parameter [1:0] PipeConfig = 2'd0;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			2'd0: fpnew_pkg_num_operands = 3;
			2'd1: fpnew_pkg_num_operands = 2;
			2'd2: fpnew_pkg_num_operands = 2;
			2'd3: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [NUM_OPERANDS - 1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	input wire vectorial_op_i;
	input wire [TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [Width - 1:0] result_o;
	output reg [4:0] status_o;
	output wire extension_bit_o;
	output wire [TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(FpFormat);
	function automatic [31:0] fpnew_pkg_num_lanes;
		input reg [31:0] width;
		input reg [2:0] fmt;
		input reg vec;
		fpnew_pkg_num_lanes = (vec ? width / fpnew_pkg_fp_width(fmt) : 1);
	endfunction
	localparam [31:0] NUM_LANES = fpnew_pkg_num_lanes(Width, FpFormat, EnableVectors);
	wire [NUM_LANES - 1:0] lane_in_ready;
	wire [NUM_LANES - 1:0] lane_out_valid;
	wire vectorial_op;
	wire [(NUM_LANES * FP_WIDTH) - 1:0] slice_result;
	wire [Width - 1:0] slice_regular_result;
	wire [Width - 1:0] slice_class_result;
	wire [Width - 1:0] slice_vec_class_result;
	wire [(NUM_LANES * 5) - 1:0] lane_status;
	wire [NUM_LANES - 1:0] lane_ext_bit;
	wire [(NUM_LANES * 10) - 1:0] lane_class_mask;
	wire [(NUM_LANES * TagType_TagType_TagType_TAG_WIDTH) - 1:0] lane_tags;
	wire [NUM_LANES - 1:0] lane_vectorial;
	wire [NUM_LANES - 1:0] lane_busy;
	wire [NUM_LANES - 1:0] lane_is_class;
	wire result_is_vector;
	wire result_is_class;
	assign in_ready_o = lane_in_ready[0];
	assign vectorial_op = vectorial_op_i & EnableVectors;
	genvar lane;
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (lane = 0; lane < sv2v_cast_32_signed(NUM_LANES); lane = lane + 1) begin : gen_num_lanes
			wire [FP_WIDTH - 1:0] local_result;
			wire local_sign;
			if ((lane == 0) || EnableVectors) begin : active_lane
				wire in_valid;
				wire out_valid;
				wire out_ready;
				reg [(NUM_OPERANDS * FP_WIDTH) - 1:0] local_operands;
				wire [FP_WIDTH - 1:0] op_result;
				wire [4:0] op_status;
				assign in_valid = in_valid_i & ((lane == 0) | vectorial_op);
				always @(*) begin : prepare_input
					begin : sv2v_autoblock_1
						reg signed [31:0] i;
						for (i = 0; i < sv2v_cast_32_signed(NUM_OPERANDS); i = i + 1)
							local_operands[i * FP_WIDTH+:FP_WIDTH] = operands_i[(i * Width) + (((($unsigned(lane) + 1) * FP_WIDTH) - 1) >= ($unsigned(lane) * FP_WIDTH) ? (($unsigned(lane) + 1) * FP_WIDTH) - 1 : (((($unsigned(lane) + 1) * FP_WIDTH) - 1) + (((($unsigned(lane) + 1) * FP_WIDTH) - 1) >= ($unsigned(lane) * FP_WIDTH) ? (((($unsigned(lane) + 1) * FP_WIDTH) - 1) - ($unsigned(lane) * FP_WIDTH)) + 1 : (($unsigned(lane) * FP_WIDTH) - ((($unsigned(lane) + 1) * FP_WIDTH) - 1)) + 1)) - 1)-:(((($unsigned(lane) + 1) * FP_WIDTH) - 1) >= ($unsigned(lane) * FP_WIDTH) ? (((($unsigned(lane) + 1) * FP_WIDTH) - 1) - ($unsigned(lane) * FP_WIDTH)) + 1 : (($unsigned(lane) * FP_WIDTH) - ((($unsigned(lane) + 1) * FP_WIDTH) - 1)) + 1)];
					end
				end
				if (OpGroup == 2'd0) begin : lane_instance
					fpnew_fma_FC83A_5615B #(
						.TagType_TagType_TagType_TagType_TAG_WIDTH(TagType_TagType_TagType_TAG_WIDTH),
						.FpFormat(FpFormat),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fma(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands),
						.is_boxed_i(is_boxed_i[NUM_OPERANDS - 1:0]),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.tag_i(tag_i),
						.aux_i(vectorial_op),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane * TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TAG_WIDTH]),
						.aux_o(lane_vectorial[lane]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
					assign lane_is_class[lane] = 1'b0;
					assign lane_class_mask[lane * 10+:10] = 10'b0000000001;
				end
				else if (OpGroup == 2'd1) begin
					;
				end
				else if (OpGroup == 2'd2) begin : lane_instance
					fpnew_noncomp_8EF6A_8033C #(
						.TagType_TagType_TagType_TagType_TAG_WIDTH(TagType_TagType_TagType_TAG_WIDTH),
						.FpFormat(FpFormat),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_noncomp(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands),
						.is_boxed_i(is_boxed_i[NUM_OPERANDS - 1:0]),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.tag_i(tag_i),
						.aux_i(vectorial_op),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.class_mask_o(lane_class_mask[lane * 10+:10]),
						.is_class_o(lane_is_class[lane]),
						.tag_o(lane_tags[lane * TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TAG_WIDTH]),
						.aux_o(lane_vectorial[lane]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				assign out_ready = out_ready_i & ((lane == 0) | result_is_vector);
				assign lane_out_valid[lane] = out_valid & ((lane == 0) | result_is_vector);
				assign local_result = (lane_out_valid[lane] ? op_result : {FP_WIDTH {lane_ext_bit[0]}});
				assign lane_status[lane * 5+:5] = (lane_out_valid[lane] ? op_status : {5 {1'sb0}});
			end
			else begin : genblk1
				assign lane_out_valid[lane] = 1'b0;
				assign lane_in_ready[lane] = 1'b0;
				assign local_result = {FP_WIDTH {lane_ext_bit[0]}};
				assign lane_status[lane * 5+:5] = 1'sb0;
				assign lane_busy[lane] = 1'b0;
				assign lane_is_class[lane] = 1'b0;
			end
			assign slice_result[(($unsigned(lane) + 1) * FP_WIDTH) - 1:$unsigned(lane) * FP_WIDTH] = local_result;
			if (((lane + 1) * 8) <= Width) begin : vectorial_class
				assign local_sign = (((lane_class_mask[lane * 10+:10] == 10'b0000000001) || (lane_class_mask[lane * 10+:10] == 10'b0000000010)) || (lane_class_mask[lane * 10+:10] == 10'b0000000100)) || (lane_class_mask[lane * 10+:10] == 10'b0000001000);
				assign slice_vec_class_result[((lane + 1) * 8) - 1:lane * 8] = {local_sign, ~local_sign, lane_class_mask[lane * 10+:10] == 10'b1000000000, lane_class_mask[lane * 10+:10] == 10'b0100000000, (lane_class_mask[lane * 10+:10] == 10'b0000010000) || (lane_class_mask[lane * 10+:10] == 10'b0000001000), (lane_class_mask[lane * 10+:10] == 10'b0000100000) || (lane_class_mask[lane * 10+:10] == 10'b0000000100), (lane_class_mask[lane * 10+:10] == 10'b0001000000) || (lane_class_mask[lane * 10+:10] == 10'b0000000010), (lane_class_mask[lane * 10+:10] == 10'b0010000000) || (lane_class_mask[lane * 10+:10] == 10'b0000000001)};
			end
		end
	endgenerate
	assign result_is_vector = lane_vectorial[0];
	assign result_is_class = lane_is_class[0];
	assign slice_regular_result = $signed({extension_bit_o, slice_result});
	localparam [31:0] CLASS_VEC_BITS = ((NUM_LANES * 8) > Width ? 8 * (Width / 8) : NUM_LANES * 8);
	generate
		if (CLASS_VEC_BITS < Width) begin : pad_vectorial_class
			assign slice_vec_class_result[Width - 1:CLASS_VEC_BITS] = 1'sb0;
		end
	endgenerate
	assign slice_class_result = (result_is_vector ? slice_vec_class_result : lane_class_mask[0+:10]);
	assign result_o = (result_is_class ? slice_class_result : slice_regular_result);
	assign extension_bit_o = lane_ext_bit[0];
	assign tag_o = lane_tags[0+:TagType_TagType_TagType_TAG_WIDTH];
	assign busy_o = |lane_busy;
	assign out_valid_o = lane_out_valid[0];
	always @(*) begin : output_processing
		reg [4:0] temp_status;
		temp_status = 1'sb0;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < sv2v_cast_32_signed(NUM_LANES); i = i + 1)
				temp_status = temp_status | lane_status[i * 5+:5];
		end
		status_o = temp_status;
	end
endmodule
module fpnew_opgroup_multifmt_slice_607F1_85D30 (
	clk_i,
	rst_ni,
	operands_i,
	is_boxed_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	extension_bit_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter signed [31:0] TagType_TagType_TagType_TAG_WIDTH = 0;
	parameter [1:0] OpGroup = 2'd3;
	parameter [31:0] Width = 64;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	parameter [0:4] FpFmtConfig = 1'sb1;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	parameter [0:3] IntFmtConfig = 1'sb1;
	parameter [0:0] EnableVectors = 1'b1;
	parameter [31:0] NumPipeRegs = 0;
	parameter [1:0] PipeConfig = 2'd0;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			2'd0: fpnew_pkg_num_operands = 3;
			2'd1: fpnew_pkg_num_operands = 2;
			2'd2: fpnew_pkg_num_operands = 2;
			2'd3: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	localparam [31:0] NUM_OPERANDS = fpnew_pkg_num_operands(OpGroup);
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * Width) - 1:0] operands_i;
	input wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	input wire [2:0] src_fmt_i;
	input wire [2:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire [TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [Width - 1:0] result_o;
	output reg [4:0] status_o;
	output wire extension_bit_o;
	output wire [TagType_TagType_TagType_TAG_WIDTH - 1:0] tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic signed [31:0] fpnew_pkg_maximum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_maximum = (a > b ? a : b);
	endfunction
	function automatic [2:0] sv2v_cast_51E70;
		input reg [2:0] inp;
		sv2v_cast_51E70 = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_max_fp_width;
		input reg [0:4] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_1
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_maximum(res, fpnew_pkg_fp_width(sv2v_cast_51E70(i))));
			end
			fpnew_pkg_max_fp_width = res;
		end
	endfunction
	localparam [31:0] MAX_FP_WIDTH = fpnew_pkg_max_fp_width(FpFmtConfig);
	function automatic [1:0] sv2v_cast_48100;
		input reg [1:0] inp;
		sv2v_cast_48100 = inp;
	endfunction
	function automatic [31:0] fpnew_pkg_int_width;
		input reg [1:0] ifmt;
		case (ifmt)
			sv2v_cast_48100(0): fpnew_pkg_int_width = 8;
			sv2v_cast_48100(1): fpnew_pkg_int_width = 16;
			sv2v_cast_48100(2): fpnew_pkg_int_width = 32;
			sv2v_cast_48100(3): fpnew_pkg_int_width = 64;
			default: begin
				fpnew_pkg_int_width = sv2v_cast_48100(0);
			end
		endcase
	endfunction
	function automatic [31:0] fpnew_pkg_max_int_width;
		input reg [0:3] cfg;
		reg [31:0] res;
		begin
			res = 0;
			begin : sv2v_autoblock_2
				reg signed [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					if (cfg[ifmt])
						res = fpnew_pkg_maximum(res, fpnew_pkg_int_width(sv2v_cast_48100(ifmt)));
			end
			fpnew_pkg_max_int_width = res;
		end
	endfunction
	localparam [31:0] MAX_INT_WIDTH = fpnew_pkg_max_int_width(IntFmtConfig);
	function automatic signed [31:0] fpnew_pkg_minimum;
		input reg signed [31:0] a;
		input reg signed [31:0] b;
		fpnew_pkg_minimum = (a < b ? a : b);
	endfunction
	function automatic [31:0] fpnew_pkg_min_fp_width;
		input reg [0:4] cfg;
		reg [31:0] res;
		begin
			res = fpnew_pkg_max_fp_width(cfg);
			begin : sv2v_autoblock_3
				reg [31:0] i;
				for (i = 0; i < fpnew_pkg_NUM_FP_FORMATS; i = i + 1)
					if (cfg[i])
						res = $unsigned(fpnew_pkg_minimum(res, fpnew_pkg_fp_width(sv2v_cast_51E70(i))));
			end
			fpnew_pkg_min_fp_width = res;
		end
	endfunction
	function automatic [31:0] fpnew_pkg_max_num_lanes;
		input reg [31:0] width;
		input reg [0:4] cfg;
		input reg vec;
		fpnew_pkg_max_num_lanes = (vec ? width / fpnew_pkg_min_fp_width(cfg) : 1);
	endfunction
	localparam [31:0] NUM_LANES = fpnew_pkg_max_num_lanes(Width, FpFmtConfig, 1'b1);
	localparam [31:0] NUM_INT_FORMATS = fpnew_pkg_NUM_INT_FORMATS;
	localparam [31:0] FMT_BITS = fpnew_pkg_maximum(3, 2);
	localparam [31:0] AUX_BITS = FMT_BITS + 2;
	wire [NUM_LANES - 1:0] lane_in_ready;
	wire [NUM_LANES - 1:0] lane_out_valid;
	wire vectorial_op;
	wire [FMT_BITS - 1:0] dst_fmt;
	wire [AUX_BITS - 1:0] aux_data;
	wire dst_fmt_is_int;
	wire dst_is_cpk;
	wire [1:0] dst_vec_op;
	wire [2:0] target_aux_d;
	wire [2:0] target_aux_q;
	wire is_up_cast;
	wire is_down_cast;
	wire [(NUM_FORMATS * Width) - 1:0] fmt_slice_result;
	wire [(NUM_INT_FORMATS * Width) - 1:0] ifmt_slice_result;
	wire [Width - 1:0] conv_slice_result;
	wire [Width - 1:0] conv_target_d;
	wire [Width - 1:0] conv_target_q;
	wire [(NUM_LANES * 5) - 1:0] lane_status;
	wire [NUM_LANES - 1:0] lane_ext_bit;
	wire [(NUM_LANES * TagType_TagType_TagType_TAG_WIDTH) - 1:0] lane_tags;
	wire [(NUM_LANES * AUX_BITS) - 1:0] lane_aux;
	wire [NUM_LANES - 1:0] lane_busy;
	wire result_is_vector;
	wire [FMT_BITS - 1:0] result_fmt;
	wire result_fmt_is_int;
	wire result_is_cpk;
	wire [1:0] result_vec_op;
	assign in_ready_o = lane_in_ready[0];
	assign vectorial_op = vectorial_op_i & EnableVectors;
	function automatic [3:0] sv2v_cast_FA912;
		input reg [3:0] inp;
		sv2v_cast_FA912 = inp;
	endfunction
	assign dst_fmt_is_int = (OpGroup == 2'd3) & (op_i == sv2v_cast_FA912(11));
	assign dst_is_cpk = (OpGroup == 2'd3) & ((op_i == sv2v_cast_FA912(13)) || (op_i == sv2v_cast_FA912(14)));
	assign dst_vec_op = (OpGroup == 2'd3) & {op_i == sv2v_cast_FA912(14), op_mod_i};
	assign is_up_cast = fpnew_pkg_fp_width(dst_fmt_i) > fpnew_pkg_fp_width(src_fmt_i);
	assign is_down_cast = fpnew_pkg_fp_width(dst_fmt_i) < fpnew_pkg_fp_width(src_fmt_i);
	assign dst_fmt = (dst_fmt_is_int ? int_fmt_i : dst_fmt_i);
	assign aux_data = {dst_fmt_is_int, vectorial_op, dst_fmt};
	assign target_aux_d = {dst_vec_op, dst_is_cpk};
	generate
		if (OpGroup == 2'd3) begin : conv_target
			assign conv_target_d = (dst_is_cpk ? operands_i[2 * Width+:Width] : operands_i[Width+:Width]);
		end
	endgenerate
	reg [4:0] is_boxed_1op;
	reg [9:0] is_boxed_2op;
	always @(*) begin : boxed_2op
		begin : sv2v_autoblock_4
			reg signed [31:0] fmt;
			for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1)
				begin
					is_boxed_1op[fmt] = is_boxed_i[fmt * NUM_OPERANDS];
					is_boxed_2op[fmt * 2+:2] = is_boxed_i[(fmt * NUM_OPERANDS) + 1-:2];
				end
		end
	end
	genvar lane;
	localparam [0:4] fpnew_pkg_CPK_FORMATS = 5'b11000;
	function automatic [0:4] fpnew_pkg_get_conv_lane_formats;
		input reg [31:0] width;
		input reg [0:4] cfg;
		input reg [31:0] lane_no;
		reg [0:4] res;
		begin
			begin : sv2v_autoblock_5
				reg [31:0] fmt;
				for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
					res[fmt] = cfg[fmt] && (((width / fpnew_pkg_fp_width(sv2v_cast_51E70(fmt))) > lane_no) || (fpnew_pkg_CPK_FORMATS[fmt] && (lane_no < 2)));
			end
			fpnew_pkg_get_conv_lane_formats = res;
		end
	endfunction
	function automatic [0:3] fpnew_pkg_get_conv_lane_int_formats;
		input reg [31:0] width;
		input reg [0:4] cfg;
		input reg [0:3] icfg;
		input reg [31:0] lane_no;
		reg [0:3] res;
		reg [0:4] lanefmts;
		begin
			res = 1'sb0;
			lanefmts = fpnew_pkg_get_conv_lane_formats(width, cfg, lane_no);
			begin : sv2v_autoblock_6
				reg [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					begin : sv2v_autoblock_7
						reg [31:0] fmt;
						for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
							res[ifmt] = res[ifmt] | ((icfg[ifmt] && lanefmts[fmt]) && (fpnew_pkg_fp_width(sv2v_cast_51E70(fmt)) == fpnew_pkg_int_width(sv2v_cast_48100(ifmt))));
					end
			end
			fpnew_pkg_get_conv_lane_int_formats = res;
		end
	endfunction
	function automatic [0:4] fpnew_pkg_get_lane_formats;
		input reg [31:0] width;
		input reg [0:4] cfg;
		input reg [31:0] lane_no;
		reg [0:4] res;
		begin
			begin : sv2v_autoblock_8
				reg [31:0] fmt;
				for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
					res[fmt] = cfg[fmt] & ((width / fpnew_pkg_fp_width(sv2v_cast_51E70(fmt))) > lane_no);
			end
			fpnew_pkg_get_lane_formats = res;
		end
	endfunction
	function automatic [0:3] fpnew_pkg_get_lane_int_formats;
		input reg [31:0] width;
		input reg [0:4] cfg;
		input reg [0:3] icfg;
		input reg [31:0] lane_no;
		reg [0:3] res;
		reg [0:4] lanefmts;
		begin
			res = 1'sb0;
			lanefmts = fpnew_pkg_get_lane_formats(width, cfg, lane_no);
			begin : sv2v_autoblock_9
				reg [31:0] ifmt;
				for (ifmt = 0; ifmt < fpnew_pkg_NUM_INT_FORMATS; ifmt = ifmt + 1)
					begin : sv2v_autoblock_10
						reg [31:0] fmt;
						for (fmt = 0; fmt < fpnew_pkg_NUM_FP_FORMATS; fmt = fmt + 1)
							if (fpnew_pkg_fp_width(sv2v_cast_51E70(fmt)) == fpnew_pkg_int_width(sv2v_cast_48100(ifmt)))
								res[ifmt] = res[ifmt] | (icfg[ifmt] && lanefmts[fmt]);
					end
			end
			fpnew_pkg_get_lane_int_formats = res;
		end
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [4:0] sv2v_cast_CB211;
		input reg [4:0] inp;
		sv2v_cast_CB211 = inp;
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (lane = 0; lane < sv2v_cast_32_signed(NUM_LANES); lane = lane + 1) begin : gen_num_lanes
			localparam [31:0] LANE = $unsigned(lane);
			localparam [0:4] ACTIVE_FORMATS = fpnew_pkg_get_lane_formats(Width, FpFmtConfig, LANE);
			localparam [0:3] ACTIVE_INT_FORMATS = fpnew_pkg_get_lane_int_formats(Width, FpFmtConfig, IntFmtConfig, LANE);
			localparam [31:0] MAX_WIDTH = fpnew_pkg_max_fp_width(ACTIVE_FORMATS);
			localparam [0:4] CONV_FORMATS = fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, LANE);
			localparam [0:3] CONV_INT_FORMATS = fpnew_pkg_get_conv_lane_int_formats(Width, FpFmtConfig, IntFmtConfig, LANE);
			localparam [31:0] CONV_WIDTH = fpnew_pkg_max_fp_width(CONV_FORMATS);
			localparam [0:4] LANE_FORMATS = (OpGroup == 2'd3 ? CONV_FORMATS : ACTIVE_FORMATS);
			localparam [31:0] LANE_WIDTH = (OpGroup == 2'd3 ? CONV_WIDTH : MAX_WIDTH);
			wire [LANE_WIDTH - 1:0] local_result;
			if ((lane == 0) || EnableVectors) begin : active_lane
				wire in_valid;
				wire out_valid;
				wire out_ready;
				reg [(NUM_OPERANDS * LANE_WIDTH) - 1:0] local_operands;
				wire [LANE_WIDTH - 1:0] op_result;
				wire [4:0] op_status;
				assign in_valid = in_valid_i & ((lane == 0) | vectorial_op);
				always @(*) begin : prepare_input
					begin : sv2v_autoblock_11
						reg [31:0] i;
						for (i = 0; i < NUM_OPERANDS; i = i + 1)
							local_operands[i * (OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))) : fpnew_pkg_max_fp_width(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))+:(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))) : fpnew_pkg_max_fp_width(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))] = operands_i[i * Width+:Width] >> (LANE * fpnew_pkg_fp_width(src_fmt_i));
					end
					if (OpGroup == 2'd3)
						if (op_i == sv2v_cast_FA912(12))
							local_operands[0+:(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))) : fpnew_pkg_max_fp_width(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))] = operands_i[0+:Width] >> (LANE * fpnew_pkg_int_width(int_fmt_i));
						else if (op_i == sv2v_cast_FA912(10)) begin
							if ((vectorial_op && op_mod_i) && is_up_cast)
								local_operands[0+:(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))) : fpnew_pkg_max_fp_width(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))] = operands_i[0+:Width] >> ((LANE * fpnew_pkg_fp_width(src_fmt_i)) + (MAX_FP_WIDTH / 2));
						end
						else if (dst_is_cpk)
							if (lane == 1)
								local_operands[0+:(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))) : fpnew_pkg_max_fp_width(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))] = operands_i[Width + (LANE_WIDTH - 1)-:LANE_WIDTH];
				end
				if (OpGroup == 2'd0) begin : lane_instance
					fpnew_fma_multi_41774_DE779 #(
						.AuxType_AUX_BITS(AUX_BITS),
						.TagType_TagType_TagType_TagType_TAG_WIDTH(TagType_TagType_TagType_TAG_WIDTH),
						.FpFmtConfig(LANE_FORMATS),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fpnew_fma_multi(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands),
						.is_boxed_i(is_boxed_i),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.src_fmt_i(src_fmt_i),
						.dst_fmt_i(dst_fmt_i),
						.tag_i(tag_i),
						.aux_i(aux_data),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane * TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TAG_WIDTH]),
						.aux_o(lane_aux[lane * AUX_BITS+:AUX_BITS]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				else if (OpGroup == 2'd1) begin : lane_instance
					fpnew_divsqrt_multi_1A2E7_2C16F #(
						.AuxType_AUX_BITS(AUX_BITS),
						.TagType_TagType_TagType_TagType_TAG_WIDTH(TagType_TagType_TagType_TAG_WIDTH),
						.FpFmtConfig(LANE_FORMATS),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fpnew_divsqrt_multi(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands[0+:(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))) : fpnew_pkg_max_fp_width(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))) * 2]),
						.is_boxed_i(is_boxed_2op),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.dst_fmt_i(dst_fmt_i),
						.tag_i(tag_i),
						.aux_i(aux_data),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane * TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TAG_WIDTH]),
						.aux_o(lane_aux[lane * AUX_BITS+:AUX_BITS]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				else if (OpGroup == 2'd2) begin
					;
				end
				else if (OpGroup == 2'd3) begin : lane_instance
					fpnew_cast_multi_BB75A_A18A7 #(
						.AuxType_AUX_BITS(AUX_BITS),
						.TagType_TagType_TagType_TagType_TAG_WIDTH(TagType_TagType_TagType_TAG_WIDTH),
						.FpFmtConfig(LANE_FORMATS),
						.IntFmtConfig(CONV_INT_FORMATS),
						.NumPipeRegs(NumPipeRegs),
						.PipeConfig(PipeConfig)
					) i_fpnew_cast_multi(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.operands_i(local_operands[0+:(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))) : fpnew_pkg_max_fp_width(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))]),
						.is_boxed_i(is_boxed_1op),
						.rnd_mode_i(rnd_mode_i),
						.op_i(op_i),
						.op_mod_i(op_mod_i),
						.src_fmt_i(src_fmt_i),
						.dst_fmt_i(dst_fmt_i),
						.int_fmt_i(int_fmt_i),
						.tag_i(tag_i),
						.aux_i(aux_data),
						.in_valid_i(in_valid),
						.in_ready_o(lane_in_ready[lane]),
						.flush_i(flush_i),
						.result_o(op_result),
						.status_o(op_status),
						.extension_bit_o(lane_ext_bit[lane]),
						.tag_o(lane_tags[lane * TagType_TagType_TagType_TAG_WIDTH+:TagType_TagType_TagType_TAG_WIDTH]),
						.aux_o(lane_aux[lane * AUX_BITS+:AUX_BITS]),
						.out_valid_o(out_valid),
						.out_ready_i(out_ready),
						.busy_o(lane_busy[lane])
					);
				end
				assign out_ready = out_ready_i & ((lane == 0) | result_is_vector);
				assign lane_out_valid[lane] = out_valid & ((lane == 0) | result_is_vector);
				assign local_result = (lane_out_valid[lane] ? op_result : {(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(sv2v_cast_CB211(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))) : fpnew_pkg_max_fp_width(sv2v_cast_CB211(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) {lane_ext_bit[0]}});
				assign lane_status[lane * 5+:5] = (lane_out_valid[lane] ? op_status : {5 {1'sb0}});
			end
			else begin : inactive_lane
				assign lane_out_valid[lane] = 1'b0;
				assign lane_in_ready[lane] = 1'b0;
				assign local_result = {(OpGroup == 2'd3 ? fpnew_pkg_max_fp_width(sv2v_cast_CB211(fpnew_pkg_get_conv_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane))))) : fpnew_pkg_max_fp_width(sv2v_cast_CB211(fpnew_pkg_get_lane_formats(Width, FpFmtConfig, sv2v_cast_32($unsigned(lane)))))) {lane_ext_bit[0]}};
				assign lane_status[lane * 5+:5] = 1'sb0;
				assign lane_busy[lane] = 1'b0;
			end
			genvar fmt;
			for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1) begin : pack_fp_result
				localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_51E70(fmt));
				if (ACTIVE_FORMATS[fmt]) begin : genblk1
					assign fmt_slice_result[(fmt * Width) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((LANE + 1) * FP_WIDTH) - 1 : ((((LANE + 1) * FP_WIDTH) - 1) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)] = local_result[FP_WIDTH - 1:0];
				end
				else if (((LANE + 1) * FP_WIDTH) <= Width) begin : genblk1
					assign fmt_slice_result[(fmt * Width) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((LANE + 1) * FP_WIDTH) - 1 : ((((LANE + 1) * FP_WIDTH) - 1) + ((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1)] = {((((LANE + 1) * FP_WIDTH) - 1) >= (LANE * FP_WIDTH) ? ((((LANE + 1) * FP_WIDTH) - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (((LANE + 1) * FP_WIDTH) - 1)) + 1) {lane_ext_bit[LANE]}};
				end
				else if ((LANE * FP_WIDTH) < Width) begin : genblk1
					assign fmt_slice_result[(fmt * Width) + ((Width - 1) >= (LANE * FP_WIDTH) ? Width - 1 : ((Width - 1) + ((Width - 1) >= (LANE * FP_WIDTH) ? ((Width - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (Width - 1)) + 1)) - 1)-:((Width - 1) >= (LANE * FP_WIDTH) ? ((Width - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (Width - 1)) + 1)] = {((Width - 1) >= (LANE * FP_WIDTH) ? ((Width - 1) - (LANE * FP_WIDTH)) + 1 : ((LANE * FP_WIDTH) - (Width - 1)) + 1) {lane_ext_bit[LANE]}};
				end
			end
			if (OpGroup == 2'd3) begin : int_results_enabled
				genvar ifmt;
				for (ifmt = 0; ifmt < NUM_INT_FORMATS; ifmt = ifmt + 1) begin : pack_int_result
					localparam [31:0] INT_WIDTH = fpnew_pkg_int_width(sv2v_cast_48100(ifmt));
					if (ACTIVE_INT_FORMATS[ifmt]) begin : genblk1
						assign ifmt_slice_result[(ifmt * Width) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((LANE + 1) * INT_WIDTH) - 1 : ((((LANE + 1) * INT_WIDTH) - 1) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)] = local_result[INT_WIDTH - 1:0];
					end
					else if (((LANE + 1) * INT_WIDTH) <= Width) begin : genblk1
						assign ifmt_slice_result[(ifmt * Width) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((LANE + 1) * INT_WIDTH) - 1 : ((((LANE + 1) * INT_WIDTH) - 1) + ((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)) - 1)-:((((LANE + 1) * INT_WIDTH) - 1) >= (LANE * INT_WIDTH) ? ((((LANE + 1) * INT_WIDTH) - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (((LANE + 1) * INT_WIDTH) - 1)) + 1)] = 1'sb0;
					end
					else if ((LANE * INT_WIDTH) < Width) begin : genblk1
						assign ifmt_slice_result[(ifmt * Width) + ((Width - 1) >= (LANE * INT_WIDTH) ? Width - 1 : ((Width - 1) + ((Width - 1) >= (LANE * INT_WIDTH) ? ((Width - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (Width - 1)) + 1)) - 1)-:((Width - 1) >= (LANE * INT_WIDTH) ? ((Width - 1) - (LANE * INT_WIDTH)) + 1 : ((LANE * INT_WIDTH) - (Width - 1)) + 1)] = 1'sb0;
					end
				end
			end
		end
	endgenerate
	genvar fmt;
	generate
		for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1) begin : extend_fp_result
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_51E70(fmt));
			if ((NUM_LANES * FP_WIDTH) < Width) begin : genblk1
				assign fmt_slice_result[(fmt * Width) + ((Width - 1) >= (NUM_LANES * FP_WIDTH) ? Width - 1 : ((Width - 1) + ((Width - 1) >= (NUM_LANES * FP_WIDTH) ? ((Width - 1) - (NUM_LANES * FP_WIDTH)) + 1 : ((NUM_LANES * FP_WIDTH) - (Width - 1)) + 1)) - 1)-:((Width - 1) >= (NUM_LANES * FP_WIDTH) ? ((Width - 1) - (NUM_LANES * FP_WIDTH)) + 1 : ((NUM_LANES * FP_WIDTH) - (Width - 1)) + 1)] = {((Width - 1) >= (NUM_LANES * FP_WIDTH) ? ((Width - 1) - (NUM_LANES * FP_WIDTH)) + 1 : ((NUM_LANES * FP_WIDTH) - (Width - 1)) + 1) {lane_ext_bit[0]}};
			end
		end
	endgenerate
	genvar ifmt;
	generate
		for (ifmt = 0; ifmt < NUM_INT_FORMATS; ifmt = ifmt + 1) begin : int_results_disabled
			if (OpGroup != 2'd3) begin : mute_int_result
				assign ifmt_slice_result[ifmt * Width+:Width] = 1'sb0;
			end
		end
		if (OpGroup == 2'd3) begin : target_regs
			reg [(0 >= NumPipeRegs ? ((1 - NumPipeRegs) * Width) + ((NumPipeRegs * Width) - 1) : ((NumPipeRegs + 1) * Width) - 1):(0 >= NumPipeRegs ? NumPipeRegs * Width : 0)] byp_pipe_target_q;
			reg [(0 >= NumPipeRegs ? ((1 - NumPipeRegs) * 3) + ((NumPipeRegs * 3) - 1) : ((NumPipeRegs + 1) * 3) - 1):(0 >= NumPipeRegs ? NumPipeRegs * 3 : 0)] byp_pipe_aux_q;
			reg [0:NumPipeRegs] byp_pipe_valid_q;
			wire [0:NumPipeRegs] byp_pipe_ready;
			wire [Width * 1:1] sv2v_tmp_FBD8C;
			assign sv2v_tmp_FBD8C = conv_target_d;
			always @(*) byp_pipe_target_q[(0 >= NumPipeRegs ? 0 : NumPipeRegs) * Width+:Width] = sv2v_tmp_FBD8C;
			wire [3:1] sv2v_tmp_A0A5D;
			assign sv2v_tmp_A0A5D = target_aux_d;
			always @(*) byp_pipe_aux_q[(0 >= NumPipeRegs ? 0 : NumPipeRegs) * 3+:3] = sv2v_tmp_A0A5D;
			wire [1:1] sv2v_tmp_49222;
			assign sv2v_tmp_49222 = in_valid_i & vectorial_op;
			always @(*) byp_pipe_valid_q[0] = sv2v_tmp_49222;
			genvar i;
			for (i = 0; i < NumPipeRegs; i = i + 1) begin : gen_bypass_pipeline
				wire reg_ena;
				assign byp_pipe_ready[i] = byp_pipe_ready[i + 1] | ~byp_pipe_valid_q[i + 1];
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						byp_pipe_valid_q[i + 1] <= 1'b0;
					else
						byp_pipe_valid_q[i + 1] <= (flush_i ? 1'b0 : (byp_pipe_ready[i] ? byp_pipe_valid_q[i] : byp_pipe_valid_q[i + 1]));
				assign reg_ena = byp_pipe_ready[i] & byp_pipe_valid_q[i];
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						byp_pipe_target_q[(0 >= NumPipeRegs ? i + 1 : NumPipeRegs - (i + 1)) * Width+:Width] <= 1'sb0;
					else
						byp_pipe_target_q[(0 >= NumPipeRegs ? i + 1 : NumPipeRegs - (i + 1)) * Width+:Width] <= (reg_ena ? byp_pipe_target_q[(0 >= NumPipeRegs ? i : NumPipeRegs - i) * Width+:Width] : byp_pipe_target_q[(0 >= NumPipeRegs ? i + 1 : NumPipeRegs - (i + 1)) * Width+:Width]);
				always @(posedge clk_i or negedge rst_ni)
					if (!rst_ni)
						byp_pipe_aux_q[(0 >= NumPipeRegs ? i + 1 : NumPipeRegs - (i + 1)) * 3+:3] <= 1'sb0;
					else
						byp_pipe_aux_q[(0 >= NumPipeRegs ? i + 1 : NumPipeRegs - (i + 1)) * 3+:3] <= (reg_ena ? byp_pipe_aux_q[(0 >= NumPipeRegs ? i : NumPipeRegs - i) * 3+:3] : byp_pipe_aux_q[(0 >= NumPipeRegs ? i + 1 : NumPipeRegs - (i + 1)) * 3+:3]);
			end
			assign byp_pipe_ready[NumPipeRegs] = out_ready_i & result_is_vector;
			assign conv_target_q = byp_pipe_target_q[(0 >= NumPipeRegs ? NumPipeRegs : NumPipeRegs - NumPipeRegs) * Width+:Width];
			assign {result_vec_op, result_is_cpk} = byp_pipe_aux_q[(0 >= NumPipeRegs ? NumPipeRegs : NumPipeRegs - NumPipeRegs) * 3+:3];
		end
		else begin : no_conv
			assign {result_vec_op, result_is_cpk} = 1'sb0;
		end
	endgenerate
	assign {result_fmt_is_int, result_is_vector, result_fmt} = lane_aux[0+:AUX_BITS];
	assign result_o = (result_fmt_is_int ? ifmt_slice_result[result_fmt * Width+:Width] : fmt_slice_result[result_fmt * Width+:Width]);
	assign extension_bit_o = lane_ext_bit[0];
	assign tag_o = lane_tags[0+:TagType_TagType_TagType_TAG_WIDTH];
	assign busy_o = |lane_busy;
	assign out_valid_o = lane_out_valid[0];
	always @(*) begin : output_processing
		reg [4:0] temp_status;
		temp_status = 1'sb0;
		begin : sv2v_autoblock_12
			reg signed [31:0] i;
			for (i = 0; i < sv2v_cast_32_signed(NUM_LANES); i = i + 1)
				temp_status = temp_status | lane_status[i * 5+:5];
		end
		status_o = temp_status;
	end
endmodule
module fpnew_rounding (
	abs_value_i,
	sign_i,
	round_sticky_bits_i,
	rnd_mode_i,
	effective_subtraction_i,
	abs_rounded_o,
	sign_o,
	exact_zero_o
);
	parameter [31:0] AbsWidth = 2;
	input wire [AbsWidth - 1:0] abs_value_i;
	input wire sign_i;
	input wire [1:0] round_sticky_bits_i;
	input wire [2:0] rnd_mode_i;
	input wire effective_subtraction_i;
	output wire [AbsWidth - 1:0] abs_rounded_o;
	output wire sign_o;
	output wire exact_zero_o;
	reg round_up;
	localparam [0:0] fpnew_pkg_DONT_CARE = 1'b1;
	always @(*) begin : rounding_decision
		case (rnd_mode_i)
			3'b000:
				case (round_sticky_bits_i)
					2'b00, 2'b01: round_up = 1'b0;
					2'b10: round_up = abs_value_i[0];
					2'b11: round_up = 1'b1;
					default: round_up = fpnew_pkg_DONT_CARE;
				endcase
			3'b001: round_up = 1'b0;
			3'b010: round_up = (|round_sticky_bits_i ? sign_i : 1'b0);
			3'b011: round_up = (|round_sticky_bits_i ? ~sign_i : 1'b0);
			3'b100: round_up = round_sticky_bits_i[1];
			default: round_up = fpnew_pkg_DONT_CARE;
		endcase
	end
	assign abs_rounded_o = abs_value_i + round_up;
	assign exact_zero_o = (abs_value_i == {AbsWidth {1'sb0}}) && (round_sticky_bits_i == {2 {1'sb0}});
	assign sign_o = (exact_zero_o && effective_subtraction_i ? rnd_mode_i == 3'b010 : sign_i);
endmodule
module fpnew_top_21317_11D0A (
	clk_i,
	rst_ni,
	operands_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter signed [31:0] TagType_TAG_WIDTH = 0;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [42:0] fpnew_pkg_RV64D_Xsflt = 43'b0000000000000000000000000100000011111111111;
	parameter [42:0] Features = fpnew_pkg_RV64D_Xsflt;
	localparam [31:0] fpnew_pkg_NUM_OPGROUPS = 4;
	function automatic [159:0] sv2v_cast_FA957;
		input reg [159:0] inp;
		sv2v_cast_FA957 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 32) - 1:0] sv2v_cast_CDC93;
		input reg [((32'd4 * 32'd5) * 32) - 1:0] inp;
		sv2v_cast_CDC93 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 2) - 1:0] sv2v_cast_15FEF;
		input reg [((32'd4 * 32'd5) * 2) - 1:0] inp;
		sv2v_cast_15FEF = inp;
	endfunction
	localparam [(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + ((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2)) + 1:0] fpnew_pkg_DEFAULT_NOREGS = {sv2v_cast_CDC93({fpnew_pkg_NUM_OPGROUPS {sv2v_cast_FA957(0)}}), sv2v_cast_15FEF({{fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}, {fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}}), 2'd0};
	parameter [(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + ((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2)) + 1:0] Implementation = fpnew_pkg_DEFAULT_NOREGS;
	localparam [31:0] WIDTH = Features[42-:32];
	localparam [31:0] NUM_OPERANDS = 3;
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * WIDTH) - 1:0] operands_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	input wire [2:0] src_fmt_i;
	input wire [2:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire [TagType_TAG_WIDTH - 1:0] tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire [TagType_TAG_WIDTH - 1:0] tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	localparam [31:0] NUM_OPGROUPS = fpnew_pkg_NUM_OPGROUPS;
	localparam [31:0] NUM_FORMATS = fpnew_pkg_NUM_FP_FORMATS;
	wire [3:0] opgrp_in_ready;
	wire [3:0] opgrp_out_valid;
	wire [3:0] opgrp_out_ready;
	wire [3:0] opgrp_ext;
	wire [3:0] opgrp_busy;
	wire [(4 * ((WIDTH + 5) + TagType_TAG_WIDTH)) - 1:0] opgrp_outputs;
	wire [(NUM_FORMATS * NUM_OPERANDS) - 1:0] is_boxed;
	function automatic [3:0] sv2v_cast_7C1AC;
		input reg [3:0] inp;
		sv2v_cast_7C1AC = inp;
	endfunction
	function automatic [1:0] fpnew_pkg_get_opgroup;
		input reg [3:0] op;
		case (op)
			sv2v_cast_7C1AC(0), sv2v_cast_7C1AC(1), sv2v_cast_7C1AC(2), sv2v_cast_7C1AC(3): fpnew_pkg_get_opgroup = 2'd0;
			sv2v_cast_7C1AC(4), sv2v_cast_7C1AC(5): fpnew_pkg_get_opgroup = 2'd1;
			sv2v_cast_7C1AC(6), sv2v_cast_7C1AC(7), sv2v_cast_7C1AC(8), sv2v_cast_7C1AC(9): fpnew_pkg_get_opgroup = 2'd2;
			sv2v_cast_7C1AC(10), sv2v_cast_7C1AC(11), sv2v_cast_7C1AC(12), sv2v_cast_7C1AC(13), sv2v_cast_7C1AC(14): fpnew_pkg_get_opgroup = 2'd3;
			default: fpnew_pkg_get_opgroup = 2'd2;
		endcase
	endfunction
	assign in_ready_o = in_valid_i & opgrp_in_ready[fpnew_pkg_get_opgroup(op_i)];
	genvar fmt;
	localparam [319:0] fpnew_pkg_FP_ENCODINGS = 320'h8000000170000000b00000034000000050000000a00000005000000020000000800000007;
	function automatic [31:0] fpnew_pkg_fp_width;
		input reg [2:0] fmt;
		fpnew_pkg_fp_width = (fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 63-:32] + fpnew_pkg_FP_ENCODINGS[((4 - fmt) * 64) + 31-:32]) + 1;
	endfunction
	function automatic [2:0] sv2v_cast_F0CFE;
		input reg [2:0] inp;
		sv2v_cast_F0CFE = inp;
	endfunction
	function automatic signed [31:0] sv2v_cast_32_signed;
		input reg signed [31:0] inp;
		sv2v_cast_32_signed = inp;
	endfunction
	generate
		for (fmt = 0; fmt < sv2v_cast_32_signed(NUM_FORMATS); fmt = fmt + 1) begin : gen_nanbox_check
			localparam [31:0] FP_WIDTH = fpnew_pkg_fp_width(sv2v_cast_F0CFE(fmt));
			if (Features[9] && (FP_WIDTH < WIDTH)) begin : check
				genvar op;
				for (op = 0; op < sv2v_cast_32_signed(NUM_OPERANDS); op = op + 1) begin : operands
					assign is_boxed[(fmt * NUM_OPERANDS) + op] = (!vectorial_op_i ? operands_i[(op * WIDTH) + ((WIDTH - 1) >= FP_WIDTH ? WIDTH - 1 : ((WIDTH - 1) + ((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1)) - 1)-:((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1)] == {((WIDTH - 1) >= FP_WIDTH ? ((WIDTH - 1) - FP_WIDTH) + 1 : (FP_WIDTH - (WIDTH - 1)) + 1) * 1 {1'sb1}} : 1'b1);
				end
			end
			else begin : no_check
				assign is_boxed[fmt * NUM_OPERANDS+:NUM_OPERANDS] = 1'sb1;
			end
		end
	endgenerate
	genvar opgrp;
	function automatic [31:0] fpnew_pkg_num_operands;
		input reg [1:0] grp;
		case (grp)
			2'd0: fpnew_pkg_num_operands = 3;
			2'd1: fpnew_pkg_num_operands = 2;
			2'd2: fpnew_pkg_num_operands = 2;
			2'd3: fpnew_pkg_num_operands = 3;
			default: fpnew_pkg_num_operands = 0;
		endcase
	endfunction
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		for (opgrp = 0; opgrp < sv2v_cast_32_signed(NUM_OPGROUPS); opgrp = opgrp + 1) begin : gen_operation_groups
			localparam [31:0] NUM_OPS = fpnew_pkg_num_operands(sv2v_cast_2(opgrp));
			wire in_valid;
			reg [(NUM_FORMATS * NUM_OPS) - 1:0] input_boxed;
			assign in_valid = in_valid_i & (fpnew_pkg_get_opgroup(op_i) == sv2v_cast_2(opgrp));
			always @(*) begin : slice_inputs
				begin : sv2v_autoblock_1
					reg [31:0] fmt;
					for (fmt = 0; fmt < NUM_FORMATS; fmt = fmt + 1)
						input_boxed[fmt * fpnew_pkg_num_operands(sv2v_cast_2(opgrp))+:fpnew_pkg_num_operands(sv2v_cast_2(opgrp))] = is_boxed[(fmt * NUM_OPERANDS) + (NUM_OPS - 1)-:NUM_OPS];
				end
			end
			fpnew_opgroup_block_A94B6_B7406 #(
				.TagType_TagType_TAG_WIDTH(TagType_TAG_WIDTH),
				.OpGroup(sv2v_cast_2(opgrp)),
				.Width(WIDTH),
				.EnableVectors(Features[10]),
				.FpFmtMask(Features[8-:5]),
				.IntFmtMask(Features[3-:fpnew_pkg_NUM_INT_FORMATS]),
				.FmtPipeRegs(Implementation[(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + (((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2) + 1)) - ((((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) - 1) - (32 * ((3 - opgrp) * fpnew_pkg_NUM_FP_FORMATS)))+:160]),
				.FmtUnitTypes(Implementation[(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2) + 1) - ((((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2) - 1) - (2 * ((3 - opgrp) * fpnew_pkg_NUM_FP_FORMATS)))+:10]),
				.PipeConfig(Implementation[1-:2])
			) i_opgroup_block(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.operands_i(operands_i[WIDTH * ((NUM_OPS - 1) - (NUM_OPS - 1))+:WIDTH * NUM_OPS]),
				.is_boxed_i(input_boxed),
				.rnd_mode_i(rnd_mode_i),
				.op_i(op_i),
				.op_mod_i(op_mod_i),
				.src_fmt_i(src_fmt_i),
				.dst_fmt_i(dst_fmt_i),
				.int_fmt_i(int_fmt_i),
				.vectorial_op_i(vectorial_op_i),
				.tag_i(tag_i),
				.in_valid_i(in_valid),
				.in_ready_o(opgrp_in_ready[opgrp]),
				.flush_i(flush_i),
				.result_o(opgrp_outputs[(opgrp * ((WIDTH + 5) + TagType_TAG_WIDTH)) + (WIDTH + (TagType_TAG_WIDTH + 4))-:((WIDTH + (TagType_TAG_WIDTH + 4)) >= (5 + (TagType_TAG_WIDTH + 0)) ? ((WIDTH + (TagType_TAG_WIDTH + 4)) - (5 + (TagType_TAG_WIDTH + 0))) + 1 : ((5 + (TagType_TAG_WIDTH + 0)) - (WIDTH + (TagType_TAG_WIDTH + 4))) + 1)]),
				.status_o(opgrp_outputs[(opgrp * ((WIDTH + 5) + TagType_TAG_WIDTH)) + (TagType_TAG_WIDTH + 4)-:((TagType_TAG_WIDTH + 4) >= (TagType_TAG_WIDTH + 0) ? ((TagType_TAG_WIDTH + 4) - (TagType_TAG_WIDTH + 0)) + 1 : ((TagType_TAG_WIDTH + 0) - (TagType_TAG_WIDTH + 4)) + 1)]),
				.extension_bit_o(opgrp_ext[opgrp]),
				.tag_o(opgrp_outputs[(opgrp * ((WIDTH + 5) + TagType_TAG_WIDTH)) + (TagType_TAG_WIDTH - 1)-:TagType_TAG_WIDTH]),
				.out_valid_o(opgrp_out_valid[opgrp]),
				.out_ready_i(opgrp_out_ready[opgrp]),
				.busy_o(opgrp_busy[opgrp])
			);
		end
	endgenerate
	wire [((WIDTH + 5) + TagType_TAG_WIDTH) - 1:0] arbiter_output;
	localparam [31:0] sv2v_uu_i_arbiter_NumIn = NUM_OPGROUPS;
	localparam [31:0] sv2v_uu_i_arbiter_IdxWidth = (sv2v_uu_i_arbiter_NumIn > 32'd1 ? $unsigned(2) : 32'd1);
	localparam [sv2v_uu_i_arbiter_IdxWidth - 1:0] sv2v_uu_i_arbiter_ext_rr_i_0 = 1'sb0;
	rr_arb_tree_DE4E6_76EE6 #(
		.DataType_TagType_TAG_WIDTH(TagType_TAG_WIDTH),
		.DataType_WIDTH(WIDTH),
		.NumIn(NUM_OPGROUPS),
		.AxiVldRdy(1'b1)
	) i_arbiter(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(flush_i),
		.rr_i(sv2v_uu_i_arbiter_ext_rr_i_0),
		.req_i(opgrp_out_valid),
		.gnt_o(opgrp_out_ready),
		.data_i(opgrp_outputs),
		.gnt_i(out_ready_i),
		.req_o(out_valid_o),
		.data_o(arbiter_output)
	);
	assign result_o = arbiter_output[WIDTH + (TagType_TAG_WIDTH + 4)-:((WIDTH + (TagType_TAG_WIDTH + 4)) >= (5 + (TagType_TAG_WIDTH + 0)) ? ((WIDTH + (TagType_TAG_WIDTH + 4)) - (5 + (TagType_TAG_WIDTH + 0))) + 1 : ((5 + (TagType_TAG_WIDTH + 0)) - (WIDTH + (TagType_TAG_WIDTH + 4))) + 1)];
	assign status_o = arbiter_output[TagType_TAG_WIDTH + 4-:((TagType_TAG_WIDTH + 4) >= (TagType_TAG_WIDTH + 0) ? ((TagType_TAG_WIDTH + 4) - (TagType_TAG_WIDTH + 0)) + 1 : ((TagType_TAG_WIDTH + 0) - (TagType_TAG_WIDTH + 4)) + 1)];
	assign tag_o = arbiter_output[TagType_TAG_WIDTH - 1-:TagType_TAG_WIDTH];
	assign busy_o = |opgrp_busy;
endmodule
module FPNewBlackbox (
	clk_i,
	rst_ni,
	operands_i,
	rnd_mode_i,
	op_i,
	op_mod_i,
	src_fmt_i,
	dst_fmt_i,
	int_fmt_i,
	vectorial_op_i,
	tag_i,
	in_valid_i,
	in_ready_o,
	flush_i,
	result_o,
	status_o,
	tag_o,
	out_valid_o,
	out_ready_i,
	busy_o
);
	parameter FLEN = 64;
	parameter ENABLE_VECTORS = 1;
	parameter ENABLE_NAN_BOX = 1;
	parameter ENABLE_FP32 = 1;
	parameter ENABLE_FP64 = 0;
	parameter ENABLE_FP16 = 0;
	parameter ENABLE_FP8 = 0;
	parameter ENABLE_FP16ALT = 0;
	parameter ENABLE_INT8 = 0;
	parameter ENABLE_INT16 = 0;
	parameter ENABLE_INT32 = 0;
	parameter ENABLE_INT64 = 0;
	parameter PIPELINE_STAGES = 1;
	parameter TAG_WIDTH = 2;
	localparam [31:0] WIDTH = FLEN;
	localparam [31:0] NUM_OPERANDS = 3;
	input wire clk_i;
	input wire rst_ni;
	input wire [(NUM_OPERANDS * WIDTH) - 1:0] operands_i;
	input wire [2:0] rnd_mode_i;
	localparam [31:0] fpnew_pkg_OP_BITS = 4;
	input wire [3:0] op_i;
	input wire op_mod_i;
	localparam [31:0] fpnew_pkg_NUM_FP_FORMATS = 5;
	localparam [31:0] fpnew_pkg_FP_FORMAT_BITS = 3;
	input wire [2:0] src_fmt_i;
	input wire [2:0] dst_fmt_i;
	localparam [31:0] fpnew_pkg_NUM_INT_FORMATS = 4;
	localparam [31:0] fpnew_pkg_INT_FORMAT_BITS = 2;
	input wire [1:0] int_fmt_i;
	input wire vectorial_op_i;
	input wire [TAG_WIDTH - 1:0] tag_i;
	input wire in_valid_i;
	output wire in_ready_o;
	input wire flush_i;
	output wire [WIDTH - 1:0] result_o;
	output wire [4:0] status_o;
	output wire [TAG_WIDTH - 1:0] tag_o;
	output wire out_valid_o;
	input wire out_ready_i;
	output wire busy_o;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [0:0] sv2v_cast_1;
		input reg [0:0] inp;
		sv2v_cast_1 = inp;
	endfunction
	function automatic [4:0] sv2v_cast_5;
		input reg [4:0] inp;
		sv2v_cast_5 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	localparam [42:0] Features = {sv2v_cast_32(FLEN), sv2v_cast_1(ENABLE_VECTORS), sv2v_cast_1(ENABLE_NAN_BOX), sv2v_cast_5(((((ENABLE_FP32 << 4) | (ENABLE_FP64 << 3)) | (ENABLE_FP16 << 2)) | (ENABLE_FP8 << 1)) | (ENABLE_FP16ALT << 0)), sv2v_cast_4((((ENABLE_INT8 << 3) | (ENABLE_INT16 << 2)) | (ENABLE_INT32 << 1)) | (ENABLE_INT64 << 0))};
	localparam [31:0] fpnew_pkg_NUM_OPGROUPS = 4;
	function automatic [((32'd4 * 32'd5) * 32) - 1:0] sv2v_cast_CDC93;
		input reg [((32'd4 * 32'd5) * 32) - 1:0] inp;
		sv2v_cast_CDC93 = inp;
	endfunction
	function automatic [((32'd4 * 32'd5) * 2) - 1:0] sv2v_cast_15FEF;
		input reg [((32'd4 * 32'd5) * 2) - 1:0] inp;
		sv2v_cast_15FEF = inp;
	endfunction
	localparam [(((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 32) + ((fpnew_pkg_NUM_OPGROUPS * fpnew_pkg_NUM_FP_FORMATS) * 2)) + 1:0] Implementation = {sv2v_cast_CDC93({{fpnew_pkg_NUM_FP_FORMATS {sv2v_cast_32(PIPELINE_STAGES)}}, {fpnew_pkg_NUM_FP_FORMATS {sv2v_cast_32(PIPELINE_STAGES)}}, {fpnew_pkg_NUM_FP_FORMATS {sv2v_cast_32(PIPELINE_STAGES)}}, {fpnew_pkg_NUM_FP_FORMATS {sv2v_cast_32(PIPELINE_STAGES)}}}), sv2v_cast_15FEF({{fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}, {fpnew_pkg_NUM_FP_FORMATS {2'd1}}, {fpnew_pkg_NUM_FP_FORMATS {2'd2}}}), 2'd0};
	fpnew_top_21317_11D0A #(
		.TagType_TAG_WIDTH(TAG_WIDTH),
		.Features(Features),
		.Implementation(Implementation)
	) inst(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.operands_i(operands_i),
		.rnd_mode_i(rnd_mode_i),
		.op_i(op_i),
		.op_mod_i(op_mod_i),
		.src_fmt_i(src_fmt_i),
		.dst_fmt_i(dst_fmt_i),
		.int_fmt_i(int_fmt_i),
		.vectorial_op_i(vectorial_op_i),
		.tag_i(tag_i),
		.in_valid_i(in_valid_i),
		.in_ready_o(in_ready_o),
		.flush_i(flush_i),
		.result_o(result_o),
		.status_o(status_o),
		.tag_o(tag_o),
		.out_valid_o(out_valid_o),
		.out_ready_i(out_ready_i),
		.busy_o(busy_o)
	);
endmodule
