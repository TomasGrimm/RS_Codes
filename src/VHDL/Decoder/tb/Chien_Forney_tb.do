quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../../Auxiliary/src/scalar_multiplier.vhd
vcom ../src/Chien_Forney.vhd 
vcom Chien_Forney_tb.vhd

vsim work.Chien_Forney_tb
view wave

add wave -divider "In/Out"
add wave -label clock /Chien_Forney_tb/clk
add wave -label reset /Chien_Forney_tb/rst
add wave -label enable /Chien_Forney_tb/ena
add wave -label syndrome /Chien_Forney_tb/syn
add wave -label "error_locator" /Chien_Forney_tb/erl
add wave -label done /Chien_Forney_tb/dne
add wave -label "estimate_codeword" /Chien_Forney_tb/est

add wave -divider States
add wave -label CS /Chien_Forney_tb/CF/current_state
add wave -label NS /Chien_Forney_tb/CF/next_state

add wave -divider
add wave -label "omega" /Chien_Forney_tb/CF/omega
add wave -label "syndrome_element" /Chien_Forney_tb/CF/syndrome_element
add wave -label "omega_step" /Chien_Forney_tb/CF/omega_step
add wave -label "syndrome_index" /Chien_Forney_tb/CF/syndrome_index

add wave -label "mult1_a" /Chien_Forney_tb/CF/mult1_a
add wave -label "mult1_b" /Chien_Forney_tb/CF/mult1_b
add wave -label "mult1_out" /Chien_Forney_tb/CF/mult1_out
add wave -label "mult2_a" /Chien_Forney_tb/CF/mult2_a
add wave -label "mult2_b" /Chien_Forney_tb/CF/mult2_b
add wave -label "mult2_out" /Chien_Forney_tb/CF/mult2_out

add wave -label "is_root" /Chien_Forney_tb/CF/is_root
add wave -label "alpha" /Chien_Forney_tb/CF/alpha
add wave -label "codeword_index" /Chien_Forney_tb/CF/codeword_index
add wave -label "is_last_element" /Chien_Forney_tb/CF/is_last_element
add wave -label "sigma_derived" /Chien_Forney_tb/CF/sigma_derived
add wave -label "key_counter" /Chien_Forney_tb/CF/key_counter
add wave -label "key_evaluated" /Chien_Forney_tb/CF/key_evaluated

add wave -label "omega_index" /Chien_Forney_tb/CF/omega_index
add wave -label "omega_evaluated" /Chien_Forney_tb/CF/omega_evaluated
add wave -label "sigma_derived_evaluated" /Chien_Forney_tb/CF/sigma_derived_evaluated

run 65000 ns
#wave zoom full

quit -f