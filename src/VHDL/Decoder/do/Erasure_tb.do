quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../src/Erasure.vhd 
vcom ../tb/Erasure_tb.vhd

vsim -t ns work.Erasure_tb

view wave
view transcript

add wave -label clk /Erasure_tb/clk
add wave -label rst /Erasure_tb/rst
add wave -label str /Erasure_tb/str
add wave -label era /Erasure_tb/era
add wave -label dne /Erasure_tb/dne
add wave -label ers /Erasure_tb/ers
add wave -label cnt -radix unsigned /Erasure_tb/cnt

add wave -divider

add wave -label alpha /Erasure_tb/erasurer/alpha
add wave -label not_another_alpha /Erasure_tb/not_another_alpha
add wave -label enable /erasure_tb/erasurer/enable_operation
add wave -label counter -radix unsigned /erasure_tb/erasurer/counter
add wave -label temp_erasures /erasure_tb/erasurer/temp_erasures
add wave -label mults_out /erasure_tb/erasurer/multipliers_output

run 3000 ns
wave zoom full

#quit -f