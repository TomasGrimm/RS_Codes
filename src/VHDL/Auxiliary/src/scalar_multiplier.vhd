library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity scalar_multiplier is
  port (
    element    : in field_element;
    polynomial : in key_equation;

    multiplied : out key_equation);
end entity;

architecture scalar_multiplier of scalar_multiplier is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;
  
begin
  generate_multiplier : for I in 0 to T generate
    multiplier : field_element_multiplier
      port map(
        element,
        polynomial(I),
        multiplied(I));
  end generate generate_multiplier;
end architecture;
