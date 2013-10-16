library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

entity Erasure is
  port (
    clock          : in  std_logic;
    reset          : in  std_logic;
    enable         : in  std_logic;
    erase          : in  std_logic;
    done           : out std_logic;
    erasures       : out T2_array;
    erasures_count : out unsigned(T downto 0));
end Erasure;

architecture Erasure of Erasure is
  component field_element_multiplier
    port (
      u : in  field_element;
      v : in  field_element;
      w : out field_element);
  end component;

  signal enable_operation : std_logic;
  
  signal counter          : unsigned(T downto 0);
  signal erasures_counter : unsigned(T downto 0);

  signal alpha : field_element;

  signal temp_erasures      : T2_array;
  signal multipliers_output : T2_array;
  signal erasures_helper    : T2_array;
  
begin
  multipliers : for I in 0 to T2 generate
    terms : field_element_multiplier port map (temp_erasures(I), alpha, multipliers_output(I));
  end generate multipliers;

  erasures_helper(0) <= alpha_zero when reset = '1';
  addition : for J in 1 to T2 generate
    erasures_helper(J) <= (others => '0') when reset = '1' or enable = '1' else
                          multipliers_output(J - 1) xor temp_erasures(J) when erase = '1' and enable_operation = '1';
  end generate addition;

  -----------------------------------------------------------------------------
  -- Enable operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter = N_LENGTH then
        enable_operation <= '0';
      elsif enable = '1' then
        enable_operation <= '1';
      end if;
    end if;
  end process;
  
  -----------------------------------------------------------------------------
  -- Counter to control the polynomial generation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable_operation = '0' then
        counter <= (others => '0');
      elsif enable_operation = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Generate decreasing alphas to populate erasure polynomial
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        alpha <= alpha_zero;
      elsif enable_operation = '1' then
        alpha(7) <= alpha(0);
        alpha(6) <= alpha(7);
        alpha(5) <= alpha(6);
        alpha(4) <= alpha(5);
        alpha(3) <= alpha(4) xor alpha(0);
        alpha(2) <= alpha(3) xor alpha(0);
        alpha(1) <= alpha(2) xor alpha(0);
        alpha(0) <= alpha(1);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Erasures counter
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        erasures_counter <= (others => '0');
      elsif enable_operation = '1' then
        if erase = '1' then
          erasures_counter <= erasures_counter + 1;
        else
          erasures_counter <= erasures_counter;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Erasures polynomial
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        temp_erasures    <= (others => (others => '0'));
        temp_erasures(0) <= (0      => '1', others => '0');
      elsif enable_operation = '1' then
        temp_erasures <= erasures_helper;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set done signal
  -----------------------------------------------------------------------------
  process(counter)
  begin
    if counter /= N_LENGTH + 1 then
      done <= '0';
    else
      done <= '1';
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Output erasures polynomial
  -----------------------------------------------------------------------------
  erasures <= temp_erasures;

  -----------------------------------------------------------------------------
  -- Output erasures count
  -----------------------------------------------------------------------------
  erasures_count <= erasures_counter;
  
end Erasure;
