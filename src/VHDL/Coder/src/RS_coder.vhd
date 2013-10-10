library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- Reed-Solomon Encoder

entity RS_coder is
  port (
    clock         : in  std_logic;      -- clock signal
    reset         : in  std_logic;  -- signal used to clear all registers and the ready signal
    message_start : in  std_logic;  -- indicates when a new message is ready to be encoded
    message       : in  field_element;  -- message to be encoded
    done          : out std_logic;      -- signals when the processing is done
    codeword      : out field_element);  -- codeword containing the message and the calculated parity bits
end entity;

architecture RS_coder of RS_coder is
  component field_element_multiplier
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal enable_calculation : std_logic;
  signal parity_ready       : std_logic;

  signal delay        : field_element;
  signal feed_through : field_element;

  signal intermediary_poly : T2less1_array;
  signal multiplicand_poly : T2less1_array;

  signal parity_counter  : unsigned(SYMBOL_LENGTH/2 downto 0);
  signal message_counter : unsigned(SYMBOL_LENGTH downto 0);
  
begin
  -----------------------------------------------------------------------------
  -- Delay the message symbol for one cycle to avoid a gap between message
  -- and parity
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        delay <= (others => '0');
      else
        delay <= message;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Multiplication of the received symbol by the highest order 
  -- element from the partial polynomial
  -----------------------------------------------------------------------------
  feed_through <= (others => '0') when reset = '1' or message_start = '1' else
                  message xor intermediary_poly(T2 - 1) when enable_calculation = '1' else
                  all_zeros;

  -----------------------------------------------------------------------------
  -- Multiplication of the feed_through signal by each of the generator
  -- polynomial's coefficients.
  -----------------------------------------------------------------------------
  alphas : for I in 0 to T2 - 1 generate
    alphaX : field_element_multiplier port map (feed_through, gen_poly(I), multiplicand_poly(I));
  end generate alphas;

  -----------------------------------------------------------------------------
  -- Enable signal
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or parity_counter = 0 then
        enable_calculation <= '0';
      elsif message_start = '1' then
        enable_calculation <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Message counter
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or message_start = '1' or parity_counter = 0 then
        message_counter <= (others => '0');
      elsif enable_calculation = '1' and message_counter < K_LENGTH + 2 then
        message_counter <= message_counter + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Parity counter
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or message_start = '1' or parity_counter = 0 then
        parity_counter <= to_unsigned(T2 - 1, SYMBOL_LENGTH/2 + 1);
      elsif enable_calculation = '1' and message_counter = K_LENGTH + 2 then
        if parity_counter > 0 then
          parity_counter <= parity_counter - 1;
        else
          parity_counter <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Parity calculation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or message_start = '1' then
        intermediary_poly <= (others => (others => '0'));
      elsif message_counter < K_LENGTH + 1 then
        intermediary_poly(0) <= multiplicand_poly(0);
        for i in 1 to T2 - 1 loop
          intermediary_poly(i) <= multiplicand_poly(i) xor intermediary_poly(i - 1);
        end loop;
      elsif enable_calculation = '1' and message_counter = K_LENGTH + 2 then
        intermediary_poly <= all_zeros & intermediary_poly(0 to T2 - 2);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set parity_ready signal
  -----------------------------------------------------------------------------
  process(message_counter)
  begin
    if message_counter /= K_LENGTH + 2 then
      parity_ready <= '0';
    else
      parity_ready <= '1';
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set parity_shifted signal
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if parity_counter /= 0 then
        done <= '0';
      else
        done <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Output parity symbols
  -----------------------------------------------------------------------------
  codeword <= delay when parity_ready = '0' else
              intermediary_poly(T2 - 1);
  
end architecture;
