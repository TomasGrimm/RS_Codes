quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../../Auxiliary/src/scalar_multiplier.vhd
vcom ../src/Syndrome.vhd
vcom ../src/BerlekampMassey.vhd
vcom ../src/Chien_Forney.vhd
vcom ../src/RS_decoder.vhd

vcom RS_decoder_tb.vhd

vsim work.RS_decoder_tb

view wave

add wave -divider "I/O"
add wave -label clock /RS_decoder_tb/clk
add wave -label reset /RS_decoder_tb/rst
add wave -label enable /RS_decoder_tb/ena
add wave -label data_in /RS_decoder_tb/din
add wave -label done /RS_decoder_tb/dne
add wave -label data_out /RS_decoder_tb/dot

add wave -divider "Internal"
add wave -label syndrome_done /RS_decoder_tb/decoder/syndrome_done
add wave -label bm_done /RS_decoder_tb/decoder/bm_done
add wave -label cf_done /RS_decoder_tb/decoder/cf_done
add wave -label syndrome_output /RS_decoder_tb/decoder/syndrome_output
add wave -label bm_output /RS_decoder_tb/decoder/bm_output
add wave -label received /RS_decoder_tb/decoder/received
add wave -label received_index /RS_decoder_tb/decoder/received_index
add wave -label output_index /RS_decoder_tb/decoder/output_index

add wave -label syndrome_reg /RS_decoder_tb/decoder/syndrome_reg
add wave -label bm_reg /RS_decoder_tb/decoder/bm_reg

add wave -label cf_internal /RS_decoder_tb/cf_internal

add wave -label cf_mags /RS_decoder_tb/decoder/cf_magnitudes
add wave -label cf_inds /RS_decoder_tb/decoder/cf_indices
add wave -label errors_counter /RS_decoder_tb/decoder/errors_counter

#add wave -divider "Syndrome"
#add wave -label "clock" /RS_decoder_tb/decoder/syndrome_module/clock
#add wave -label "reset" /RS_decoder_tb/decoder/syndrome_module/reset
#add wave -label "enable" /RS_decoder_tb/decoder/syndrome_module/enable
#add wave -label "received_vector" /RS_decoder_tb/decoder/syndrome_module/received_vector
#add wave -label "done" /RS_decoder_tb/decoder/syndrome_module/done
#add wave -label "syndrome" /RS_decoder_tb/decoder/syndrome_module/syndrome
#add wave -label "counter" /RS_decoder_tb/decoder/syndrome_module/counter
#add wave -label "alphas" /RS_decoder_tb/decoder/syndrome_module/alphas
#add wave -label "syndromes" /RS_decoder_tb/decoder/syndrome_module/syndromes
#add wave -label "multiplications" /RS_decoder_tb/decoder/syndrome_module/multiplications

run 70000 ns
wave zoom full

#quit -f