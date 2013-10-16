quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../src/BerlekampMassey.vhd 
vcom BerlekampMassey_tb.vhd

vsim -t ns work.BerlekampMassey_tb

add wave -label clk /BerlekampMassey_tb/clk
add wave -label rst /BerlekampMassey_tb/rst
add wave -label ena /BerlekampMassey_tb/ena
add wave -label syn /BerlekampMassey_tb/syn
add wave -label dne /BerlekampMassey_tb/dne
add wave -label elp /BerlekampMassey_tb/elp
add wave -label eep /BerlekampMassey_tb/eep

add wave -divider

add wave -label enable_locator /BerlekampMassey_tb/BM/enable_locator
add wave -label enable_evaluator /BerlekampMassey_tb/BM/enable_evaluator
add wave -label discrepancy /BerlekampMassey_tb/BM/discrepancy
add wave -label sigma /berlekampmassey_tb/BM/sigma
add wave -label temp_sigma /berlekampmassey_tb/BM/temp_sigma
add wave -label L -radix unsigned /berlekampmassey_tb/BM/L
add wave -label B /BerlekampMassey_tb/BM/B
add wave -label delta /BerlekampMassey_tb/BM/delta
add wave -label theta /BerlekampMassey_tb/BM/theta

add wave -divider

add wave -label locator_counter -radix unsigned /berlekampmassey_tb/BM/locator_counter
add wave -label phase /berlekampmassey_tb/BM/phase
add wave -label discrepancy_syndromes /berlekampmassey_tb/BM/discrepancy_syndromes
add wave -label mult_in1 /berlekampmassey_tb/BM/multiplicator_input_1
add wave -label mult_in2 /berlekampmassey_tb/BM/multiplicator_input_2
add wave -label mult_out /berlekampmassey_tb/BM/multiplicator_output
add wave -label omega /berlekampmassey_tb/BM/omega
add wave -label evaluator_counter -radix unsigned /berlekampmassey_tb/BM/evaluator_counter

run 1500 ns
wave zoom full

#quit -f