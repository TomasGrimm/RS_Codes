import os, sys

file_to_write = "temp_vhd.txt"
file_to_read = sys.argv[1]

# tenta remover arquivo, caso ja exista
try:
    os.remove(file_to_write)
except OSError:
    pass

# abre arquivo a ser escrito
write_fd = open(file_to_write, "w")

# abre arquivo a ser lido
with open(file_to_read) as fd:

    # le cada uma das linhas
    for line in fd:
        
        # remove o simbolo de nova linha
        line = line.strip("\n")
        
        # escreve a linha formatada no novo arquivo
        write_fd.write("        \"")
        write_fd.write(line)
        write_fd.write("\\n\"\n")

write_fd.close()
