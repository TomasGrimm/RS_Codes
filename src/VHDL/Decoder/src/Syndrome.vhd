library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- Syndrome calculation for a Reed-Solomon code

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
    start           : in std_logic;
    received_vector : in field_element;

    done     : out std_logic;
    syndrome : out T2less1_array);
end entity;

architecture Syndrome of Syndrome is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal enable_operation : std_logic;

  signal registers       : T2less1_array;
  signal multiplications : T2less1_array;

  signal counter : unsigned(T - 1 downto 0);
  
begin
  multipliers : for I in 0 to T2 - 1 generate
    synd : field_element_multiplier port map (registers(I), roots(I), multiplications(I));
  end generate multipliers;

  -----------------------------------------------------------------------------
  -- Enable operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter = N_LENGTH then
        enable_operation <= '0';
      elsif start = '1' then
        enable_operation <= '1';
      end if;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Counter to control the syndrome calculation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable_operation = '0' then
        counter <= (others => '0');
      elsif enable_operation = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Syndromes sum with intermediate results
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or start = '1' then
        registers <= (others => (others => '0'));
      elsif enable_operation = '1' then
        for i in 0 to T2 - 1 loop
          registers(i) <= received_vector xor multiplications(i);
        end loop;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set done signal
  -----------------------------------------------------------------------------
  process(counter)
  begin
    if counter /= N_LENGTH then
      done <= '0';
    else
      done <= '1';
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Output syndromes
  -----------------------------------------------------------------------------
  syndrome <= registers;
end architecture;
