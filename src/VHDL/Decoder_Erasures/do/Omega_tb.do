quit -sim

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../src/Omega.vhd
vcom ../tb/Omega_tb.vhd

vsim -t ns work.Omega_tb

add wave -label clock /omega_tb/eval_gen/clock 
add wave -label reset /omega_tb/eval_gen/reset 
add wave -label enable /omega_tb/eval_gen/enable 
add wave -label syndrome /omega_tb/eval_gen/syndrome 
add wave -label sigma /omega_tb/eval_gen/error_locator 
add wave -label done /omega_tb/eval_gen/done 
add wave -label omega /omega_tb/eval_gen/error_evaluator 
add wave -label enable_omega /omega_tb/eval_gen/enable_evaluator 
add wave -label eval_counter /omega_tb/eval_gen/evaluator_counter 
add wave -label discrepancy_syndromes /omega_tb/eval_gen/discrepancy_syndromes 
add wave -label mult_out /omega_tb/eval_gen/multiplicator_output 
add wave -label omega_temp /omega_tb/eval_gen/omega_temp 
add wave -label sigma_helper /omega_tb/eval_gen/sigma_helper

run 1000 ns
wave zoom full