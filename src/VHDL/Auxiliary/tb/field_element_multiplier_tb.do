quit -sim

vlib work

vcom ../src/ReedSolomon.vhd
vcom ../src/field_element_multiplier.vhd
vcom field_element_multiplier_tb.vhd

vsim work.field_element_multiplier_tb

view wave

add wave -label in_1 /field_element_multiplier_tb/in_1
add wave -label in_2 /field_element_multiplier_tb/in_2
add wave -label out /field_element_multiplier_tb/output

run 50 ns
wave zoom full