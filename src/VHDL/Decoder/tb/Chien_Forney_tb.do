quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../../Auxiliary/src/inversion_table.vhd
vcom ../src/Chien_Forney.vhd 
vcom Chien_Forney_tb.vhd

vsim work.Chien_Forney_tb
view wave

add wave -divider "In/Out"
add wave -label clock /Chien_Forney_tb/clk
add wave -label reset /Chien_Forney_tb/rst
add wave -label enable /Chien_Forney_tb/ena
add wave -label "error_locator" /Chien_Forney_tb/erl
add wave -label "error_evaluator" /Chien_Forney_tb/eep
add wave -label done /Chien_Forney_tb/dne
add wave -label is_root /Chien_Forney_tb/root
add wave -label processing /Chien_Forney_tb/working
add wave -label index /Chien_Forney_tb/index
add wave -label "error_magnitude" /Chien_Forney_tb/err_mag

add wave -divider

add wave -label partial_error_locator /Chien_Forney_tb/CF/partial_error_locator
add wave -label partial_error_evaluator /Chien_Forney_tb/CF/partial_error_evaluator
add wave -label "error_locator_out" /Chien_Forney_tb/CF/error_locator_out
add wave -label "error_evaluator_out" /Chien_Forney_tb/CF/error_evaluator_out
add wave -label "sigma_input" /Chien_Forney_tb/CF/sigma_input
add wave -label "counter" /Chien_Forney_tb/CF/counter
add wave -label "sigma_sum" /Chien_Forney_tb/CF/sigma_sum
add wave -label "sigma_derived" /Chien_Forney_tb/CF/sigma_derived
add wave -label "sigma_inverted" /Chien_Forney_tb/CF/sigma_inverted
add wave -label "omega_sum" /Chien_Forney_tb/CF/omega_sum
add wave -label "enable_op" /Chien_Forney_tb/CF/enable_operation

run 2700 ns
wave zoom full

#quit -f