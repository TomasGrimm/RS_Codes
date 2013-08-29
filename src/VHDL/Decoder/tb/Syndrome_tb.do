quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../src/Syndrome.vhd 
vcom Syndrome_tb.vhd

vsim work.Syndrome_tb

view wave

add wave /Syndrome_tb/clk
add wave /Syndrome_tb/rst
add wave /Syndrome_tb/ena
add wave /Syndrome_tb/rcv
add wave /Syndrome_tb/dne
add wave /Syndrome_tb/noerr
add wave /Syndrome_tb/sdm

add wave -divider

add wave /Syndrome_tb/synd/syndromes
add wave /Syndrome_tb/synd/counter

run 3000 ns
#wave zoom full

quit -f