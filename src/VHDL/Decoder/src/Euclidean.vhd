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

    --error    : out std_logic;
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

  type   states is (idle, init, set_params, update, settle, compare, set_done);
  signal current_state, next_state : states;

  signal sigma    : std_logic;
  signal not_done : std_logic;

  signal first_half_R_element       : field_element;
  signal second_half_R_element      : field_element;
  signal first_half_lambda_element  : field_element;
  signal second_half_lambda_element : field_element;
  signal a                          : field_element;
  signal b                          : field_element;

  signal first_half_R_poly         : T2_array;
  signal second_half_R_poly        : T2_array;
  signal first_half_R_output       : T2_array;
  signal second_half_R_output      : T2_array;
  signal first_half_lambda_poly    : T2_array;
  signal second_half_lambda_poly   : T2_array;
  signal first_half_lambda_output  : T2_array;
  signal second_half_lambda_output : T2_array;
  signal R                         : T2_array;
  signal Q                         : T2_array;
  signal mu                        : T2_array;
  signal lambda                    : T2_array;

  signal R_counter : unsigned(4 downto 0);
  signal Q_counter : unsigned(4 downto 0);
  
begin
  first_half_R : for I in 0 to T2 generate
    first_stages : field_element_multiplier port map (first_half_R_element, first_half_R_poly(I), first_half_R_output(I));
  end generate first_half_R;

  second_half_R : for I in 0 to T2 generate
    second_stages : field_element_multiplier port map (second_half_R_element, second_half_R_poly(I), second_half_R_output(I));
  end generate second_half_R;

  first_half_lambda : for I in 0 to T2 generate
    first_stages : field_element_multiplier port map (first_half_lambda_element, first_half_lambda_poly(I), first_half_lambda_output(I));
  end generate first_half_lambda;

  second_half_lambda : for I in 0 to T2 generate
    second_stages : field_element_multiplier port map (second_half_lambda_element, second_half_lambda_poly(I), second_half_lambda_output(I));
  end generate second_half_lambda;

  sigma <= '0' when Q_counter > R_counter else
           '1';
  
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

  process(current_state, enable, not_done)
  begin
    case current_state is
      when idle =>
        if enable = '1' then
          next_state <= init;
        else
          next_state <= idle;
        end if;
        
      when init =>
        next_state <= set_params;

      when set_params =>
        if not_done = '0' then
          next_state <= update;
        else
          next_state <= set_done;
        end if;

      when update =>
        next_state <= settle;

      when settle =>
        next_state <= compare;

      when compare =>
        next_state <= set_params;

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
          error_locator   <= (others => (others => '0'));
          error_evaluator <= (others => (others => '0'));

          done <= '0';
          Q    <= (others => (others => '0'));

          R      <= (others => (others => '0'));
          R(T2)  <= (0      => '1', others => '0');
          lambda <= (others => (others => '0'));
          mu     <= (others => (others => '0'));
          mu(0)  <= (0      => '1', others => '0');

          not_done <= '0';

          R_counter <= (others => '0');
          Q_counter <= (others => '0');

          a                          <= (others => '0');
          b                          <= (others => '0');
          first_half_R_element       <= (others => '0');
          first_half_R_poly          <= (others => (others => '0'));
          second_half_R_element      <= (others => '0');
          second_half_R_poly         <= (others => (others => '0'));
          first_half_lambda_element  <= (others => '0');
          first_half_lambda_poly     <= (others => (others => '0'));
          second_half_lambda_element <= (others => '0');
          second_half_lambda_poly    <= (others => (others => '0'));
          
        when init =>
          for i in 0 to T2 - 1 loop
            Q(i) <= syndrome(i);
          end loop;
          Q(T2) <= all_zeros;
          
        when set_params =>
          for i in T2 downto 0 loop
            if R(i) /= all_zeros then
              a         <= R(i);
              R_counter <= to_unsigned(i, 5);
              exit;
            end if;
          end loop;

          for j in T2 downto 0 loop
            if Q(j) /= all_zeros then
              b         <= Q(j);
              Q_counter <= to_unsigned(j, 5);
              exit;
            end if;
          end loop;

        when update =>
          second_half_R_poly(0 to T2)      <= (others => (others => '0'));
          second_half_lambda_poly(0 to T2) <= (others => (others => '0'));

          if sigma = '0' then
            first_half_R_element      <= a;
            first_half_R_poly         <= Q;
            first_half_lambda_element <= a;
            first_half_lambda_poly    <= mu;

            second_half_R_element      <= b;
            second_half_lambda_element <= b;
            if R_counter = Q_counter then
              second_half_R_poly      <= R;
              second_half_lambda_poly <= lambda;
            elsif R_counter > Q_counter then
              second_half_R_poly(to_integer(R_counter - Q_counter) to T2)      <= R(0 to T2 - to_integer(R_counter - Q_counter));
              second_half_lambda_poly(to_integer(R_counter - Q_counter) to T2) <= lambda(0 to T2 - to_integer(R_counter - Q_counter));
            else
              second_half_R_poly(to_integer(Q_counter - R_counter) to T2)      <= R(0 to T2 - to_integer(Q_counter - R_counter));
              second_half_lambda_poly(to_integer(Q_counter - R_counter) to T2) <= lambda(0 to T2 - to_integer(Q_counter - R_counter));
            end if;
            
          elsif sigma = '1' then
            first_half_R_element      <= b;
            first_half_R_poly         <= R;
            first_half_lambda_element <= b;
            first_half_lambda_poly    <= lambda;

            second_half_R_element      <= a;
            second_half_lambda_element <= a;
            if R_counter = Q_counter then
              second_half_R_poly      <= Q;
              second_half_lambda_poly <= mu;
            elsif R_counter > Q_counter then
              second_half_R_poly(to_integer(R_counter - Q_counter) to T2)      <= Q(0 to T2 - to_integer(R_counter - Q_counter));
              second_half_lambda_poly(to_integer(R_counter - Q_counter) to T2) <= mu(0 to T2 - to_integer(R_counter - Q_counter));
            else
              second_half_R_poly(to_integer(Q_counter - R_counter) to T2)      <= Q(0 to T2 - to_integer(Q_counter - R_counter));
              second_half_lambda_poly(to_integer(Q_counter - R_counter) to T2) <= mu(0 to T2 - to_integer(Q_counter - R_counter));
            end if;
          end if;

        when settle =>
          for i in 0 to T2 loop
            R(i)      <= first_half_R_output(i) xor second_half_R_output(i);
            lambda(i) <= first_half_lambda_output(i) xor second_half_lambda_output(i);
          end loop;
          
        when compare =>
          if sigma = '0' then
            Q  <= R;
            mu <= lambda;
          elsif sigma = '1' then
            Q  <= Q;
            mu <= mu;
          end if;

          not_done <= '1';
          for i in T2 downto t loop
            if R(i) /= all_zeros then
              not_done <= '0';
              exit;
            end if;
          end loop;
          
        when set_done =>
          error_locator   <= T_array(lambda(0 to T));
          error_evaluator <= T2less1_array(R(0 to T2 - 1));

          done <= '1';

        when others =>
          null;
          
      end case;
    end if;
  end process;
end Euclidean;
