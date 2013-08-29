quit -sim

vlib work

vcom ../Auxiliary/src/ReedSolomon.vhd
vcom ../Auxiliary/src/field_element_multiplier.vhd
vcom polynomial_evaluator.vhd
vcom polynomial_evaluator_tb.vhd

vsim work.polynomial_evaluator_tb

view wave

add wave -label x /polynomial_evaluator_tb/element
add wave -label poly /polynomial_evaluator_tb/poly
add wave -label y /polynomial_evaluator_tb/output

run 100 ns
