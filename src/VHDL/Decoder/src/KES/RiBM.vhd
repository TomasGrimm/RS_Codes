library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- Implementation of the invertionless Berlekamp-Massey algorithm

--entity BerlekampMassey is
--  port (
--    clock    : in std_logic;
--    reset    : in std_logic;
--    enable   : in std_logic;
--    syndrome : in T2less1_array;

--    done            : out std_logic;
--    error_locator   : out T_array;
--    error_evaluator : out Tless1_array);
--end entity;

--architecture BerlekampMassey of BerlekampMassey is
architecture RiBM of KES is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal enable_operation : std_logic;

  signal counter : unsigned(SYMBOL_LENGTH/2 downto 0);
  signal k       : signed(SYMBOL_LENGTH/2 downto 0);

  signal gamma : field_element;

  signal gamma_sigma_out : T3_array;
  signal sigma           : T3_array;
  signal sigma_theta_out : T3_array;
  signal theta           : T3_array;
  
begin
  gamma_mult_sigma : for I in 1 to T3 generate
    gamma_sigma_term : field_element_multiplier port map (gamma, sigma(I), gamma_sigma_out(I));
  end generate gamma_mult_sigma;
  

  sigma_mult_theta : for J in 0 to T3 generate
    sigma_theta_term : field_element_multiplier port map (sigma(0), theta(J), sigma_theta_out(J));
  end generate sigma_mult_theta;

  -----------------------------------------------------------------------------
  -- Enable BM operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter = T2 - 1 then
        enable_operation <= '0';
      elsif enable = '1' then
        enable_operation <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Count iterations
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter = T2 - 1 then
        counter <= (others => '0');
      elsif enable_operation = '1' and counter < T2 then
        counter <= counter + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control sigma update
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        sigma <= (others => (others => '0'));
      elsif enable = '1' then
        sigma              <= (others => (others => '0'));
        sigma(T3)          <= (0      => '1', others => '0');
        sigma(0 to T2 - 1) <= syndrome(0) &
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
                              syndrome(15);
      elsif enable_operation = '1' then
        for i in 0 to T3 - 1 loop
          sigma(i) <= gamma_sigma_out(i + 1) xor sigma_theta_out(i);
        end loop;
        sigma(T3) <= sigma_theta_out(T3);
      else
        sigma <= sigma;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control theta update
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        theta <= (others => (others => '0'));
      elsif enable = '1' then
        theta              <= (others => (others => '0'));
        theta(T3)          <= (0      => '1', others => '0');
        theta(0 to T2 - 1) <= syndrome(0) &
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
                              syndrome(15);
      elsif enable_operation = '1' then
        if sigma(0) /= all_zeros and k >= 0 then
          theta <= sigma(1 to T3) & all_zeros;
        else
          theta <= theta;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control gamma
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        gamma <= alpha_zero;
      elsif enable_operation = '1' then
        if sigma(0) /= all_zeros and k >= 0 then
          gamma <= sigma(0);
        else
          gamma <= gamma;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control k
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        k <= (others => '0');
      elsif enable_operation = '1' then
        if sigma(0) /= all_zeros and k >= 0 then
          k <= k - 1;
        else
          k <= k + 1;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set done signal
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if counter = T2 - 1 then
        done <= '1';
      else
        done <= '0';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set output signals
  -----------------------------------------------------------------------------
  error_locator <= sigma(8) &
                   sigma(9) &
                   sigma(10) &
                   sigma(11) &
                   sigma(12) &
                   sigma(13) &
                   sigma(14) &
                   sigma(15) &
                   sigma(16);

  error_evaluator <= sigma(0) &
                     sigma(1) &
                     sigma(2) &
                     sigma(3) &
                     sigma(4) &
                     sigma(5) &
                     sigma(6) &
                     sigma(7);
  
end architecture;
