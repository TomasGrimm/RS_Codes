library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

entity Euclidean is
  port (
    clock    : in std_logic;
    reset    : in std_logic;
    enable   : in std_logic;
    syndrome : in T2less1_array;

    done            : out std_logic;
    error_locator   : out T_array;
    error_evaluator : out T2less1_array);
end Euclidean;

architecture Euclidean of Euclidean is
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
  signal R_control        : std_logic;

  signal counter : unsigned(SYMBOL_LENGTH/2 - 1 downto 0);

  signal R      : T2less1_array;
  signal Rb_out : T2less1_array;
  signal Q      : T2less1_array;
  signal Qa_out : T2less1_array;

  signal lambda      : T_array;
  signal lambdab_out : T_array;
  signal mu          : T_array;
  signal mua_out     : T_array;

begin
  R_mult_b : for I in 0 to T2 - 2 generate
    term_R : field_element_multiplier port map (Q(T2 - 1), R(I), Rb_out(I));
  end generate R_mult_b;

  Q_mult_a : for J in 0 to T2 - 2 generate
    term_Q : field_element_multiplier port map (R(T2 - 1), Q(J), Qa_out(J));
  end generate Q_mult_a;

  lambda_mult_b : for K in 0 to T generate
    term_lambda : field_element_multiplier port map (Q(T2 - 1), lambda(K), lambdab_out(K));
  end generate lambda_mult_b;

  mu_mult_a : for L in 0 to T generate
    term_mu : field_element_multiplier port map (R(T2 - 1), mu(L), mua_out(L));
  end generate mu_mult_a;

  -----------------------------------------------------------------------------
  -- Enable operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or counter = T2 - 2 then
        enable_operation <= '0';
      elsif enable = '1' then
        enable_operation <= '1';
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Operation counter
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
  -- R operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        R <= (others => (others => '0'));
      elsif enable = '1' then
        R <= all_zeros &
             syndrome(0) &
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
             syndrome(14);
      elsif enable_operation = '1' then
        if R(T2 - 1) = all_zeros then
          R <= all_zeros & R(0 to T2 - 2);
        else
          R(0) <= (others => '0');
          for i in 1 to T2 - 1 loop
            R(i) <= Rb_out(i - 1) xor Qa_out(i - 1);
          end loop;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Q operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        Q <= (others => (others => '0'));
      elsif enable = '1' then
        Q <= syndrome;
      elsif enable_operation = '1' then
        if R_control = '0' and R(T2 - 1) /= all_zeros then
          Q <= R;
        else
          Q <= Q;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- lambda operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        lambda    <= (others => (others => '0'));
        lambda(2) <= (0      => '1', others => '0');
      elsif enable_operation = '1' then
        if R(T2 - 1) = all_zeros then
          lambda <= lambda(T) & lambda(0 to T - 1);
        else
          lambda(0) <= lambdab_out(T) xor mua_out(T);
          for i in 1 to T loop
            lambda(i) <= lambdab_out(i - 1) xor mua_out(i - 1);
          end loop;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- mu operation
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        mu    <= (others => (others => '0'));
        mu(1) <= (0      => '1', others => '0');
      elsif enable_operation = '1' then
        if R_control = '0' and R(T2 - 1) /= all_zeros then
          mu <= lambda;
        else
          mu <= mu;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Control signal
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or enable = '1' then
        R_control <= '1';
      elsif enable_operation = '1' then
        if R(T2 - 1) = all_zeros then
          R_control <= '0';
        else
          R_control <= not R_control;
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Set done signal
  -----------------------------------------------------------------------------
  process(counter)
  begin
    if counter /= T2 - 1 then
      done <= '0';
    else
      done <= '1';
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Output polynomials
  -----------------------------------------------------------------------------
  error_locator   <= lambda;
  error_evaluator <= R;

end architecture;
