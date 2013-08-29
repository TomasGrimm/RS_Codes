library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity Chien_Forney is
  port (
    clock         : in std_logic;       -- clock signal
    reset         : in std_logic;       -- reset signal
    enable        : in std_logic;  -- enables this unit when the key equation is ready
    syndrome      : in syndrome_vector;
    error_locator : in key_equation;

    done               : out std_logic;  -- signals when the search is done
    estimated_codeword : out codeword_array);
end entity;

architecture Chien_Forney of Chien_Forney is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  component scalar_multiplier is
    port (
      element    : in  field_element;
      polynomial : in  key_equation;
      multiplied : out key_equation);
  end component;

  type states is (idle, prepare_omega, calculate_omega, set_alpha, prepare_key_equation, solve_key_equation, analyze_key_evaluated,
                  evaluate_is_root, prepare_error_evaluator, calculate_error_evaluator, prepare_independent_term, generate_alpha_stub,
                  prepare_sigma_derived_inversion, calculate_sigma_derived_inversion, evaluate_error_magnitude, update_estimated_codeword, set_done);
  signal current_state, next_state : states;

  signal alpha                   : field_element;
  signal alpha_stub              : field_element;
  signal key_evaluated           : field_element;
  signal mult1_a                 : field_element;
  signal mult1_b                 : field_element;
  signal mult2_a                 : field_element;
  signal mult2_b                 : field_element;
  signal mult1_out               : field_element;
  signal mult2_out               : field_element;
  signal omega_evaluated         : field_element;
  signal sigma_derived_evaluated : field_element;
  signal sigma_derived_inverted  : field_element;
  signal syndrome_element        : field_element;

  signal codeword_index : integer;
  signal key_counter    : integer;
  signal omega_index    : integer;
  signal syndrome_index : integer;

  signal omega_step    : key_equation;
  signal sigma_derived : key_equation;

  signal omega : omega_array;

  signal is_last_element : std_logic;
  signal is_root         : std_logic;
  
