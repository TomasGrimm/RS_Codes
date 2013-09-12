library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- Implementation of the invertionless Berlekamp-Massey algorithm

entity BerlekampMassey is
  port (
    clock          : in std_logic;
    reset          : in std_logic;
    enable         : in std_logic;
    syndrome       : in T2less1_array;
    erasures       : in T2less1_array;
    erasures_count : in unsigned(T downto 0);

    done            : out std_logic;
    error_locator   : out T2less1_array;
    error_evaluator : out T2less1_array);
end entity;

architecture BerlekampMassey of BerlekampMassey is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal delta             : std_logic;
  signal enable_locator    : std_logic;
  signal enable_evaluator  : std_logic;
  signal syndrome_updated  : std_logic;
  signal updating_syndrome : std_logic;

  signal discrepancy : field_element;
  signal theta       : field_element;

  signal B                     : T2less1_array;
  signal discrepancy_syndromes : T2less1_array;
  signal multiplicator_input_1 : T2less1_array;
  signal multiplicator_input_2 : T2less1_array;
  signal multiplicator_output  : T2less1_array;
  signal omega                 : T2less1_array;
  signal sigma                 : T2less1_array;
  signal temp_sigma            : T2less1_array;
  signal sigma_helper          : T2less1_array;

  signal phase : unsigned(1 downto 0);

  signal evaluator_counter : unsigned(T downto 0);
  signal L                 : unsigned(T downto 0);
  signal locator_counter   : unsigned(T downto 0);
  signal update_count      : unsigned(T downto 0);
  
