library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

-- realimentar palavra-codigo estimada no bloco da sindrome enquanto faz o
-- shift out, e caso, ao final for diferente de zero, sinalizar erro
-- rever necessidade de registrar saidas da sindrome e do bm (ver se sinais sao
-- registrados dentro dos modulos subsequentes)

-- Reed-Solomon Decoder
--
-- Each code symbol has 8 bits.
-- The received vector is decoded following these steps:
--      1. Syndrome calculation
--      2. Inversionless Berlekamp-Massey for the Error Location Polynomial
--      3. Chien's search to determine the Error Location Polynomial's roots
--      4. Forney's algorithm to evaluate the error's values

entity RS_decoder is
  port (
    clock       : in std_logic;
    reset       : in std_logic;
    start_block : in std_logic;
    end_block   : in std_logic;
    data_in     : in field_element;

    --error    : out std_logic;
    done     : out std_logic;
    data_out : out field_element);
end entity;

architecture RS_decoder of RS_decoder is
  component Syndrome is
    port (
      clock           : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;
      received_vector : in field_element;

      done     : out std_logic;
      syndrome : out T2less1_array);
  end component;

  component BerlekampMassey is
  --component Euclidean is
    port (
      clock    : in std_logic;
      reset    : in std_logic;
      enable   : in std_logic;
      syndrome : in T2less1_array;

      done            : out std_logic;
      error_locator   : out T_array;
      error_evaluator : out T2less1_array);
  end component;

  component Chien_Forney is
    port (
      clock           : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;
      error_locator   : in T_array;
      error_evaluator : in T2less1_array;

      done            : out std_logic;
      is_root         : out std_logic;
      processing      : out std_logic;
      error_index     : out unsigned(T - 1 downto 0);
      error_magnitude : out field_element);
  end component;

  signal bm_done              : std_logic;
  signal cf_done              : std_logic;
  signal cf_processing        : std_logic;
  signal cf_root              : std_logic;
  signal decoding_done        : std_logic;
  signal enable_bm            : std_logic;
  signal received_is_codeword : std_logic;
  signal store_received_poly  : std_logic;
  signal syndrome_done        : std_logic;

  signal syndrome_output : T2less1_array;
  signal syndrome_reg    : T2less1_array;

  signal bm_locator_output   : T_array;
  signal bm_locator_reg      : T_array;
  signal bm_evaluator_output : T2less1_array;
  signal bm_evaluator_reg    : T2less1_array;

  signal cf_magnitude : field_element;

  signal received : N_array;

  signal cf_index     : unsigned(T - 1 downto 0);
  signal output_index : unsigned(T - 1 downto 0);
  
begin
  syndrome_module : Syndrome
    port map (
      clock           => clock,
      reset           => reset,
      enable          => store_received_poly,
      received_vector => data_in,
      done            => syndrome_done,
      syndrome        => syndrome_output);

  enable_bm <= '1' when syndrome_done = '1' and received_is_codeword = '0' else
               '0';

  bm_module : BerlekampMassey
  --bm_module : Euclidean
    port map (
      clock           => clock,
      reset           => reset,
      enable          => enable_bm,
      syndrome        => syndrome_reg,
      done            => bm_done,
      error_locator   => bm_locator_output,
      error_evaluator => bm_evaluator_output);

  cf_module : Chien_Forney
    port map (
      clock           => clock,
      reset           => reset,
      enable          => bm_done,
      error_locator   => bm_locator_reg,
      error_evaluator => bm_evaluator_reg,
      done            => cf_done,
      is_root         => cf_root,
      processing      => cf_processing,
      error_index     => cf_index,
      error_magnitude => cf_magnitude);

  -- After a module finishes its operation, its outputs are registered to be
  -- used by the next.
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or decoding_done = '1' then
        syndrome_reg     <= (others => (others => '0'));
        bm_locator_reg   <= (others => (others => '0'));
        bm_evaluator_reg <= (others => (others => '0'));
        
      elsif syndrome_done = '1' then
        syndrome_reg <= syndrome_output;
        
      elsif bm_done = '1' then
        bm_locator_reg   <= bm_locator_output;
        bm_evaluator_reg <= bm_evaluator_output;
        
      end if;
    end if;
  end process;

  store_received_poly <= '1' when start_block = '1' else
                         '0' when reset = '1' or end_block = '1';

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        received_is_codeword <= '0';
      elsif syndrome_done = '1' then
        for i in 0 to T2 - 1 loop
          if syndrome_reg(i) = all_zeros then
            received_is_codeword <= '1';
          end if;
        end loop;
      end if;
    end if;
  end process;
  
  -- The received polynomial must be registered to be either corrected or
  -- simply shifted out, in case the syndrome signals no errors were found.
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        received <= (others => (others => '0'));
        
      elsif store_received_poly = '1' then
        received <= data_in & received(0 to N_LENGTH - 2);
      end if;
    end if;
  end process;

  -- In case the received polynomial has no errors, this process controls the
  -- output of its symbols.
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        output_index  <= to_unsigned(N_LENGTH - 1, SYMBOL_LENGTH);
        decoding_done <= '0';
        
      else
        if received_is_codeword = '1' then
          if output_index > 0 then
            output_index <= output_index - 1;
          else
            decoding_done <= '1';
            output_index  <= (others => '0');
          end if;
        end if;
      end if;
    end if;
  end process;

  data_out <= received(to_integer(output_index)) when output_codeword = '1' else
              received(to_integer(cf_index)) xor cf_magnitude when cf_root = '1' and cf_processing = '1' else
              received(to_integer(cf_index))                  when cf_root = '0' and cf_processing = '1' else
              (others => '0');

  done <= '1' when decoding_done = '1' or cf_done = '1' else
          '0';
  
end architecture;
