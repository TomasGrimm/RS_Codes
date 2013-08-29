quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../../Auxiliary/src/scalar_multiplier.vhd
vcom ../src/BerlekampMassey.vhd 
vcom BerlekampMassey_tb.vhd

vsim work.BerlekampMassey_tb

add wave -label clk /BerlekampMassey_tb/clk
add wave -label rst /BerlekampMassey_tb/rst
add wave -label ena /BerlekampMassey_tb/ena
add wave -label syn /BerlekampMassey_tb/syn
add wave -label dne /BerlekampMassey_tb/dne
add wave -label equ /BerlekampMassey_tb/equ

add wave -divider

add wave -label syn /BerlekampMassey_tb/syn
add wave -label discrepancy /BerlekampMassey_tb/BM/discrepancy
add wave -label sigma /BerlekampMassey_tb/BM/sigma
add wave -label L /BerlekampMassey_tb/BM/L
add wave -label B /BerlekampMassey_tb/BM/B
add wave -label lambda /BerlekampMassey_tb/BM/lambda
add wave -label theta /BerlekampMassey_tb/BM/theta

add wave -label CS /BerlekampMassey_tb/BM/current_state
#add wave -label NS /BerlekampMassey_tb/BM/next_state
#add wave -label sigma /BerlekampMassey_tb/BM/sigma
#add wave -label B /BerlekampMassey_tb/BM/B
#add wave -label discrepancy /BerlekampMassey_tb/BM/discrepancy
#add wave -label theta /BerlekampMassey_tb/BM/theta
#add wave -label L /BerlekampMassey_tb/BM/L
#add wave -label lambda /BerlekampMassey_tb/BM/lambda

#add wave -divider

#add wave -label index /BerlekampMassey_tb/BM/index
#add wave -label discrepancy_index /BerlekampMassey_tb/BM/discrepancy_index
#add wave -label discrepancy_A /BerlekampMassey_tb/BM/discrepancy_A
#add wave -label discrepancy_B /BerlekampMassey_tb/BM/discrepancy_B
#add wave -label discrepancy_product /BerlekampMassey_tb/BM/discrepancy_product

#add wave -divider

#add wave -label sigma_A /BerlekampMassey_tb/BM/sigma_A
#add wave -label sigma_B /BerlekampMassey_tb/BM/sigma_B
#add wave -label sigma_product /BerlekampMassey_tb/BM/sigma_product
#add wave -label sigmaX_A /BerlekampMassey_tb/BM/sigmaX_A
#add wave -label sigmaX_B /BerlekampMassey_tb/BM/sigmaX_B
#add wave -label sigmaX_product /BerlekampMassey_tb/BM/sigmaX_product

#add wave -divider

#add wave -label double_L /BerlekampMassey_tb/BM/double_L

run 1200 ns
wave zoom full

#quit -f