begin
  omega_multiplier : scalar_multiplier
    port map (
      element    => syndrome_element,
      polynomial => error_locator,
      multiplied => omega_step);

  multiplicator_1 : field_element_multiplier
    port map (
      u => mult1_a,
      v => mult1_b,
      w => mult1_out);

  multiplicator_2 : field_element_multiplier
    port map (
      u => mult2_a,
      v => mult2_b,
      w => mult2_out);

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

  process(current_state, enable, syndrome_index, is_last_element, is_root, omega_index, codeword_index, key_counter, mult1_out)
  begin
    case current_state is
      when idle =>
        if enable = '1' then
          next_state <= prepare_omega;
        else
          next_state <= idle;
        end if;
        
      when prepare_omega =>
        next_state <= calculate_omega;
        
      when calculate_omega =>
        if syndrome_index = (T2 - 1) then
          next_state <= set_alpha;
        else
          next_state <= prepare_omega;
        end if;
        
      when set_alpha =>
        next_state <= prepare_key_equation;

      when prepare_key_equation =>
        next_state <= solve_key_equation;
        
      when solve_key_equation =>
        if key_counter = 0 then
          next_state <= analyze_key_evaluated;
        else
          next_state <= prepare_key_equation;
        end if;

      when analyze_key_evaluated =>
        next_state <= evaluate_is_root;
        
      when evaluate_is_root =>
        if is_root = '1' then
          next_state <= prepare_error_evaluator;
        elsif is_last_element = '1' then
          next_state <= set_done;
        else
          next_state <= update_estimated_codeword;
        end if;

      when prepare_error_evaluator =>
        next_state <= calculate_error_evaluator;

      when calculate_error_evaluator =>
        if omega_index = 0 then
          next_state <= prepare_independent_term;
        else
          next_state <= prepare_error_evaluator;
        end if;

      when prepare_independent_term =>
        next_state <= generate_alpha_stub;

      when generate_alpha_stub =>
        next_state <= prepare_sigma_derived_inversion;
        
      when prepare_sigma_derived_inversion =>
        next_state <= calculate_sigma_derived_inversion;

      when calculate_sigma_derived_inversion =>
        if mult1_out = alpha_zero then
          next_state <= evaluate_error_magnitude;
        else
          next_state <= generate_alpha_stub;
        end if;

      when evaluate_error_magnitude =>
        next_state <= update_estimated_codeword;

      when update_estimated_codeword =>
        if codeword_index = N_LENGTH - 1 then
          next_state <= set_done;
        else
          next_state <= set_alpha;
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
          done               <= '0';
          estimated_codeword <= (others => (others => '0'));

          alpha            <= last_element;  -- initialize with a^(n-2) to return to a^0 on the first time to enter "set_alpha"
          key_evaluated    <= (others => '0');
          mult1_a          <= (others => '0');
          mult1_b          <= (others => '0');
          mult2_a          <= (others => '0');
          mult2_b          <= (others => '0');
          omega_evaluated  <= (others => '0');
          syndrome_element <= (others => '0');

          sigma_derived           <= (others => (others => '0'));
          sigma_derived_evaluated <= (others => '0');
          sigma_derived_inverted  <= (others => '0');

          codeword_index <= 0;
          omega_index    <= T2 - 1;
          syndrome_index <= 0;
          key_counter    <= 0;

          omega <= (others => (others => '0'));

          is_last_element <= '0';
          is_root         <= '0';

          -- the derivative of a polynomial with coefficients 
          -- from an extension field eliminate the terms 
          -- multiplied by an even power of x
          sigma_derived(0) <= error_locator(1);
          sigma_derived(2) <= error_locator(3);
          sigma_derived(4) <= error_locator(5);
          sigma_derived(6) <= error_locator(7);
          
        when prepare_omega =>
          syndrome_element <= syndrome(syndrome_index);
          
        when calculate_omega =>
          omega(syndrome_index)     <= omega(syndrome_index) xor omega_step(0);
          omega(syndrome_index + 1) <= omega(syndrome_index + 1) xor omega_step(1);
          omega(syndrome_index + 2) <= omega(syndrome_index + 2) xor omega_step(2);
          omega(syndrome_index + 3) <= omega(syndrome_index + 3) xor omega_step(3);
          omega(syndrome_index + 4) <= omega(syndrome_index + 4) xor omega_step(4);
          omega(syndrome_index + 5) <= omega(syndrome_index + 5) xor omega_step(5);
          omega(syndrome_index + 6) <= omega(syndrome_index + 6) xor omega_step(6);
          omega(syndrome_index + 7) <= omega(syndrome_index + 7) xor omega_step(7);
          omega(syndrome_index + 8) <= omega(syndrome_index + 8) xor omega_step(8);

          -- (syndrome * key_equation) mod x^2t
          omega(T2 to (T2 + T - 1)) <= (others => (others => '0'));

          syndrome_index <= syndrome_index + 1;
          
        when set_alpha =>
          alpha(7) <= alpha(6);
          alpha(6) <= alpha(5);
          alpha(5) <= alpha(4);
          alpha(4) <= alpha(3) xor alpha(7);
          alpha(3) <= alpha(2) xor alpha(7);
          alpha(2) <= alpha(1) xor alpha(7);
          alpha(1) <= alpha(0);
          alpha(0) <= alpha(7);

          omega_evaluated <= (others => '0');
          omega_index     <= T2 - 1;
          key_counter     <= T;
          key_evaluated   <= (others => '0');
          
        when prepare_key_equation =>
          mult1_a     <= alpha;
          mult1_b     <= error_locator(key_counter);
          key_counter <= key_counter - 1;
          
        when solve_key_equation =>
          if key_counter = 0 then
            key_evaluated <= key_evaluated xor mult1_out xor error_locator(0);
          else
            key_evaluated <= key_evaluated xor mult1_out;
          end if;

        when analyze_key_evaluated =>
          if key_counter = 0 then
            if alpha = last_element then
              is_last_element <= '1';
            else
              is_last_element <= '0';
            end if;

            if key_evaluated = all_zeros then
              is_root <= '1';
            else
              is_root <= '0';
            end if;
          end if;
          
        when evaluate_is_root =>
          -- the other process will set the next state based on the 'is_root' variable

        when prepare_error_evaluator =>
          mult1_a <= omega(omega_index);
          mult1_b <= alpha;

          if omega_index <= T then
            mult2_a <= sigma_derived(omega_index);
            mult2_b <= alpha;
          end if;

          omega_index <= omega_index - 1;

        when calculate_error_evaluator =>
          omega_evaluated <= omega_evaluated xor mult1_out;  -- apply Horner's rule to all elements multiplied by x

          if omega_index < T then
            sigma_derived_evaluated <= sigma_derived_evaluated xor mult2_out;
          end if;

        when prepare_independent_term =>
          omega_evaluated         <= omega_evaluated xor omega(0);  -- sum the independent element in the end
          sigma_derived_evaluated <= sigma_derived_evaluated xor sigma_derived(0);

          alpha_stub <= last_element;

        when generate_alpha_stub =>
          alpha_stub(7) <= alpha_stub(6);
          alpha_stub(6) <= alpha_stub(5);
          alpha_stub(5) <= alpha_stub(4);
          alpha_stub(4) <= alpha_stub(3) xor alpha_stub(7);
          alpha_stub(3) <= alpha_stub(2) xor alpha_stub(7);
          alpha_stub(2) <= alpha_stub(1) xor alpha_stub(7);
          alpha_stub(1) <= alpha_stub(0);
          alpha_stub(0) <= alpha_stub(7);
          
        when prepare_sigma_derived_inversion =>
          mult1_a <= sigma_derived_evaluated;
          mult1_b <= alpha_stub;
          
        when calculate_sigma_derived_inversion =>
          -- the other process will evaluate the multiplication result to set
          -- the next_state signal
          sigma_derived_inverted <= alpha_stub;

        when evaluate_error_magnitude =>
          mult1_a <= omega_evaluated;
          mult1_b <= sigma_derived_inverted;
          
        when update_estimated_codeword =>
          if is_root = '1' then
            if codeword_index = 0 then
              estimated_codeword(codeword_index) <= mult1_out;
            else
              estimated_codeword(N_LENGTH - codeword_index) <= mult1_out;
            end if;
          end if;

          codeword_index <= codeword_index + 1;
          
        when set_done =>
          done <= '1';

        when others =>
          null;
      end case;
    end if;
  end process;
end architecture;
