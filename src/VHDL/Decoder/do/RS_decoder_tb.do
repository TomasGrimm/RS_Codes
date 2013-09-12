quit -sim

vlib work

vcom ../../Auxiliary/src/ReedSolomon.vhd
vcom ../../Auxiliary/src/field_element_multiplier.vhd
vcom ../../Auxiliary/src/inversion_table.vhd
vcom -check_synthesis ../src/Syndrome.vhd
vcom -check_synthesis ../src/Erasure.vhd
vcom -check_synthesis ../src/BerlekampMassey.vhd
vcom -check_synthesis ../src/Chien_Forney.vhd
vcom -check_synthesis ../src/RS_decoder.vhd

vcom ../tb/RS_decoder_tb.vhd

vsim -t ns work.RS_decoder_tb

view wave

add wave -divider "I/O"
add wave -label clock /RS_decoder_tb/clk
add wave -label reset /RS_decoder_tb/rst
add wave -label start_block /RS_decoder_tb/srt_blk
add wave -label erase /RS_decoder_tb/era
add wave -label data_in /RS_decoder_tb/din
add wave -label fail /RS_decoder_tb/fl
add wave -label done /RS_decoder_tb/dne
add wave -label data_out /RS_decoder_tb/dot

add wave -divider "Internal"
add wave -label syndrome_done /RS_decoder_tb/decoder/syndrome_done
add wave -label erasure_done /RS_decoder_tb/decoder/erasure_done
add wave -label enable_bm /RS_decoder_tb/decoder/enable_bm
add wave -label bm_done /RS_decoder_tb/decoder/bm_done
add wave -label cf_done /RS_decoder_tb/decoder/cf_done
add wave -label syndrome_output /RS_decoder_tb/decoder/syndrome_reg
add wave -label erasure_output /RS_decoder_tb/decoder/erasure_reg
add wave -label received /RS_decoder_tb/decoder/received
add wave -label output_index /RS_decoder_tb/decoder/output_index
add wave -label cf_index /RS_decoder_tb/decoder/cf_index
add wave -label magnitude /RS_decoder_tb/decoder/cf_magnitude
add wave -label root /RS_decoder_tb/decoder/cf_root
add wave -label processing /RS_decoder_tb/decoder/cf_processing
add wave -label received_is_codeword /RS_decoder_tb/decoder/received_is_codeword

add wave -divider

add wave -label counter /RS_decoder_tb/counter
add wave -label erasures_count /RS_decoder_tb/decoder/erasures_count
add wave -label sigma /RS_decoder_tb/decoder/bm_locator_output
add wave -label omega /RS_decoder_tb/decoder/bm_evaluator_output

run 7000 ns
wave zoom full

#quit -f