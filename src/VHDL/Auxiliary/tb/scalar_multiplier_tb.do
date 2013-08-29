quit -sim

vlib work

vcom ../src/ReedSolomon.vhd
vcom ../src/field_element_multiplier.vhd
vcom ../src/scalar_multiplier.vhd
vcom scalar_multiplier_tb.vhd

vsim work.scalar_multiplier_tb

view wave

add wave -label elmt /scalar_multiplier_tb/elmt
add wave -label poly /scalar_multiplier_tb/poly
add wave -label mult /scalar_multiplier_tb/mult

run 50 ns
wave zoom full