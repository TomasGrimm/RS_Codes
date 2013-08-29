quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../../Auxiliary/src/scalar_multiplier.vhd
vcom ../../Auxiliary/src/inversion_table.vhd
vcom -check_synthesis ../src/Syndrome.vhd
vcom -check_synthesis ../src/BerlekampMassey.vhd
vcom -check_synthesis ../src/Chien_Forney.vhd
vcom -check_synthesis ../src/RS_decoder.vhd

vcom RS_decoder_tb.vhd

vsim work.RS_decoder_tb

view wave

add wave -divider "I/O"
add wave -label clock /RS_decoder_tb/clk
add wave -label reset /RS_decoder_tb/rst
add wave -label start_block /RS_decoder_tb/srt_blk
add wave -label data_in /RS_decoder_tb/din
add wave -label done /RS_decoder_tb/dne
add wave -label data_out /RS_decoder_tb/dot

add wave -divider "Internal"
add wave -label syndrome_done /RS_decoder_tb/decoder/syndrome_done
add wave -label bm_done /RS_decoder_tb/decoder/bm_done
add wave -label cf_done /RS_decoder_tb/decoder/cf_done
add wave -label syndrome_output /RS_decoder_tb/decoder/syndrome_reg
add wave -label bm_locator /RS_decoder_tb/decoder/bm_locator_reg
add wave -label bm_evaluator /RS_decoder_tb/decoder/bm_evaluator_reg
add wave -label received /RS_decoder_tb/decoder/received
add wave -label received_index /RS_decoder_tb/decoder/received_index
add wave -label output_index /RS_decoder_tb/decoder/output_index
add wave -label cf_index /RS_decoder_tb/decoder/cf_index
add wave -label magnitude /RS_decoder_tb/decoder/cf_magnitude
add wave -label root /RS_decoder_tb/decoder/cf_root
add wave -label processing /RS_decoder_tb/decoder/cf_processing
add wave -label received_is_codeword /RS_decoder_tb/decoder/received_is_codeword

run 7000 ns
wave zoom full

#quit -f