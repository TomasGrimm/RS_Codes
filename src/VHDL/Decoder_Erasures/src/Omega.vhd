library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

entity Omega is
  port (
    clock         : in std_logic;
    reset         : in std_logic;
    enable        : in std_logic;
    syndrome      : in T2less1_array;
    error_locator : in T2_array;

    done            : out std_logic;
    error_evaluator : out T2less1_array);
end entity;

architecture Omega of Omega is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal enable_evaluator : std_logic;

  signal evaluator_counter : unsigned(T - 1 downto 0);

  signal discrepancy_syndromes : T2_array;
  signal multiplicator_output  : T2_array;
  signal omega_temp            : T2_array;
  signal sigma_helper          : T2_array;
  
begin
  multiplicators : for I in 0 to T2 generate
    multiply : field_element_multiplier port map(discrepancy_syndromes(I), sigma_helper(0), multiplicator_output(I));
  end generate multiplicators;

  -----------------------------------------------------------------------------
  -- Syndrome register used for the discrepancy calculation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        discrepancy_syndromes <= (others => (others => '0'));
      elsif enable = '1' then
        discrepancy_syndromes <= syndrome(0) &
                                 syndrome(1) &
                                 syndrome(2) &
                                 syndrome(3) &
                                 syndrome(4) &
                                 syndrome(5) &
                                 syndrome(6) &
                                 syndrome(7) &
                                 syndrome(8) &
                                 syndrome(9) &
                                 syndrome(10) &
                                 syndrome(11) &
                                 syndrome(12) &
                                 syndrome(13) &
                                 syndrome(14) &
                                 syndrome(15) &
                                 all_zeros;
      elsif enable_evaluator = '1' then
        discrepancy_syndromes <= all_zeros & discrepancy_syndromes(0 to T2 - 1);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Enable error evaluator polynomial calculation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or evaluator_counter = T2 - 1 then
        enable_evaluator <= '0';
      elsif enable = '1' then
        enable_evaluator <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Error evaluator polynomial counter control
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or evaluator_counter = T2 - 1 then
        evaluator_counter <= (others => '0');
      elsif enable_evaluator = '1' and evaluator_counter < T2 then
        evaluator_counter <= evaluator_counter + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Determine error evaluator polynomial
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        omega_temp <= (others => (others => '0'));
      elsif enable_evaluator = '1' then
        for i in 0 to T2 - 1 loop
          omega_temp(i) <= omega_temp(i) xor multiplicator_output(i);
        end loop;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Sigma helper for error evaluator polynomial calculation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        sigma_helper <= (others => (others => '0'));
      elsif enable = '1' then
        sigma_helper <= error_locator;
      elsif enable_evaluator = '1' then
        sigma_helper <= sigma_helper(1 to T2) & all_zeros;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Signal done
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if evaluator_counter /= T2 - 1 then
        done <= '0';
      else
        done <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Output error evaluator polynomial
  -----------------------------------------------------------------------------
  error_evaluator <= T2less1_array(omega_temp(0 to T2 - 1));
end Omega;
