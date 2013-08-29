library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- Implementation of the invertionless Berlekamp-Massey algorithm

entity BerlekampMassey is
  port (
    clock    : in std_logic;
    reset    : in std_logic;
    enable   : in std_logic;
    syndrome : in syndrome_vector;

    --error    : out std_logic;
    done            : out std_logic;
    error_locator   : out key_equation;
    error_evaluator : out omega_array);
end entity;

architecture BerlekampMassey of BerlekampMassey is
  component field_element_multiplier is
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  type   states is (idle, prepare_discrepancy, calculate_discrepancy, prepare_polynomials, update_signals, prepare_omega, calculate_omega, set_done);
  signal current_state, next_state : states;

  signal discrepancy         : field_element;
  signal discrepancy_A       : field_element;
  signal discrepancy_B       : field_element;
  signal discrepancy_product : field_element;
  signal sigma_A             : field_element;
  signal sigmaX_A            : field_element;
  signal theta               : field_element;

  signal B              : key_equation;
  signal sigma          : key_equation;
  signal sigma_B        : key_equation;
  signal sigma_product  : key_equation;
  signal sigmaX_B       : key_equation;
  signal sigmaX_product : key_equation;
  signal temp_sigma     : key_equation;

  signal discrepancy_index : integer;
  signal index             : integer;
  signal L                 : integer;

  signal discrepancy_done : std_logic;
  signal lambda           : std_logic;

  type temp_array is array (0 to T2 + T - 1) of field_element;
  signal omega_temp : temp_array;
  
