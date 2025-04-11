onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/DUT/position
add wave -noupdate /tb/DUT/digit
add wave -noupdate /tb/DUT/clock
add wave -noupdate /tb/DUT/reset
add wave -noupdate /tb/DUT/data
add wave -noupdate /tb/DUT/count
add wave -noupdate -color {Orange Red} /tb/DUT/EA
add wave -noupdate -color {Orange Red} /tb/DUT/PE
add wave -noupdate -color {Orange Red} -radix unsigned -radixshowbase 0 /tb/DUT/cont
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1241 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {4515 ns}

