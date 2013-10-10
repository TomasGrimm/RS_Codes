#include <fstream>

void Write_Inversion_Table(int primPoly)
{
  std::fstream fd;

  fd.open("RS_Inversion_Table.vhd", std::fstream::out);

  fd << "library IEEE;\n"
        "use IEEE.std_logic_1164.all;\n"
        "use IEEE.numeric_std.all;\n"
        "use work.ReedSolomon.all;\n"
        "\n"
        "entity inversion_table is\n"
        "  port (\n"
        "    input  : in  field_element;\n"
        "    output : out field_element);\n"
        "end inversion_table;\n"
        "\n"
        "architecture inversion_table of inversion_table is\n"
        "  type rom_table is array (0 to N_LENGTH) of field_element;\n"
        "  constant inversion : rom_table := (";

  if (primPoly == 285)
  {
    fd << "\"00000000\",\n"
          "                                    \"00000001\",\n"
          "                                    \"10001110\",\n"
          "                                    \"11110100\",\n"
          "                                    \"01000111\",\n"
          "                                    \"10100111\",\n"
          "                                    \"01111010\",\n"
          "                                    \"10111010\",\n"
          "                                    \"10101101\",\n"
          "                                    \"10011101\",\n"
          "                                    \"11011101\",\n"
          "                                    \"10011000\",\n"
          "                                    \"00111101\",\n"
          "                                    \"10101010\",\n"
          "                                    \"01011101\",\n"
          "                                    \"10010110\",\n"
          "                                    \"11011000\",\n"
          "                                    \"01110010\",\n"
          "                                    \"11000000\",\n"
          "                                    \"01011000\",\n"
          "                                    \"11100000\",\n"
          "                                    \"00111110\",\n"
          "                                    \"01001100\",\n"
          "                                    \"01100110\",\n"
          "                                    \"10010000\",\n"
          "                                    \"11011110\",\n"
          "                                    \"01010101\",\n"
          "                                    \"10000000\",\n"
          "                                    \"10100000\",\n"
          "                                    \"10000011\",\n"
          "                                    \"01001011\",\n"
          "                                    \"00101010\",\n"
          "                                    \"01101100\",\n"
          "                                    \"11101101\",\n"
          "                                    \"00111001\",\n"
          "                                    \"01010001\",\n"
          "                                    \"01100000\",\n"
          "                                    \"01010110\",\n"
          "                                    \"00101100\",\n"
          "                                    \"10001010\",\n"
          "                                    \"01110000\",\n"
          "                                    \"11010000\",\n"
          "                                    \"00011111\",\n"
          "                                    \"01001010\",\n"
          "                                    \"00100110\",\n"
          "                                    \"10001011\",\n"
          "                                    \"00110011\",\n"
          "                                    \"01101110\",\n"
          "                                    \"01001000\",\n"
          "                                    \"10001001\",\n"
          "                                    \"01101111\",\n"
          "                                    \"00101110\",\n"
          "                                    \"10100100\",\n"
          "                                    \"11000011\",\n"
          "                                    \"01000000\",\n"
          "                                    \"01011110\",\n"
          "                                    \"01010000\",\n"
          "                                    \"00100010\",\n"
          "                                    \"11001111\",\n"
          "                                    \"10101001\",\n"
          "                                    \"10101011\",\n"
          "                                    \"00001100\",\n"
          "                                    \"00010101\",\n"
          "                                    \"11100001\",\n"
          "                                    \"00110110\",\n"
          "                                    \"01011111\",\n"
          "                                    \"11111000\",\n"
          "                                    \"11010101\",\n"
          "                                    \"10010010\",\n"
          "                                    \"01001110\",\n"
          "                                    \"10100110\",\n"
          "                                    \"00000100\",\n"
          "                                    \"00110000\",\n"
          "                                    \"10001000\",\n"
          "                                    \"00101011\",\n"
          "                                    \"00011110\",\n"
          "                                    \"00010110\",\n"
          "                                    \"01100111\",\n"
          "                                    \"01000101\",\n"
          "                                    \"10010011\",\n"
          "                                    \"00111000\",\n"
          "                                    \"00100011\",\n"
          "                                    \"01101000\",\n"
          "                                    \"10001100\",\n"
          "                                    \"10000001\",\n"
          "                                    \"00011010\",\n"
          "                                    \"00100101\",\n"
          "                                    \"01100001\",\n"
          "                                    \"00010011\",\n"
          "                                    \"11000001\",\n"
          "                                    \"11001011\",\n"
          "                                    \"01100011\",\n"
          "                                    \"10010111\",\n"
          "                                    \"00001110\",\n"
          "                                    \"00110111\",\n"
          "                                    \"01000001\",\n"
          "                                    \"00100100\",\n"
          "                                    \"01010111\",\n"
          "                                    \"11001010\",\n"
          "                                    \"01011011\",\n"
          "                                    \"10111001\",\n"
          "                                    \"11000100\",\n"
          "                                    \"00010111\",\n"
          "                                    \"01001101\",\n"
          "                                    \"01010010\",\n"
          "                                    \"10001101\",\n"
          "                                    \"11101111\",\n"
          "                                    \"10110011\",\n"
          "                                    \"00100000\",\n"
          "                                    \"11101100\",\n"
          "                                    \"00101111\",\n"
          "                                    \"00110010\",\n"
          "                                    \"00101000\",\n"
          "                                    \"11010001\",\n"
          "                                    \"00010001\",\n"
          "                                    \"11011001\",\n"
          "                                    \"11101001\",\n"
          "                                    \"11111011\",\n"
          "                                    \"11011010\",\n"
          "                                    \"01111001\",\n"
          "                                    \"11011011\",\n"
          "                                    \"01110111\",\n"
          "                                    \"00000110\",\n"
          "                                    \"10111011\",\n"
          "                                    \"10000100\",\n"
          "                                    \"11001101\",\n"
          "                                    \"11111110\",\n"
          "                                    \"11111100\",\n"
          "                                    \"00011011\",\n"
          "                                    \"01010100\",\n"
          "                                    \"10100001\",\n"
          "                                    \"00011101\",\n"
          "                                    \"01111100\",\n"
          "                                    \"11001100\",\n"
          "                                    \"11100100\",\n"
          "                                    \"10110000\",\n"
          "                                    \"01001001\",\n"
          "                                    \"00110001\",\n"
          "                                    \"00100111\",\n"
          "                                    \"00101101\",\n"
          "                                    \"01010011\",\n"
          "                                    \"01101001\",\n"
          "                                    \"00000010\",\n"
          "                                    \"11110101\",\n"
          "                                    \"00011000\",\n"
          "                                    \"11011111\",\n"
          "                                    \"01000100\",\n"
          "                                    \"01001111\",\n"
          "                                    \"10011011\",\n"
          "                                    \"10111100\",\n"
          "                                    \"00001111\",\n"
          "                                    \"01011100\",\n"
          "                                    \"00001011\",\n"
          "                                    \"11011100\",\n"
          "                                    \"10111101\",\n"
          "                                    \"10010100\",\n"
          "                                    \"10101100\",\n"
          "                                    \"00001001\",\n"
          "                                    \"11000111\",\n"
          "                                    \"10100010\",\n"
          "                                    \"00011100\",\n"
          "                                    \"10000010\",\n"
          "                                    \"10011111\",\n"
          "                                    \"11000110\",\n"
          "                                    \"00110100\",\n"
          "                                    \"11000010\",\n"
          "                                    \"01000110\",\n"
          "                                    \"00000101\",\n"
          "                                    \"11001110\",\n"
          "                                    \"00111011\",\n"
          "                                    \"00001101\",\n"
          "                                    \"00111100\",\n"
          "                                    \"10011100\",\n"
          "                                    \"00001000\",\n"
          "                                    \"10111110\",\n"
          "                                    \"10110111\",\n"
          "                                    \"10000111\",\n"
          "                                    \"11100101\",\n"
          "                                    \"11101110\",\n"
          "                                    \"01101011\",\n"
          "                                    \"11101011\",\n"
          "                                    \"11110010\",\n"
          "                                    \"10111111\",\n"
          "                                    \"10101111\",\n"
          "                                    \"11000101\",\n"
          "                                    \"01100100\",\n"
          "                                    \"00000111\",\n"
          "                                    \"01111011\",\n"
          "                                    \"10010101\",\n"
          "                                    \"10011010\",\n"
          "                                    \"10101110\",\n"
          "                                    \"10110110\",\n"
          "                                    \"00010010\",\n"
          "                                    \"01011001\",\n"
          "                                    \"10100101\",\n"
          "                                    \"00110101\",\n"
          "                                    \"01100101\",\n"
          "                                    \"10111000\",\n"
          "                                    \"10100011\",\n"
          "                                    \"10011110\",\n"
          "                                    \"11010010\",\n"
          "                                    \"11110111\",\n"
          "                                    \"01100010\",\n"
          "                                    \"01011010\",\n"
          "                                    \"10000101\",\n"
          "                                    \"01111101\",\n"
          "                                    \"10101000\",\n"
          "                                    \"00111010\",\n"
          "                                    \"00101001\",\n"
          "                                    \"01110001\",\n"
          "                                    \"11001000\",\n"
          "                                    \"11110110\",\n"
          "                                    \"11111001\",\n"
          "                                    \"01000011\",\n"
          "                                    \"11010111\",\n"
          "                                    \"11010110\",\n"
          "                                    \"00010000\",\n"
          "                                    \"01110011\",\n"
          "                                    \"01110110\",\n"
          "                                    \"01111000\",\n"
          "                                    \"10011001\",\n"
          "                                    \"00001010\",\n"
          "                                    \"00011001\",\n"
          "                                    \"10010001\",\n"
          "                                    \"00010100\",\n"
          "                                    \"00111111\",\n"
          "                                    \"11100110\",\n"
          "                                    \"11110000\",\n"
          "                                    \"10000110\",\n"
          "                                    \"10110001\",\n"
          "                                    \"11100010\",\n"
          "                                    \"11110001\",\n"
          "                                    \"11111010\",\n"
          "                                    \"01110100\",\n"
          "                                    \"11110011\",\n"
          "                                    \"10110100\",\n"
          "                                    \"01101101\",\n"
          "                                    \"00100001\",\n"
          "                                    \"10110010\",\n"
          "                                    \"01101010\",\n"
          "                                    \"11100011\",\n"
          "                                    \"11100111\",\n"
          "                                    \"10110101\",\n"
          "                                    \"11101010\",\n"
          "                                    \"00000011\",\n"
          "                                    \"10001111\",\n"
          "                                    \"11010011\",\n"
          "                                    \"11001001\",\n"
          "                                    \"01000010\",\n"
          "                                    \"11010100\",\n"
          "                                    \"11101000\",\n"
          "                                    \"01110101\",\n"
          "                                    \"01111111\",\n"
          "                                    \"11111111\",\n"
          "                                    \"01111110\",\n"
          "                                    \"11111101\");\n";
  }
  else if (primPoly == 391)
  {
    fd << "\"00000001\",\n"
          "                                    \"11000011\",\n"
          "                                    \"10000010\",\n"
          "                                    \"10100010\",\n"
          "                                    \"01111110\",\n"
          "                                    \"01000001\",\n"
          "                                    \"01011010\",\n"
          "                                    \"01010001\",\n"
          "                                    \"00110110\",\n"
          "                                    \"00111111\",\n"
          "                                    \"10101100\",\n"
          "                                    \"11100011\",\n"
          "                                    \"01101000\",\n"
          "                                    \"00101101\",\n"
          "                                    \"00101010\",\n"
          "                                    \"11101011\",\n"
          "                                    \"10011011\",\n"
          "                                    \"00011011\",\n"
          "                                    \"00110101\",\n"
          "                                    \"11011100\",\n"
          "                                    \"00011110\",\n"
          "                                    \"01010110\",\n"
          "                                    \"10100101\",\n"
          "                                    \"10110010\",\n"
          "                                    \"01110100\",\n"
          "                                    \"00110100\",\n"
          "                                    \"00010010\",\n"
          "                                    \"11010101\",\n"
          "                                    \"01100100\",\n"
          "                                    \"00010101\",\n"
          "                                    \"11011101\",\n"
          "                                    \"10110110\",\n"
          "                                    \"01001011\",\n"
          "                                    \"10001110\",\n"
          "                                    \"11111011\",\n"
          "                                    \"11001110\",\n"
          "                                    \"11101001\",\n"
          "                                    \"11011001\",\n"
          "                                    \"10100001\",\n"
          "                                    \"01101110\",\n"
          "                                    \"11011011\",\n"
          "                                    \"00001111\",\n"
          "                                    \"00101100\",\n"
          "                                    \"00101011\",\n"
          "                                    \"00001110\",\n"
          "                                    \"10010001\",\n"
          "                                    \"11110001\",\n"
          "                                    \"01011001\",\n"
          "                                    \"11010111\",\n"
          "                                    \"00111010\",\n"
          "                                    \"11110100\",\n"
          "                                    \"00011010\",\n"
          "                                    \"00010011\",\n"
          "                                    \"00001001\",\n"
          "                                    \"01010000\",\n"
          "                                    \"10101001\",\n"
          "                                    \"01100011\",\n"
          "                                    \"00110010\",\n"
          "                                    \"11110101\",\n"
          "                                    \"11001001\",\n"
          "                                    \"11001100\",\n"
          "                                    \"10101101\",\n"
          "                                    \"00001010\",\n"
          "                                    \"01011011\",\n"
          "                                    \"00000110\",\n"
          "                                    \"11100110\",\n"
          "                                    \"11110111\",\n"
          "                                    \"01000111\",\n"
          "                                    \"10111111\",\n"
          "                                    \"10111110\",\n"
          "                                    \"01000100\",\n"
          "                                    \"01100111\",\n"
          "                                    \"01111011\",\n"
          "                                    \"10110111\",\n"
          "                                    \"00100001\",\n"
          "                                    \"10101111\",\n"
          "                                    \"01010011\",\n"
          "                                    \"10010011\",\n"
          "                                    \"11111111\",\n"
          "                                    \"00110111\",\n"
          "                                    \"00001000\",\n"
          "                                    \"10101110\",\n"
          "                                    \"01001101\",\n"
          "                                    \"11000100\",\n"
          "                                    \"11010001\",\n"
          "                                    \"00010110\",\n"
          "                                    \"10100100\",\n"
          "                                    \"11010110\",\n"
          "                                    \"00110000\",\n"
          "                                    \"00000111\",\n"
          "                                    \"01000000\",\n"
          "                                    \"10001011\",\n"
          "                                    \"10011101\",\n"
          "                                    \"10111011\",\n"
          "                                    \"10001100\",\n"
          "                                    \"11101111\",\n"
          "                                    \"10000001\",\n"
          "                                    \"10101000\",\n"
          "                                    \"00111001\",\n"
          "                                    \"00011101\",\n"
          "                                    \"11010100\",\n"
          "                                    \"01111010\",\n"
          "                                    \"01001000\",\n"
          "                                    \"00001101\",\n"
          "                                    \"11100010\",\n"
          "                                    \"11001010\",\n"
          "                                    \"10110000\",\n"
          "                                    \"11000111\",\n"
          "                                    \"11011110\",\n"
          "                                    \"00101000\",\n"
          "                                    \"11011010\",\n"
          "                                    \"10010111\",\n"
          "                                    \"11010010\",\n"
          "                                    \"11110010\",\n"
          "                                    \"10000100\",\n"
          "                                    \"00011001\",\n"
          "                                    \"10110011\",\n"
          "                                    \"10111001\",\n"
          "                                    \"10000111\",\n"
          "                                    \"10100111\",\n"
          "                                    \"11100100\",\n"
          "                                    \"01100110\",\n"
          "                                    \"01001001\",\n"
          "                                    \"10010101\",\n"
          "                                    \"10011001\",\n"
          "                                    \"00000101\",\n"
          "                                    \"10100011\",\n"
          "                                    \"11101110\",\n"
          "                                    \"01100001\",\n"
          "                                    \"00000011\",\n"
          "                                    \"11000010\",\n"
          "                                    \"01110011\",\n"
          "                                    \"11110011\",\n"
          "                                    \"10111000\",\n"
          "                                    \"01110111\",\n"
          "                                    \"11100000\",\n"
          "                                    \"11111000\",\n"
          "                                    \"10011100\",\n"
          "                                    \"01011100\",\n"
          "                                    \"01011111\",\n"
          "                                    \"10111010\",\n"
          "                                    \"00100010\",\n"
          "                                    \"11111010\",\n"
          "                                    \"11110000\",\n"
          "                                    \"00101110\",\n"
          "                                    \"11111110\",\n"
          "                                    \"01001110\",\n"
          "                                    \"10011000\",\n"
          "                                    \"01111100\",\n"
          "                                    \"11010011\",\n"
          "                                    \"01110000\",\n"
          "                                    \"10010100\",\n"
          "                                    \"01111101\",\n"
          "                                    \"11101010\",\n"
          "                                    \"00010001\",\n"
          "                                    \"10001010\",\n"
          "                                    \"01011101\",\n"
          "                                    \"10111100\",\n"
          "                                    \"11101100\",\n"
          "                                    \"11011000\",\n"
          "                                    \"00100111\",\n"
          "                                    \"00000100\",\n"
          "                                    \"01111111\",\n"
          "                                    \"01010111\",\n"
          "                                    \"00010111\",\n"
          "                                    \"11100101\",\n"
          "                                    \"01111000\",\n"
          "                                    \"01100010\",\n"
          "                                    \"00111000\",\n"
          "                                    \"10101011\",\n"
          "                                    \"10101010\",\n"
          "                                    \"00001011\",\n"
          "                                    \"00111110\",\n"
          "                                    \"01010010\",\n"
          "                                    \"01001100\",\n"
          "                                    \"01101011\",\n"
          "                                    \"11001011\",\n"
          "                                    \"00011000\",\n"
          "                                    \"01110101\",\n"
          "                                    \"11000000\",\n"
          "                                    \"11111101\",\n"
          "                                    \"00100000\",\n"
          "                                    \"01001010\",\n"
          "                                    \"10000110\",\n"
          "                                    \"01110110\",\n"
          "                                    \"10001101\",\n"
          "                                    \"01011110\",\n"
          "                                    \"10011110\",\n"
          "                                    \"11101101\",\n"
          "                                    \"01000110\",\n"
          "                                    \"01000101\",\n"
          "                                    \"10110100\",\n"
          "                                    \"11111100\",\n"
          "                                    \"10000011\",\n"
          "                                    \"00000010\",\n"
          "                                    \"01010100\",\n"
          "                                    \"11010000\",\n"
          "                                    \"11011111\",\n"
          "                                    \"01101100\",\n"
          "                                    \"11001101\",\n"
          "                                    \"00111100\",\n"
          "                                    \"01101010\",\n"
          "                                    \"10110001\",\n"
          "                                    \"00111101\",\n"
          "                                    \"11001000\",\n"
          "                                    \"00100100\",\n"
          "                                    \"11101000\",\n"
          "                                    \"11000101\",\n"
          "                                    \"01010101\",\n"
          "                                    \"01110001\",\n"
          "                                    \"10010110\",\n"
          "                                    \"01100101\",\n"
          "                                    \"00011100\",\n"
          "                                    \"01011000\",\n"
          "                                    \"00110001\",\n"
          "                                    \"10100000\",\n"
          "                                    \"00100110\",\n"
          "                                    \"01101111\",\n"
          "                                    \"00101001\",\n"
          "                                    \"00010100\",\n"
          "                                    \"00011111\",\n"
          "                                    \"01101101\",\n"
          "                                    \"11000110\",\n"
          "                                    \"10001000\",\n"
          "                                    \"11111001\",\n"
          "                                    \"01101001\",\n"
          "                                    \"00001100\",\n"
          "                                    \"01111001\",\n"
          "                                    \"10100110\",\n"
          "                                    \"01000010\",\n"
          "                                    \"11110110\",\n"
          "                                    \"11001111\",\n"
          "                                    \"00100101\",\n"
          "                                    \"10011010\",\n"
          "                                    \"00010000\",\n"
          "                                    \"10011111\",\n"
          "                                    \"10111101\",\n"
          "                                    \"10000000\",\n"
          "                                    \"01100000\",\n"
          "                                    \"10010000\",\n"
          "                                    \"00101111\",\n"
          "                                    \"01110010\",\n"
          "                                    \"10000101\",\n"
          "                                    \"00110011\",\n"
          "                                    \"00111011\",\n"
          "                                    \"11100111\",\n"
          "                                    \"01000011\",\n"
          "                                    \"10001001\",\n"
          "                                    \"11100001\",\n"
          "                                    \"10001111\",\n"
          "                                    \"00100011\",\n"
          "                                    \"11000001\",\n"
          "                                    \"10110101\",\n"
          "                                    \"10010010\",\n"
          "                                    \"01001111\",\n";
  }

  fd << "begin\n"
        "  output <= inversion(to_integer(unsigned(input)));\n"
    "end architecture;\n";

  fd.close();
}