begin
  discrepancy_multiplier : field_element_multiplier port map (discrepancy_A, discrepancy_B, discrepancy_product);

  sigma_multiplier : for I in 0 to T generate
    multiplier : field_element_multiplier port map(sigma_A, sigma_B(I), sigma_product(I));
  end generate sigma_multiplier;
  
  sigmaX_multiplier : for I in 0 to T generate
    multiplier : field_element_multiplier port map(sigmaX_A, sigmaX_B(I), sigmaX_product(I));
  end generate sigmaX_multiplier;
  
  lambda <= '1' when (discrepancy /= all_zeros) and ((L + L) <= index) else
            '0';

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

  process(current_state, enable, discrepancy_done, index)
  begin
    case current_state is
      when idle =>
        if enable = '1' then
          next_state <= prepare_discrepancy;
        else
          next_state <= idle;
        end if;
        
      when prepare_discrepancy =>
        next_state <= calculate_discrepancy;
        
      when calculate_discrepancy =>
        if discrepancy_done = '1' then
          next_state <= prepare_polynomials;
        else
          next_state <= prepare_discrepancy;
        end if;
        
      when prepare_polynomials =>
        next_state <= update_signals;
        
      when update_signals =>
        if index = (T2 - 1) then
          next_state <= prepare_omega;
        else
          next_state <= prepare_discrepancy;
        end if;

      when prepare_omega =>
        next_state <= calculate_omega;
        
      when calculate_omega =>
        if index = (T2 - 1) then
          next_state <= set_done;
        else
          next_state <= prepare_omega;
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
          error_locator   <= (others => (others => '0'));
          error_evaluator <= (others => (others => '0'));

          discrepancy      <= (others => '0');
          discrepancy_A    <= (others => '0');
          discrepancy_B    <= (others => '0');
          sigma_A          <= (others => '0');
          sigmaX_A         <= (others => '0');
          theta            <= (0      => '1', others => '0');

          B          <= (others => (others => '0'));
          B(0)       <= (0      => '1', others => '0');
          sigma      <= (others => (others => '0'));
          sigma(0)   <= (0      => '1', others => '0');
          sigma_B    <= (others => (others => '0'));
          sigmaX_B   <= (others => (others => '0'));
          temp_sigma <= (others => (others => '0'));

          discrepancy_index <= 0;
          index             <= 0;
          L                 <= 0;

          discrepancy_done <= '0';

          omega_temp <= (others => (others => '0'));

        -- The discrepancy is calculated according to the current index and the
        -- value of L
        when prepare_discrepancy =>
          discrepancy_A <= sigma(discrepancy_index);
          discrepancy_B <= syndrome(index - discrepancy_index);

          if discrepancy_index < L then
            discrepancy_index <= discrepancy_index + 1;
            discrepancy_done  <= '0';
          else
            discrepancy_done <= '1';
          end if;
          
        when calculate_discrepancy =>
          discrepancy <= discrepancy xor discrepancy_product;

        when prepare_polynomials =>
          temp_sigma <= sigma;
          
          sigma_A <= theta;
          sigma_B <= sigma;

          sigmaX_A <= discrepancy;
          sigmaX_B <= B;
          
        when update_signals =>
          -- In the case that the discrepancy is different from zero and the
          -- current index is smaller than twice the polynomial's length the
          -- connection polynomial has to be updated, along with the L and
          -- theta variables.
          sigma(0) <= sigma_product(0);
          sigma(1) <= sigma_product(1) xor sigmaX_product(0);
          sigma(2) <= sigma_product(2) xor sigmaX_product(1);
          sigma(3) <= sigma_product(3) xor sigmaX_product(2);
          sigma(4) <= sigma_product(4) xor sigmaX_product(3);
          sigma(5) <= sigma_product(5) xor sigmaX_product(4);
          sigma(6) <= sigma_product(6) xor sigmaX_product(5);
          sigma(7) <= sigma_product(7) xor sigmaX_product(6);
          sigma(8) <= sigma_product(8) xor sigmaX_product(7);
          
          if lambda = '1' then
            B <= temp_sigma;

            theta <= discrepancy;
            L     <= index - L + 1;
            
          elsif lambda = '0' then
            B(0) <= (others => '0');
            B(1) <= B(0);
            B(2) <= B(1);
            B(3) <= B(2);
            B(4) <= B(3);
            B(5) <= B(4);
            B(6) <= B(5);
            B(7) <= B(6);
            B(8) <= B(7);

            theta <= theta;
            L     <= L;
          end if;

          if index = (T2 - 1) then
            index <= 0;
          else
            index <= index + 1;
          end if;

          discrepancy       <= (others => '0');
          discrepancy_index <= 0;
          
        when prepare_omega =>
          -- After the error locator polynomial is calculated, the error
          -- evaluator polynomial is determined
          -- The polynomial has the form
          -- (syndrome * error_locator) mod (x^2t)
          sigma_A <= syndrome(index);
          sigma_B <= sigma;
          
        when calculate_omega =>
          omega_temp(index)     <= omega_temp(index) xor sigma_product(0);
          omega_temp(index + 1) <= omega_temp(index + 1) xor sigma_product(1);
          omega_temp(index + 2) <= omega_temp(index + 2) xor sigma_product(2);
          omega_temp(index + 3) <= omega_temp(index + 3) xor sigma_product(3);
          omega_temp(index + 4) <= omega_temp(index + 4) xor sigma_product(4);
          omega_temp(index + 5) <= omega_temp(index + 5) xor sigma_product(5);
          omega_temp(index + 6) <= omega_temp(index + 6) xor sigma_product(6);
          omega_temp(index + 7) <= omega_temp(index + 7) xor sigma_product(7);
          omega_temp(index + 8) <= omega_temp(index + 8) xor sigma_product(8);

          index <= index + 1;
          
        when set_done =>
          done            <= '1';
          error_locator   <= sigma;
          error_evaluator(0) <= omega_temp(0);
          error_evaluator(1) <= omega_temp(1);
          error_evaluator(2) <= omega_temp(2);
          error_evaluator(3) <= omega_temp(3);
          error_evaluator(4) <= omega_temp(4);
          error_evaluator(5) <= omega_temp(5);
          error_evaluator(6) <= omega_temp(6);
          error_evaluator(7) <= omega_temp(7);
          error_evaluator(8) <= omega_temp(8);
          error_evaluator(9) <= omega_temp(9);
          error_evaluator(10) <= omega_temp(10);
          error_evaluator(11) <= omega_temp(11);
          error_evaluator(12) <= omega_temp(12);
          error_evaluator(13) <= omega_temp(13);
          error_evaluator(14) <= omega_temp(14);
          error_evaluator(15) <= omega_temp(15);
          
        when others =>
          null;
          
      end case;
    end if;
  end process;
end architecture;
