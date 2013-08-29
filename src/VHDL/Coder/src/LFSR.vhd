library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

entity LFSR is
  port (
    clock   : in std_logic;
    reset   : in std_logic;
    start   : in std_logic;
    message : in field_element;

    codeword       : out field_element;
    parity_ready   : out std_logic;
    parity_shifted : out std_logic);
end LFSR;

architecture LFSR of LFSR is
  component field_element_multiplier
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  type   states is (idle, calculate_parity, shift_out_parity, set_done);
  signal current_state, next_state : states;

  signal feed_through : field_element;

  signal multiplicand_poly : syndrome_vector;
  signal intermediary_poly : syndrome_vector;

  signal calculation_done : std_logic;
  signal shifted          : std_logic;
  signal freeze           : std_logic;

  signal LFSR_counter   : unsigned(7 downto 0);
  signal parity_counter : unsigned(3 downto 0);
  
begin
  alphas : for I in 0 to T2 - 1 generate
    alphaX : field_element_multiplier
      port map (
        feed_through,
        gen_poly(I),
        multiplicand_poly(I));
  end generate alphas;

  -- multiplication of the received symbol by the highest order element from the partial polynomial
  feed_through <= (others => '0') when reset = '1' or start = '1' else
                  message xor intermediary_poly(T2 - 1);
  
  process(clock, reset)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        current_state <= idle;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  process(current_state, start, calculation_done, shifted)
  begin
    case current_state is
      when idle =>
        if start = '1' then
          next_state <= calculate_parity;
        else
          next_state <= idle;
        end if;
        
      when calculate_parity =>
        if calculation_done = '1' then
          next_state <= shift_out_parity;
        else
          next_state <= calculate_parity;
        end if;
        
      when shift_out_parity =>
        if shifted = '1' then
          next_state <= set_done;
        else
          next_state <= shift_out_parity;
        end if;
        
      when set_done =>
        next_state <= idle;
        
      when others =>
        null;
        
    end case;
  end process;

  process(clock)
  begin
    if clock'event and clock = '1' then
      case current_state is
        when idle =>
          calculation_done  <= '0';
          freeze            <= '0';
          parity_ready      <= '0';
          parity_shifted    <= '0';
          shifted           <= '0';
          LFSR_counter      <= (others => '0');
          parity_counter    <= (others => '0');
          intermediary_poly <= (others => (others => '0'));
          
        when calculate_parity =>
          LFSR_counter <= LFSR_counter + 1;

          if freeze = '0' then
            intermediary_poly(0)  <= multiplicand_poly(0);
            intermediary_poly(1)  <= multiplicand_poly(1) xor intermediary_poly(0);
            intermediary_poly(2)  <= multiplicand_poly(2) xor intermediary_poly(1);
            intermediary_poly(3)  <= multiplicand_poly(3) xor intermediary_poly(2);
            intermediary_poly(4)  <= multiplicand_poly(4) xor intermediary_poly(3);
            intermediary_poly(5)  <= multiplicand_poly(5) xor intermediary_poly(4);
            intermediary_poly(6)  <= multiplicand_poly(6) xor intermediary_poly(5);
            intermediary_poly(7)  <= multiplicand_poly(7) xor intermediary_poly(6);
            intermediary_poly(8)  <= multiplicand_poly(8) xor intermediary_poly(7);
            intermediary_poly(9)  <= multiplicand_poly(9) xor intermediary_poly(8);
            intermediary_poly(10) <= multiplicand_poly(10) xor intermediary_poly(9);
            intermediary_poly(11) <= multiplicand_poly(11) xor intermediary_poly(10);
            intermediary_poly(12) <= multiplicand_poly(12) xor intermediary_poly(11);
            intermediary_poly(13) <= multiplicand_poly(13) xor intermediary_poly(12);
            intermediary_poly(14) <= multiplicand_poly(14) xor intermediary_poly(13);
            intermediary_poly(15) <= multiplicand_poly(15) xor intermediary_poly(14);
          end if;

          if LFSR_counter = K_LENGTH - 1 then
            freeze           <= '1';
            calculation_done <= '1';
          elsif LFSR_counter = K_LENGTH then
            parity_ready <= '1';
          end if;
          
        when shift_out_parity =>
          if parity_counter < T2 - 1 then
            parity_counter <= parity_counter + 1;
          else
            shifted <= '1';
          end if;
          
        when set_done =>
          parity_shifted <= '1';
          
        when others =>
		    null;
      end case;
    end if;
  end process;

  codeword <= intermediary_poly(T2 - 1 - to_integer(parity_counter));
end LFSR;
