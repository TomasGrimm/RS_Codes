library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

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

  type   states is (idle, chienize, set_done);
  signal current_state, next_state : states;

  signal first_iteration : std_logic;
  signal processed       : std_logic;
  signal sum_and_compare : std_logic;

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

  sigma_input <= (others => (others => '0')) when enable = '1' else
                 sigma_alpha_zero when iterations_counter = 0 else
                 sigma_alphas;
  
  error_locator_terms : for I in 0 to T generate
    term : field_element_multiplier port map (sigma_input(I), partial_error_locator(I), error_locator_out(I));
  end generate;

  error_evaluator_terms : for J in 0 to (T2 - 1) generate
    term : field_element_multiplier port map (omega_alphas(J), partial_error_evaluator(J), error_evaluator_out(J));
  end generate;

  sigma_sum <= (others => '0') when sum_and_compare = '0' else
               error_locator_out(0) xor
               error_locator_out(1) xor
               error_locator_out(2) xor
               error_locator_out(3) xor
               error_locator_out(4) xor
               error_locator_out(5) xor
               error_locator_out(6) xor
               error_locator_out(7) xor
               error_locator_out(8);

  is_root <= '1' when sigma_sum = all_zeros and sum_and_compare = '1' else
             '0';
  
  sigma_derived <= (others => '0') when sum_and_compare = '0' else
                   error_locator_out(1) xor
                   error_locator_out(3) xor
                   error_locator_out(5) xor
                   error_locator_out(7);

  omega_sum <= (others => '0') when sum_and_compare = '0' else
               error_evaluator_out(0) xor
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
               error_evaluator_out(15);

  inverter : inversion_table port map (sigma_derived, sigma_inverted);

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
          next_state <= chienize;
        else
          next_state <= idle;
        end if;

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
      case current_state is
        when idle =>
          done            <= '0';
          sum_and_compare <= '0';
          first_iteration <= '1';
          alpha           <= last_element;

          partial_error_locator   <= (others => (others => '0'));
          partial_error_evaluator <= (others => (others => '0'));
          
        when chienize =>
          if first_iteration = '1' then
            partial_error_locator   <= error_locator;
            partial_error_evaluator <= error_evaluator;
            first_iteration         <= '0';
          else
            partial_error_locator   <= error_locator_out;
            partial_error_evaluator <= error_evaluator_out;
          end if;

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
          done            <= '1';
          sum_and_compare <= '0';
          
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

        if alpha = alpha_zero then
          iterations_counter <= N_LENGTH - 1;
        end if;
      end if;
    end if;
  end process;
end architecture;
