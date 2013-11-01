function print_file(bitstream, filename, symbol_length)
fd = fopen(filename, 'w');

for i = 1:size(bitstream, 1)
   fprintf(fd, '%d', bitstream(i, 1));
    
   if (mod(i, symbol_length) == 0)
       fprintf(fd, '\n');
   end
end

fclose(fd);