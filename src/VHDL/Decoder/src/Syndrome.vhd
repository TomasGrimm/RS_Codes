library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- Syndrome calculation for a Reed-Solomon (255, 239) code

-- The syndrome of the received polynomial is calculated by a Horner's rule-like
-- equation, where the calculations begin with the highest degree element,
-- which is the first to be received.
-- After n iterations the process ends, and, if the resulting polynomial is
-- zero, then no errors have been detected and no further processing is needed,
-- otherwise, the next step is activated.

entity Syndrome is
  port (
    clock           : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;
    received_vector : in field_element;

    done     : out std_logic;
    no_error : out std_logic;
    syndrome : out syndrome_vector);
end entity;

architecture Syndrome of Syndrome is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal counter : unsigned(8 downto 0);

  signal syndromes       : syndrome_vector;
  signal multiplications : syndrome_vector;
  
begin
  multipliers : for I in 0 to T2 - 1 generate
    synd : field_element_multiplier port map (syndromes(I), alphas(I), multiplications(I));
  end generate multipliers;

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '0' then
        done      <= '0';
        no_error  <= '0';
        counter   <= (others => '0');
        syndrome  <= (others => (others => '0'));
        syndromes <= (others => (others => '0'));
        
      elsif enable = '1' then
        counter <= counter + 1;

        if counter <= N_LENGTH - 1 then
          syndromes(0)  <= received_vector xor multiplications(0);
          syndromes(1)  <= received_vector xor multiplications(1);
          syndromes(2)  <= received_vector xor multiplications(2);
          syndromes(3)  <= received_vector xor multiplications(3);
          syndromes(4)  <= received_vector xor multiplications(4);
          syndromes(5)  <= received_vector xor multiplications(5);
          syndromes(6)  <= received_vector xor multiplications(6);
          syndromes(7)  <= received_vector xor multiplications(7);
          syndromes(8)  <= received_vector xor multiplications(8);
          syndromes(9)  <= received_vector xor multiplications(9);
          syndromes(10) <= received_vector xor multiplications(10);
          syndromes(11) <= received_vector xor multiplications(11);
          syndromes(12) <= received_vector xor multiplications(12);
          syndromes(13) <= received_vector xor multiplications(13);
          syndromes(14) <= received_vector xor multiplications(14);
          syndromes(15) <= received_vector xor multiplications(15);
        end if;
      end if;

      if counter = N_LENGTH then
        counter  <= counter + 1;
        syndrome <= syndromes;
        done <= '1';

        if (syndromes(0) = "00000000") and
           (syndromes(1) = "00000000") and
           (syndromes(2) = "00000000") and
           (syndromes(3) = "00000000") and
           (syndromes(4) = "00000000") and
           (syndromes(5) = "00000000") and
           (syndromes(6) = "00000000") and
           (syndromes(7) = "00000000") and
           (syndromes(8) = "00000000") and
           (syndromes(9) = "00000000") and
           (syndromes(10) = "00000000") and
           (syndromes(11) = "00000000") and
           (syndromes(12) = "00000000") and
           (syndromes(13) = "00000000") and
           (syndromes(14) = "00000000") and
           (syndromes(15) = "00000000") then
          no_error <= '1';
        else
          no_error <= '0';
        end if;
        
      elsif counter = N_LENGTH + 1 then
        done <= '0';
      end if;
    end if;
  end process;
end architecture;
