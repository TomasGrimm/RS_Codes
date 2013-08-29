vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../src/Euclidean.vhd
vcom Euclidean_tb.vhd

vsim -t ns work.Euclidean_tb

add wave -label clk /Euclidean_tb/clk
add wave -label rst /Euclidean_tb/rst
add wave -label ena /Euclidean_tb/ena
add wave -label syn /Euclidean_tb/syn
add wave -label dne /Euclidean_tb/dne
add wave -label erl /Euclidean_tb/erl
add wave -label ere /Euclidean_tb/ere

add wave -divider

add wave -label CS /Euclidean_tb/euclids/current_state
add wave -label NS /Euclidean_tb/euclids/next_state
add wave -label sigma /euclidean_tb/euclids/sigma 
add wave -label not_done /euclidean_tb/euclids/not_done
add wave -label R /euclidean_tb/euclids/R
add wave -label Q /euclidean_tb/euclids/Q
add wave -label mu /euclidean_tb/euclids/mu
add wave -label lambda /euclidean_tb/euclids/lambda
add wave -label R_counter /euclidean_tb/euclids/R_counter
add wave -label Q_counter /euclidean_tb/euclids/Q_counter
#add wave -label l /euclidean_tb/euclids/l

add wave -divider

#add wave -label "first_half_element" /euclidean_tb/euclids/first_half_element 
#add wave -label "second_half_element" /euclidean_tb/euclids/second_half_element 
add wave -label "a" /euclidean_tb/euclids/a 
add wave -label "b" /euclidean_tb/euclids/b 
#add wave -label "first_half_poly" /euclidean_tb/euclids/first_half_poly 
#add wave -label "second_half_poly" /euclidean_tb/euclids/second_half_poly 
#add wave -label "first_half_output" /euclidean_tb/euclids/first_half_output 
#add wave -label "second_half_output" /euclidean_tb/euclids/second_half_output

run 4000 ns
wave zoom full