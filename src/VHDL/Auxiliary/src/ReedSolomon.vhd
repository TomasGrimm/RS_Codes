library IEEE;
use IEEE.std_logic_1164.all;

package ReedSolomon is
  constant N_LENGTH      : natural := 255;  -- maximum codeword size
  constant K_LENGTH      : natural := 239;  -- message symbols
  constant SYMBOL_LENGTH : natural := 8;    -- number of bits per symbol
  constant T             : natural := 8;    -- code's correction capability
  constant T2            : natural := 16;   -- 2*t
  constant T3            : natural := 24;   -- 3*t

  subtype field_element is std_logic_vector(SYMBOL_LENGTH - 1 downto 0);  -- message and codeword symbol

  constant alpha_zero   : field_element;  -- representation of alpha^0
  constant last_element : field_element;  -- representation of alpha^254
  constant all_zeros    : field_element;  -- representation of the zero symbol

  type N_array is array (0 to N_LENGTH - 1) of field_element;
  type T_array is array (0 to T) of field_element;
  type T2_array is array (0 to T2) of field_element;
  type T3_array is array (0 to T3) of field_element;
  type Tless1_array is array (0 to T - 1) of field_element;
  type T2less1_array is array (0 to T2 - 1) of field_element;
  type T3less1_array is array (0 to T3 - 1) of field_element;
  
  constant gen_poly : T2less1_array;    -- generator polynomial
  constant roots    : T2less1_array;    -- generator polynomial roots
end package ReedSolomon;

package body ReedSolomon is
  constant alpha_zero   : field_element := "00000001";  -- a^0
  constant last_element : field_element := "10001110";  -- a^254
  constant all_zeros    : field_element := "00000000";
  
  constant roots : T2less1_array := ("00000001",   -- a^0
                                     "00000010",   -- a^1
                                     "00000100",   -- a^2
                                     "00001000",   -- a^3
                                     "00010000",   -- a^4
                                     "00100000",   -- a^5
                                     "01000000",   -- a^6
                                     "10000000",   -- a^7
                                     "00011101",   -- a^8
                                     "00111010",   -- a^9
                                     "01110100",   -- a^10
                                     "11101000",   -- a^11
                                     "11001101",   -- a^12
                                     "10000111",   -- a^13
                                     "00010011",   -- a^14
                                     "00100110");  -- a^15

  constant gen_poly : T2less1_array := ("00111011",  -- x^0 (a^5 + a^4 + a^3 + a + 1)
                                        "00100100",  -- x^1 (a^5 + a^2)
                                        "00110010",  -- x^2 (a^5 + a^4 + a)
                                        "01100010",  -- x^3 (a^6 + a^5 + a)
                                        "11100101",  -- x^4 (a^7 + a^6 + a^5 + a^2 + 1)
                                        "00101001",  -- x^5 (a^5 + a^3 + 1)
                                        "01000001",  -- x^6 (a^6 + 1)
                                        "10100011",  -- x^7 (a^7 + a^5 + a + 1)
                                        "00001000",  -- x^8 (a^3)
                                        "00011110",  -- x^9 (a^4 + a^3 + a^2 + a)
                                        "11010001",  -- x^10(a^7 + a^6 + a^4 + 1)
                                        "01000100",  -- x^11(a^6 + a^2)
                                        "10111101",  -- x^12(a^7 + a^5 + a^4 + a^3 + a^2 + 1)
                                        "01101000",  -- x^13(a^6 + a^5 + a^3)
                                        "00001101",  -- x^14(a^3 + a^2 + 1)
                                        "00111011");  -- x^15(a^5 + a^4 + a^3 + a + 1)
end ReedSolomon;
