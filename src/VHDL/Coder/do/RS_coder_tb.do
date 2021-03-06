quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../src/RS_coder.vhd 
vcom RS_coder_tb.vhd

vsim -t ns work.RS_coder_tb

view wave

add wave /RS_coder_tb/clk
add wave /RS_coder_tb/rst
add wave /RS_coder_tb/m_str
add wave /RS_coder_tb/din
add wave /RS_coder_tb/dne
add wave /RS_coder_tb/dout

add wave -divider

#add wave -label "done" /RS_coder_tb/coder/done

#add wave -label message /RS_coder_tb/coder/message

#add wave -label "msg_ctr" -radix unsigned /RS_coder_tb/coder/encode/message_counter
#add wave -label "prt_ctr" -radix unsigned /RS_coder_tb/coder/encode/parity_counter
#add wave -label "feed_through" /RS_coder_tb/coder/encode/feed_through
#add wave -label "multiplicand_poly" /RS_coder_tb/coder/encode/multiplicand_poly
#add wave -label "intermediary_poly" /RS_coder_tb/coder/encode/intermediary_poly
#add wave -label delay /RS_coder_tb/coder/delay
#add wave -label par_ready /RS_coder_tb/coder/par_ready

add wave /RS_coder_tb/coder/*

run 3000 ns
wave zoom full

#quit -f
