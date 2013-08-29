library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity polynomial_evaluator_tb is
end entity;

architecture polynomial_evaluator_tb of polynomial_evaluator_tb is
  component polynomial_evaluator is
    port (
      x          : in  field_element;
      polynomial : in  key_equation;
      y          : out field_element);
  end component;

  signal element : field_element;
  signal poly    : key_equation;
  signal output  : field_element;
  
begin
  evaluator : polynomial_evaluator
    port map (
      x          => element,
      polynomial => poly,
      y          => output);

  process
  begin
    element <= (others => '0');
    poly    <= (others => (others => '0'));
    wait for 20 ns;

    element <= "00000001";
    poly(8) <= "00000001";
    poly(7) <= "00000001";
    poly(6) <= "00000001";
    poly(5) <= "00000001";
    poly(4) <= "00000001";
    poly(3) <= "00000001";
    poly(2) <= "00000001";
    poly(1) <= "00000001";
    poly(0) <= "00000001";
    wait for 20 ns;

    element <= "00001000";
    poly(8) <= "10010100";
    poly(7) <= "10010010";
    poly(6) <= "01010101";
    poly(5) <= "10010101";
    poly(4) <= "11110000";
    poly(3) <= "00110011";
    poly(2) <= "11001100";
    poly(1) <= "00011000";
    poly(0) <= "11111000";
    wait for 20 ns;
  end process;

end architecture;