begin
  multiplicators : for I in 0 to T2 - 1 generate
    multiply : field_element_multiplier port map(multiplicator_input_1(I), multiplicator_input_2(I), multiplicator_output(I));
  end generate multiplicators;

  multiplicator_input_1 <= discrepancy_syndromes when phase = "00" and enable_locator = '1' else
                           (others => theta)       when phase = "01" and enable_locator = '1' else
                           (others => discrepancy) when phase = "10" and enable_locator = '1' else
                           discrepancy_syndromes   when enable_evaluator = '1';

  multiplicator_input_2 <= sigma when phase = "00" and enable_locator = '1' else
                           sigma                       when phase = "01" and enable_locator = '1' else
                           B                           when phase = "10" and enable_locator = '1' else
                           (others => sigma_helper(0)) when enable_evaluator = '1';

  delta <= '1' when (discrepancy /= all_zeros) and ((L + L) <= locator_counter) and enable_locator = '1' else
           '0' when phase = "00";

  -----------------------------------------------------------------------------
  -- Enable error locator polynomial calculation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or (locator_counter = T2 - 1 - erasures_count and phase = "11") then
        enable_locator <= '0';
      elsif syndrome_updated = '1' and locator_counter < T2 - 1 - to_integer(erasures_count) then
        enable_locator <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Enable syndrome update for erasure initialization
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or update_count = erasures_count - 1 then
        updating_syndrome <= '0';
      elsif enable = '1' and erasures_count < T2 then
        updating_syndrome <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Count the number of shifts on the syndrome register
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        update_count <= (others => '0');
      elsif updating_syndrome = '1' then
        update_count <= update_count + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Signal when syndrome register is updated
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable_locator = '1' then
        syndrome_updated <= '0';
      elsif updating_syndrome = '1' and update_count = erasures_count - 1 then
        syndrome_updated <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Phase control
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        phase <= "00";
      elsif enable_locator = '1' then
        if locator_counter <= T2 - 1 - erasures_count then
          phase <= phase + 1;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Error locator polynomial counter control
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' or enable_evaluator = '1' then
        locator_counter <= (others => '0');
      elsif phase = "11" and locator_counter < T2 - erasures_count then
        locator_counter <= locator_counter + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Syndrome register used for the discrepancy calculation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        discrepancy_syndromes <= (others => (others => '0'));
      elsif enable = '1' then
        discrepancy_syndromes(0) <= syndrome(0);
        for i in 1 to T2 - 1 loop
          discrepancy_syndromes(i) <= syndrome(T2 - i);
        end loop;
      elsif updating_syndrome = '1' or (enable_locator = '1' and phase = "11") then
        discrepancy_syndromes <= discrepancy_syndromes(T2 - 1) & discrepancy_syndromes(0 to T2 - 2);
      elsif (locator_counter = T2 - erasures_count and enable_evaluator = '0') or (enable = '1' and erasures_count = T2) then
        discrepancy_syndromes <= syndrome;
      elsif enable_evaluator = '1' then
        discrepancy_syndromes <= all_zeros & discrepancy_syndromes(0 to T2 - 2);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Calculate the discrepancy
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or phase = "11" then
        discrepancy <= (others => '0');
      elsif phase = "00" and enable_locator = '1' then
        discrepancy <= discrepancy
                       xor multiplicator_output(0)
                       xor multiplicator_output(1)
                       xor multiplicator_output(2)
                       xor multiplicator_output(3)
                       xor multiplicator_output(4)
                       xor multiplicator_output(5)
                       xor multiplicator_output(6)
                       xor multiplicator_output(7)
                       xor multiplicator_output(8)
                       xor multiplicator_output(9)
                       xor multiplicator_output(10)
                       xor multiplicator_output(11)
                       xor multiplicator_output(12)
                       xor multiplicator_output(13)
                       xor multiplicator_output(14)
                       xor multiplicator_output(15);
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Determine error locator polynomial
  ------------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        sigma <= (others => (others => '0'));
      elsif enable = '1' then
        sigma <= erasures;
      elsif phase = "11" and enable_locator = '1' then
        sigma(0) <= temp_sigma(0);
        for i in 1 to T2 - 1 loop
          sigma(i) <= temp_sigma(i) xor multiplicator_output(i - 1);
        end loop;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Error locator polynomial helper
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        temp_sigma <= (others => (others => '0'));
      elsif enable = '1' then
        temp_sigma <= erasures;
      elsif enable_locator = '1' then
        if phase = "01" then
          temp_sigma <= multiplicator_output;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control polynomial B
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        B <= (others => (others => '0'));
      elsif enable = '1' then
        B <= erasures;
      elsif phase = "11" and locator_counter < T2 - erasures_count then
        if delta = '0' then
          B <= all_zeros & B(0 to T2 - 2);
        else
          B <= sigma;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Keep track of the length of the error locator polynomial
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        L <= (others => '0');
      elsif phase = "10" then
        if delta = '0' then
          L <= L;
        elsif delta = '1' then
          L <= locator_counter - L + 1;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control theta
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        theta <= (0 => '1', others => '0');
      elsif phase = "10" then
        if delta = '0' then
          theta <= theta;
        else
          theta <= discrepancy;
        end if;
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
      elsif (locator_counter = T2 - erasures_count and enable_locator = '0') or (enable = '1' and erasures_count = T2) then
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
      elsif enable_evaluator = '1' and evaluator_counter < T2 - 1 then
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
        omega <= (others => (others => '0'));
      elsif enable_evaluator = '1' then
        for i in 0 to T2 - 1 loop
          omega(i) <= omega(i) xor multiplicator_output(i);
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
      elsif locator_counter = T2 - erasures_count and enable_evaluator = '0' then
        sigma_helper <= sigma;
      elsif enable = '1' and erasures_count = T2 then
        sigma_helper <= erasures;
      elsif enable_evaluator = '1' then
        sigma_helper <= sigma_helper(1 to T2 - 1) & all_zeros;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Signal done
  -----------------------------------------------------------------------------
  process(evaluator_counter)
  begin
    if evaluator_counter /= T2 - 1 then
      done <= '0';
    else
      done <= '1';
    end if;
  end process;

  error_locator <= erasures when erasures_count = T2 else
                   sigma;
  error_evaluator <= omega;
end architecture;
