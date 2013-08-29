library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

-- Finite field elements multiplier
-- Based on the theory described on section 2.3.1 of Yuan's "A practical Guide
-- to Error-Control Coding Using MATLAB"

-- Both inputs and the output have at most degree (m - 1), as the
-- multiplication must result in an element from the field.

entity field_element_multiplier is
  port (
    u : in  field_element;
    v : in  field_element;
    w : out field_element);
end entity;

architecture field_element_multiplier of field_element_multiplier is
  signal d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14 : std_logic;
begin
  d0  <= (u(0) and v(0));
  d1  <= (u(0) and v(1)) xor (u(1) and v(0));
  d2  <= (u(0) and v(2)) xor (u(1) and v(1)) xor (u(2) and v(0));
  d3  <= (u(0) and v(3)) xor (u(1) and v(2)) xor (u(2) and v(1)) xor (u(3) and v(0));
  d4  <= (u(0) and v(4)) xor (u(1) and v(3)) xor (u(2) and v(2)) xor (u(3) and v(1)) xor (u(4) and v(0));
  d5  <= (u(0) and v(5)) xor (u(1) and v(4)) xor (u(2) and v(3)) xor (u(3) and v(2)) xor (u(4) and v(1)) xor (u(5) and v(0));
  d6  <= (u(0) and v(6)) xor (u(1) and v(5)) xor (u(2) and v(4)) xor (u(3) and v(3)) xor (u(4) and v(2)) xor (u(5) and v(1)) xor (u(6) and v(0));
  d7  <= (u(0) and v(7)) xor (u(1) and v(6)) xor (u(2) and v(5)) xor (u(3) and v(4)) xor (u(4) and v(3)) xor (u(5) and v(2)) xor (u(6) and v(1)) xor (u(7) and v(0));
  d8  <= (u(7) and v(1)) xor (u(6) and v(2)) xor (u(5) and v(3)) xor (u(4) and v(4)) xor (u(3) and v(5)) xor (u(2) and v(6)) xor (u(1) and v(7));
  d9  <= (u(7) and v(2)) xor (u(6) and v(3)) xor (u(5) and v(4)) xor (u(4) and v(5)) xor (u(3) and v(6)) xor (u(2) and v(7));
  d10 <= (u(7) and v(3)) xor (u(6) and v(4)) xor (u(5) and v(5)) xor (u(4) and v(6)) xor (u(3) and v(7));
  d11 <= (u(7) and v(4)) xor (u(6) and v(5)) xor (u(5) and v(6)) xor (u(4) and v(7));
  d12 <= (u(7) and v(5)) xor (u(6) and v(6)) xor (u(5) and v(7));
  d13 <= (u(7) and v(6)) xor (u(6) and v(7));
  d14 <= (u(7) and v(7));

  w(0) <= d0 xor d8 xor d12 xor d13 xor d14;
  w(1) <= d1 xor d9 xor d13 xor d14;
  w(2) <= d2 xor d8 xor d10 xor d12 xor d13;
  w(3) <= d3 xor d8 xor d9 xor d11 xor d12;
  w(4) <= d4 xor d8 xor d9 xor d10 xor d14;
  w(5) <= d5 xor d9 xor d10 xor d11;
  w(6) <= d6 xor d10 xor d11 xor d12;
  w(7) <= d7 xor d11 xor d12 xor d13;
end architecture;
