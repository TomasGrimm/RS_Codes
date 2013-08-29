#!/bin/bash
# Script de teste do Código Reed-Solomon (255, 239)

counter=0

cd /home/tomasgrimm/Dropbox/Mestrado/Dissertation/Codes/RS_255_239/Decoder/tb/
./RS_decoder_vcom &&

cd ../../Tests

while [ $counter -ne 2000 ];
do

echo=$counter

# Primeira parte
# são gerados os arquivos para usar como entrada no Codificador e Decodificador, assim como os arquivos de resultados
matlab -nosplash -nodesktop -r RS_code

# Segunda parte
# os módulos implementados em VHDL são exercitados e os resultados produzidos são armazenados em arquivos texto.
# Codificador
#cd ../Coder/tb/
#vsim -c -do RS_coder_tb.do &&

# Decodificador
cd ../Decoder/tb/
vsim -c -do RS_decoder_sim.do &&

# Terceira parte
# os arquivos gerados na segunda parte são comparados com os arquivos de saída gerados na primeira parte.
cd ../../Tests/
#echo $counter >> codeword_log
echo $counter >> estimated_log
#./compare_codeword codeword_golden.txt codeword_vhdl.txt >> codeword_log
./compare_estimated estimated_golden.txt estimated_vhdl.txt >> estimated_log

rm *.txt

((counter=$counter+1))
done
