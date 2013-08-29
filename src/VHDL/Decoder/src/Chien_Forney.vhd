library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

-- Chien search and Forney's algorithm module
-- This module has been designed following the architecture from Yuan's "A
-- Practical Guide to Error-Control Coding Using MATLAB" page 148.

entity Chien_Forney is
  port (
    clock           : in std_logic;     -- clock signal
    reset           : in std_logic;     -- reset signal
    enable          : in std_logic;  -- enables this unit when the key equation is ready
    error_locator   : in key_equation;
    error_evaluator : in omega_array;

    done            : out std_logic;    -- signals when the search is done
    is_root         : out std_logic;
    processing      : out std_logic;
    error_index     : out integer;
    error_magnitude : out field_element);
end entity;

architecture Chien_Forney of Chien_Forney is
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

  type   states is (idle, capture_input, chienize, set_done);
  signal current_state, next_state : states;

  signal processed          : std_logic;
  signal process_alpha_zero : std_logic;
  signal sum_and_compare    : std_logic;

  signal alpha          : field_element;
  signal omega_scaled   : field_element;
  signal omega_sum      : field_element;
  signal sigma_sum      : field_element;
  signal sigma_derived  : field_element;
  signal sigma_inverted : field_element;

  signal error_locator_out     : key_equation;
  signal partial_error_locator : key_equation;
  signal sigma_input           : key_equation;

  signal error_evaluator_out     : omega_array;
  signal partial_error_evaluator : omega_array;
  signal omega_input             : omega_array;

  signal iterations_counter : integer;

  constant sigma_alpha_zero : key_equation := (others => "00000001");
  constant sigma_alphas : key_equation := ("00000001",
                                           "00000010",
                                           "00000100",
                                           "00001000",
                                           "00010000",
                                           "00100000",
                                           "01000000",
                                           "10000000",
                                           "00011101");

  constant omega_alpha_zero : omega_array := (others => "00000001");
  constant omega_alphas : omega_array := ("00000001",
                                          "00000010",
                                          "00000100",
                                          "00001000",
                                          "00010000",
                                          "00100000",
                                          "01000000",
                                          "10000000",
                                          "00011101",
                                          "00111010",
                                          "01110100",
                                          "11101000",
                                          "11001101",
                                          "10000111",
                                          "00010011",
                                          "00100110");

