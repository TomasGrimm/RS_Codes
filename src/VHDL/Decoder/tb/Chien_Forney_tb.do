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

add wave -label "error_locator_out" /Chien_Forney_tb/CF/error_locator_out
add wave -label "error_evaluator_out" /Chien_Forney_tb/CF/error_evaluator_out
add wave -label "sigma_input" /Chien_Forney_tb/CF/sigma_input
add wave -label "iterations" /Chien_Forney_tb/CF/iterations_counter
add wave -label "alpha" /Chien_Forney_tb/CF/alpha
add wave -label "alpha_not" /Chien_Forney_tb/CF/alpha_not
add wave -label "sigma_sum" /Chien_Forney_tb/CF/sigma_sum
add wave -label "sigma_derived" /Chien_Forney_tb/CF/sigma_derived
add wave -label "sigma_inverted" /Chien_Forney_tb/CF/sigma_inverted
add wave -label "omega_sum" /Chien_Forney_tb/CF/omega_sum
add wave -label "omega_scaled" /Chien_Forney_tb/CF/omega_scaled
add wave -label "sum_and_compare" /Chien_Forney_tb/CF/sum_and_compare
add wave -label first_iter /Chien_Forney_tb/CF/first_iteration
add wave -label current_state /Chien_Forney_tb/CF/current_state
add wave -label next_state /Chien_Forney_tb/CF/next_state

run 2700 ns
wave zoom full

#quit -f