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
    done     : out std_logic;
    equation : out key_equation);
end entity;

architecture BerlekampMassey of BerlekampMassey is
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

  type   states is (idle, prepare_discrepancy, calculate_discrepancy, set_lambda, prepare_polynomials, update_signals, set_done);
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
  signal double_L          : integer;
  signal index             : integer;
  signal L                 : integer;

  signal discrepancy_done        : std_logic;
  signal lambda                  : std_logic;
  signal update_polynomials_done : std_logic;
  
begin
  discrepancy_multiplier : field_element_multiplier
    port map (
      u => discrepancy_A,
      v => discrepancy_B,
      w => discrepancy_product);

  sigma_multiplier : scalar_multiplier
    port map (
      element    => sigma_A,
      polynomial => sigma_B,
      multiplied => sigma_product);

  sigmaX_multiplier : scalar_multiplier
    port map (
      element    => sigmaX_A,
      polynomial => sigmaX_B,
      multiplied => sigmaX_product);

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
          next_state <= set_lambda;
        else
          next_state <= prepare_discrepancy;
        end if;
        
      when set_lambda =>
        next_state <= prepare_polynomials;
        
      when prepare_polynomials =>
        next_state <= update_signals;
        
      when update_signals =>
        if index = (T2 - 1) then
          next_state <= set_done;
        else
          next_state <= prepare_discrepancy;
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
          done              <= '0';
          discrepancy_done  <= '0';
          lambda            <= '0';
          L                 <= 0;
          index             <= 0;
          double_L          <= 0;
          discrepancy_index <= 0;
          discrepancy       <= (others => '0');
          discrepancy_A     <= (others => '0');
          discrepancy_B     <= (others => '0');
          sigma_A           <= (others => '0');
          sigmaX_A          <= (others => '0');
          equation          <= (others => (others => '0'));
          sigma             <= (others => (others => '0'));
          B                 <= (others => (others => '0'));
          sigma_B           <= (others => (others => '0'));
          sigmaX_B          <= (others => (others => '0'));
          temp_sigma        <= (others => (others => '0'));

          sigma(0) <= (0 => '1', others => '0');
          B(0)     <= (0 => '1', others => '0');
          theta    <= (0 => '1', others => '0');
          
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
          double_L    <= L + L;
          
        when set_lambda =>
          if (discrepancy /= "00000000") and (double_L <= index) then
            lambda <= '1';
          else
            lambda <= '0';
          end if;

          temp_sigma <= sigma;
          sigma      <= (others => (others => '0'));
          
        when prepare_polynomials =>
          sigma_A <= theta;
          sigma_B <= temp_sigma;

          sigmaX_A <= discrepancy;
          sigmaX_B <= B;
          
        when update_signals =>
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
            B(0) <= temp_sigma(0);
            B(1) <= temp_sigma(1);
            B(2) <= temp_sigma(2);
            B(3) <= temp_sigma(3);
            B(4) <= temp_sigma(4);
            B(5) <= temp_sigma(5);
            B(6) <= temp_sigma(6);
            B(7) <= temp_sigma(7);
            B(8) <= temp_sigma(8);

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

          index             <= index + 1;
          discrepancy       <= (others => '0');
          discrepancy_index <= 0;
          
        when set_done =>
          done     <= '1';
          equation <= sigma;

        when others =>
          null;
          
      end case;
    end if;
  end process;
end architecture;