begin
  processing  <= sum_and_compare;
  error_index <= iterations_counter;

  -- When the Chien search starts, the first element to multiply the error
  -- locator polynomial is alpha^0, and as all the powers of alpha^0 are equal to
  -- alpha^0, the first iteration uses the variable sigma_alpha_zero.
  -- For the other n - 1 iterations, the variable sigma_alphas is used, so that
  -- every new iteration has the previous result multiplied by alpha.
  sigma_input <= (others => (others => '0')) when enable = '1' else
                 sigma_alpha_zero when iterations_counter = 0 else
                 sigma_alphas;

  -- When the Forney algorithm starts, the first element to multiply the error
  -- evaluator polynomial is alpha^0, and as all the powers of alpha^0 are equal to
  -- alpha^0, the first iteration uses the variable omega_alpha_zero.
  -- For the other n - 1 iterations, the variable omega_alphas is used, so that
  -- every new iteration has the previous result multiplied by alpha.
  omega_input <= (others => (others => '0')) when enable = '1' else
                 omega_alpha_zero when iterations_counter = 0 else
                 omega_alphas;

  -- The error locator polynomial has to be evaluated for each value of alpha
  error_locator_terms : for I in 0 to T generate
    term : field_element_multiplier port map (sigma_input(I), partial_error_locator(I), error_locator_out(I));
  end generate;

  -- The error evaluator polynomial has to be evaluated for each value of alpha
  error_evaluator_terms : for J in 0 to (T2 - 1) generate
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
               error_locator_out(8) when sum_and_compare = '1' or process_alpha_zero = '1' else
               (others => '0');

  -- If the error locator polynomial is evaluated as zero, than a root has been
  -- found
  is_root <= '1' when sigma_sum = all_zeros and sum_and_compare = '1' else
             '0';

  -- At the same time that the error locator polynomial is evaluated, its
  -- derivative is also evaluated to be used in the calculation of the error magnitude.
  sigma_derived <= error_locator_out(1) xor
                   error_locator_out(3) xor
                   error_locator_out(5) xor
                   error_locator_out(7) when sum_and_compare = '1' or process_alpha_zero = '1' else
                   (others => '0');

  -- After being evaluated, all the terms from the error locator polynomial must be summed.
  omega_sum <= error_evaluator_out(0) xor
               error_evaluator_out(1) xor
               error_evaluator_out(2) xor
               error_evaluator_out(3) xor
               error_evaluator_out(4) xor
               error_evaluator_out(5) xor
               error_evaluator_out(6) xor
               error_evaluator_out(7) xor
               error_evaluator_out(8) xor
               error_evaluator_out(9) xor
               error_evaluator_out(10) xor
               error_evaluator_out(11) xor
               error_evaluator_out(12) xor
               error_evaluator_out(13) xor
               error_evaluator_out(14) xor
               error_evaluator_out(15) when sum_and_compare = '1' or process_alpha_zero = '1' else
               (others => '0');

  -- To avoid the division operation, the result from the derivative is inverted.
  inverter : inversion_table port map (sigma_derived, sigma_inverted);

  -- To nullify the effect of the alpha^i being multiplied to the error locator
  -- derivative, the error evaluator is multiplied by alpha^i
  omega_scaling : field_element_multiplier port map (omega_sum, alpha, omega_scaled);

  -- Finally, the error magnitude is calculated as the multiplication of the
  -- scaled version of the result from the error evaluator polynomial by the
  -- derivative of the error locator polynomial.
  magnitude_calculation : field_element_multiplier port map (omega_sum, sigma_inverted, error_magnitude);

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        current_state <= idle;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  process(current_state, enable, iterations_counter, processed)
  begin
    case current_state is
      when idle =>
        if enable = '1' then
          next_state <= capture_input;
        else
          next_state <= idle;
        end if;

      when capture_input =>
        next_state <= chienize;
        
      when chienize =>
        if iterations_counter = 0 and processed = '1' then
          next_state <= set_done;
        else
          next_state <= chienize;
        end if;

      when set_done =>
        next_state <= idle;
        
      when others =>
        next_state <= idle;
    end case;
  end process;

  process(clock)
  begin
    if clock'event and clock = '1' then
      done               <= '0';
      process_alpha_zero <= '0';
      sum_and_compare    <= '0';

      case current_state is
        when idle =>
          alpha <= last_element;

          partial_error_locator   <= (others => (others => '0'));
          partial_error_evaluator <= (others => (others => '0'));

        when capture_input =>
          -- In this state the inputs are captured and the calulation for
          -- alpha^0 is performed, so that, starting in the next clock cycle,
          -- the first calculated magnitude is added to the highest degree term
          -- of the received polynomial, should it have any errors.
          partial_error_locator   <= error_locator;
          partial_error_evaluator <= error_evaluator;

          process_alpha_zero <= '1';

          alpha(7) <= alpha(6);
          alpha(6) <= alpha(5);
          alpha(5) <= alpha(4);
          alpha(4) <= alpha(3) xor alpha(7);
          alpha(3) <= alpha(2) xor alpha(7);
          alpha(2) <= alpha(1) xor alpha(7);
          alpha(1) <= alpha(0);
          alpha(0) <= alpha(7);
          
        when chienize =>
          partial_error_locator   <= error_locator_out;
          partial_error_evaluator <= error_evaluator_out;

          sum_and_compare <= '1';

          alpha(7) <= alpha(6);
          alpha(6) <= alpha(5);
          alpha(5) <= alpha(4);
          alpha(4) <= alpha(3) xor alpha(7);
          alpha(3) <= alpha(2) xor alpha(7);
          alpha(2) <= alpha(1) xor alpha(7);
          alpha(1) <= alpha(0);
          alpha(0) <= alpha(7);
          
        when set_done =>
          done <= '1';
          
        when others =>
          null;
      end case;
    end if;
  end process;

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        processed          <= '0';
        iterations_counter <= 0;
        
      elsif sum_and_compare = '1' then
        if iterations_counter > 0 then
          iterations_counter <= iterations_counter - 1;
          processed          <= '1';
        else
          iterations_counter <= 0;
        end if;
      end if;

      if alpha = alpha_zero then
        iterations_counter <= N_LENGTH - 1;
      end if;
    end if;
  end process;
end architecture;
