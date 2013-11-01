library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- Alterar a arquitetura para acomodar a correcao utilizando o E-DCME
architecture CF_EDCME of Chien_Forney is
  component field_element_multiplier
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  component inversion_table
    port (
      input  : in  field_element;
      output : out field_element);
  end component;

  signal enable_operation : std_logic;

  signal omega_sum      : field_element;
  signal sigma_sum      : field_element;
  signal sigma_derived  : field_element;
  signal sigma_inverted : field_element;

  signal error_locator_out     : T_array;
  signal partial_error_locator : T_array;
  signal sigma_input           : T_array;

  signal error_evaluator_out     : Tless1_array;
  signal partial_error_evaluator : Tless1_array;
  signal omega_input             : Tless1_array;

  signal counter : unsigned(SYMBOL_LENGTH - 1 downto 0);

  constant alpha_zero_array : T_array := (others => alpha_zero);

begin
  processing <= enable_operation;

  -- When the Chien search starts, the first element to multiply the error
  -- locator polynomial is alpha^0, and as all the powers of alpha^0 are equal to
  -- alpha^0, the first iteration uses the variable sigma_alpha_zero.
  -- For the other n - 1 iterations, the variable sigma_alphas is used, so that
  -- every new iteration has the previous result multiplied by alpha.
  sigma_input <= alpha_zero_array when enable = '1' else
                 T_array(roots(0 to T));

  -- When the Forney algorithm starts, the first element to multiply the error
  -- evaluator polynomial is alpha^0, and as all the powers of alpha^0 are equal to
  -- alpha^0, the first iteration uses the variable omega_alpha_zero.
  -- For the other n - 1 iterations, the variable omega_alphas is used, so that
  -- every new iteration has the previous result multiplied by alpha.
  omega_input <= Tless1_array(alpha_zero_array(0 to T - 1)) when enable = '1' else
                 Tless1_array(roots(0 to T - 1));

  -- The error locator polynomial has to be evaluated for each value of alpha
  error_locator_terms : for I in 0 to T generate
    term : field_element_multiplier port map (sigma_input(I), partial_error_locator(I), error_locator_out(I));
  end generate;

  -- The error evaluator polynomial has to be evaluated for each value of alpha
  error_evaluator_terms : for J in 0 to (T - 1) generate
    term : field_element_multiplier port map (omega_input(J), partial_error_evaluator(J), error_evaluator_out(J));
  end generate;

  -- After being evaluated, all the terms from the error locator polynomial must be summed.
  sigma_sum <= error_locator_out(0) xor
               error_locator_out(1) xor
               error_locator_out(2) xor
               error_locator_out(3) xor
               error_locator_out(4) xor
               error_locator_out(5) xor
               error_locator_out(6) xor
               error_locator_out(7) xor
               error_locator_out(8) when enable_operation = '1' else
               (others => '0');

  -- If the error locator polynomial is evaluated as zero, than a root has been
  -- found
  is_root <= '1' when sigma_sum = all_zeros and enable_operation = '1' else
             '0';

  -- At the same time that the error locator polynomial is evaluated, its
  -- derivative is also evaluated to be used in the calculation of the error magnitude.
  sigma_derived <= error_locator_out(1) xor
                   error_locator_out(3) xor
                   error_locator_out(5) xor
                   error_locator_out(7) when enable_operation = '1' else
                   (others => '0');

  -- After being evaluated, all the terms from the error locator polynomial must be summed.
  omega_sum <= error_evaluator_out(0) xor
               error_evaluator_out(1) xor
               error_evaluator_out(2) xor
               error_evaluator_out(3) xor
               error_evaluator_out(4) xor
               error_evaluator_out(5) xor
               error_evaluator_out(6) xor
               error_evaluator_out(7) when enable_operation = '1' else
               (others => '0');

  -- To avoid the division operation, the result from the derivative is inverted.
  inverter : inversion_table port map (sigma_derived, sigma_inverted);

  -- Finally, the error magnitude is calculated as the multiplication of the
  -- scaled version of the result from the error evaluator polynomial by the
  -- derivative of the error locator polynomial.
  magnitude_calculation : field_element_multiplier port map (omega_sum, sigma_inverted, error_magnitude);

  -----------------------------------------------------------------------------
  -- Enable operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter = 0 then
        enable_operation <= '0';
      elsif enable = '1' then
        enable_operation <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control of the index
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter = 0 then
        counter <= to_unsigned(N_LENGTH - 1, SYMBOL_LENGTH);
      elsif enable_operation = '1' then
        if counter > 0 then
          counter <= counter - 1;
        else
          counter <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control the intermediary locator polynomial
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        partial_error_locator <= (others => (others => '0'));
      elsif enable = '1' then
        partial_error_locator <= error_locator;
      elsif enable_operation = '1' then
        partial_error_locator <= error_locator_out;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control the intermediary evaluator polynomial
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        partial_error_evaluator <= (others => (others => '0'));
      elsif enable = '1' then
        partial_error_evaluator <= error_evaluator;
      elsif enable_operation = '1' then
        partial_error_evaluator <= error_evaluator_out;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set done signal
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter /= 0 then
        done <= '0';
      elsif counter = 0 then
        done <= '1';
      end if;
    end if;
  end process;
end architecture;
