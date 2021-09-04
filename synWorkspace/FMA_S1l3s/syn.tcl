# usage: dc_shell -f syn.tcl

# load library if config exists
set rc [file exist ~/library.tcl]
if {$rc == 1} {
	source ~/library.tcl
}

# args
set input_files [list FMA_S1l3s.v]
set toplevel_name FMA_S1l3s

# load design
read_file -format verilog $input_files
current_design $toplevel_name

# setup
set_host_options -max_cores 16

# timing
# 1GHz clock
create_clock clock -period 1.0000
# dff clock to output: 0.14ns
# assume all input comes from output of dff
set_input_delay 0.14 -clock clock [all inputs]

# synthesis flow
link
uniquify
ungroup -flatten -all
compile_ultra -retime

# export
write -format ddc -hierarchy -output [format "%s%s" $toplevel_name ".ddc"]
write_sdf -version 1.0 [format "%s%s" $toplevel_name ".sdf"]
write -format verilog -hierarchy -output [format "%s%s" $toplevel_name ".syn.v"]
write_sdc [format "%s%s" $toplevel_name ".sdc"]

# reports
check_timing > ${toplevel_name}_check_timing.txt
check_design > ${toplevel_name}_check_design.txt
report_design > ${toplevel_name}_report_design.txt
report_area -hierarchy > ${toplevel_name}_report_area.txt
report_power -hierarchy > ${toplevel_name}_report_power.txt
report_cell > ${toplevel_name}_report_cell.txt
report_timing -delay_type max -max_paths 5 > ${toplevel_name}_report_timing_setup.txt
report_timing -delay_type min -max_paths 5 > ${toplevel_name}_report_timing_hold.txt
report_constraint -all_violators > ${toplevel_name}_report_constraint.txt
report_qor > ${toplevel_name}_report_qor.txt

# quit
quit