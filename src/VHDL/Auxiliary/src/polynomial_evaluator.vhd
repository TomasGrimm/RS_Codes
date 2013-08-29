library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity polynomial_evaluator is
  port (
    x          : in  field_element;
    polynomial : in  key_equation;
    y          : out field_element);
end entity;

architecture polynomial_evaluator of polynomial_evaluator is
  component field_element_multiplier
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal degree_8, degree_7, degree_6, degree_5, degree_4, degree_3, degree_2, degree_1 : field_element;
  signal term_x7, term_x6, term_x5, term_x4, term_x3, term_x2, term_x1 : field_element;
  
begin
  -- key equation polynomial
  -- lambda(x) = (x^8)*(a^i) + (x^7)*(a^i) + (x^6)*(a^i) + (x^5)*(a^i) + (x^4)*(a^i) + (x^3)*(a^i) + (x^2)*(a^i) + (x^1)*(a^i) + (a^i)

  -- key equation in Horner's rule notation
  -- lambda(x) = (((((((x^8 * a^i + x^7) * a^i + x^6) * a^i + x^5) * a^i + x^4) * a^i + x^3) * a^i + x^2) * a^i + x^1) * a^i + x^0

  x8 : field_element_multiplier
    port map (
      u => polynomial(8),
      v => x,
      w => degree_8);

  term_x7 <= polynomial(7) xor degree_8;
  x7 : field_element_multiplier
    port map (
      u => term_x7,
      v => x,
      w => degree_7);

  term_x6 <= polynomial(6) xor degree_7;
  x6 : field_element_multiplier
    port map (
      u => term_x6,
      v => x,
      w => degree_6);

  term_x5 <= polynomial(5) xor degree_6;
  x5 : field_element_multiplier
    port map (
      u => term_x5,
      v => x,
      w => degree_5);

  term_x4 <= polynomial(4) xor degree_5;
  x4 : field_element_multiplier
    port map (
      u => term_x4,
      v => x,
      w => degree_4);

  term_x3 <= polynomial(3) xor degree_4;
  x3 : field_element_multiplier
    port map (
      u => term_x3,
      v => x,
      w => degree_3);

  term_x2 <= polynomial(2) xor degree_3;
  x2 : field_element_multiplier
    port map (
      u => term_x2,
      v => x,
      w => degree_2);

  term_x1 <= polynomial(1) xor degree_2;
  x1 : field_element_multiplier
    port map (
      u => term_x1,
      v => x,
      w => degree_1);

  y <= polynomial(0) xor degree_1;
  
end architecture;
