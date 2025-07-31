if [file exists "work"] {vdel -all}
vlib work

#Compiling the RTL & Testbench Files
vlog -source -lint -sv design.sv
vlog -source -lint -sv testbench.sv

vopt async_fifo_TB -o async_fifo_TB_Opt +acc +cover=sbfec
vsim async_fifo_TB_Opt -coverage +UVM_TESTNAME=fifo_write
vcd file async_fifo_TB.vcd
vcd add -r async_fifo_TB/*

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save fifo_write.ucdb
quit -sim

vopt async_fifo_TB -o async_fifo_TB_Opt +acc +cover=sbfec
vsim async_fifo_TB_Opt -coverage +UVM_TESTNAME=fifo_read

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save fifo_read.ucdb
quit -sim

vopt async_fifo_TB -o async_fifo_TB_Opt +acc +cover=sbfec
vsim async_fifo_TB_Opt -coverage +UVM_TESTNAME=fifo_read_write

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save fifo_read_write.ucdb
quit -sim

vopt async_fifo_TB -o async_fifo_TB_Opt +acc +cover=sbfec
vsim async_fifo_TB_Opt -coverage +UVM_TESTNAME=fifo_full

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save fifo_full.ucdb
quit -sim

vopt async_fifo_TB -o async_fifo_TB_Opt +acc +cover=sbfec
vsim async_fifo_TB_Opt -coverage +UVM_TESTNAME=fifo_full_empty

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save fifo_full_empty.ucdb
quit -sim

vopt async_fifo_TB -o async_fifo_TB_Opt +acc +cover=sbfec
vsim async_fifo_TB_Opt -coverage +UVM_TESTNAME=simultaneous_read_write

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save simultaneous_read_write.ucdb
vcover merge output.ucdb fifo_write.ucdb fifo_read.ucdb fifo_read_write.ucdb fifo_full.ucdb fifo_full_empty.ucdb simultaneous_read_write.ucdb
#vcover report output.ucdb
vcover report output.ucdb -cvg -details

quit