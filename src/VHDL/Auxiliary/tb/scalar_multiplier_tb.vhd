library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity scalar_multiplier_tb is
end scalar_multiplier_tb;

architecture scalar_multiplier_tb of scalar_multiplier_tb is
  component scalar_multiplier
    port (
      element    : in  field_element;
      polynomial : in  key_equation;
      multiplied : out key_equation);
  end component;

  signal elmt : field_element;
  signal poly, mult : key_equation;
  
begin
  sm : scalar_multiplier
    port map (
      element    => elmt,
      polynomial => poly,
      multiplied => mult);

  process
  begin
    elmt <= (others => '0');
    poly <= (others => (others => '0'));
    wait for 20 ns;

    elmt <= "00000001";
    poly(0) <= "00000001";
    poly(1) <= "00000010";
    poly(2) <= "00000100";
    poly(3) <= "00001000";
    poly(4) <= "00010000";
    poly(5) <= "00100000";
    poly(6) <= "01000000";
    poly(7) <= "10000000";
    poly(8) <= "00000011";
    wait;
  end process;
end scalar_multiplier_tb;
