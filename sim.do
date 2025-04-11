if {[file isdirectory work]} { vdel -all -lib work }
vlib work
vmap work work

vcom -mixedsvvh -work work display.vhd
vcom -mixedsvvh -work work control.sv
vcom -mixedsvvh -work work tb.vhd

vsim -voptargs=+acc=lprn -t ns work.tb

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

do wave.do 

run 4 us
