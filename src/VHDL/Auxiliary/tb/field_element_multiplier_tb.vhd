library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity field_element_multiplier_tb is
end entity;

architecture field_element_multiplier_tb of field_element_multiplier_tb is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal in_1, in_2, output : field_element;
  
begin
  fe_mult : field_element_multiplier
    port map (
      u => in_1,
      v => in_2,
      w => output);
  
  process
  begin
    in_1 <= (others => '0');
    in_2 <= (others => '0');
    wait for 10 ns;

    in_1 <= "00000010";
    in_2 <= "00000010";
    wait for 10 ns;

    in_1 <= "10000000";
    in_2 <= "10000000";
    wait for 10 ns;

    in_1 <= (others => '1');
    in_2 <= (others => '1');
    wait;
  end process;
end architecture;
