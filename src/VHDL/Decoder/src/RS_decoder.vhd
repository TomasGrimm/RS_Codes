library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ReedSolomon.all;

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
    erase       : in std_logic;
    data_in     : in field_element;

    fail     : out std_logic;
    done     : out std_logic;
    data_out : out field_element);
end entity;

architecture RS_decoder of RS_decoder is
  component Syndrome is
    port (
      clock           : in  std_logic;
      reset           : in  std_logic;
      start           : in  std_logic;
      received_vector : in  field_element;
      done            : out std_logic;
      syndrome        : out T2less1_array);
  end component;

  component Erasure is
    port (
      clock          : in  std_logic;
      reset          : in  std_logic;
      enable         : in  std_logic;
      erase          : in  std_logic;
      done           : out std_logic;
      erasures       : out T2less1_array;
      erasures_count : out unsigned(T downto 0));
  end component;

  component BerlekampMassey is
    port (
      clock           : in  std_logic;
      reset           : in  std_logic;
      enable          : in  std_logic;
      syndrome        : in  T2less1_array;
      erasures        : in  T2less1_array;
      erasures_count  : in  unsigned(T downto 0);
      done            : out std_logic;
      error_locator   : out T2less1_array;
      error_evaluator : out T2less1_array);
  end component;

  component Chien_Forney is
    port (
      clock           : in  std_logic;
      reset           : in  std_logic;
      enable          : in  std_logic;
      error_locator   : in  T2less1_array;
      error_evaluator : in  T2less1_array;
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
  signal erasure_done         : std_logic;
  signal received_is_codeword : std_logic;
  signal start_syndrome       : std_logic;
  signal store_received_poly  : std_logic;
  signal syndrome_done        : std_logic;

  signal erasure_output : T2less1_array;
  signal erasure_reg    : T2less1_array;

  signal syndrome_output : T2less1_array;
  signal syndrome_reg    : T2less1_array;

  signal bm_locator_output   : T2less1_array;
  signal bm_evaluator_output : T2less1_array;

  signal cf_magnitude : field_element;
  signal syndrome_in  : field_element;

  signal received : N_array;

  signal erasures_count : unsigned(T downto 0);
  signal cf_index       : unsigned(T - 1 downto 0);
  signal output_index   : unsigned(T - 1 downto 0);
  
begin
  syndrome_module : Syndrome
    port map (
      clock           => clock,
      reset           => reset,
      start           => start_syndrome,
      received_vector => syndrome_in,
      done            => syndrome_done,
      syndrome        => syndrome_output);

  erasure_module : Erasure
    port map (
      clock          => clock,
      reset          => reset,
      enable         => start_block,
      erase          => erase,
      done           => erasure_done,
      erasures       => erasure_output,
      erasures_count => erasures_count);

  bm_module : BerlekampMassey
    port map (
      clock           => clock,
      reset           => reset,
      enable          => enable_bm,
      syndrome        => syndrome_reg,
      erasures        => erasure_reg,
      erasures_count  => erasures_count,
      done            => bm_done,
      error_locator   => bm_locator_output,
      error_evaluator => bm_evaluator_output);

  cf_module : Chien_Forney
    port map (
      clock           => clock,
      reset           => reset,
      enable          => bm_done,
      error_locator   => bm_locator_output,
      error_evaluator => bm_evaluator_output,
      done            => cf_done,
      is_root         => cf_root,
      processing      => cf_processing,
      error_index     => cf_index,
      error_magnitude => cf_magnitude);

  -----------------------------------------------------------------------------
  -- Syndrome reset signal
  -----------------------------------------------------------------------------
  start_syndrome <= '1' when start_block = '1' or bm_done = '1' else
                    '0';

  -----------------------------------------------------------------------------
  -- Set syndrome input
  -----------------------------------------------------------------------------
  syndrome_in <= data_in when store_received_poly = '1' and erase = '0' else
                 (others => '0')                         when store_received_poly = '1' and erase = '1' else
                 received(N_LENGTH - 1)                  when cf_root = '0' and cf_processing = '1'     else
                 received(N_LENGTH - 1) xor cf_magnitude when cf_root = '1' and cf_processing = '1';

  -----------------------------------------------------------------------------
  -- Register syndrome output
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or decoding_done = '1' then
        syndrome_reg <= (others => (others => '0'));
      elsif syndrome_done = '1' then
        syndrome_reg <= syndrome_output;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Store erasure output
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or decoding_done = '1' then
        erasure_reg <= (others => (others => '0'));
      elsif erasure_done = '1' then
        erasure_reg <= erasure_output;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Enable received polynomial storing
  -----------------------------------------------------------------------------
  store_received_poly <= '1' when start_block = '1' else
                         '0' when reset = '1' or syndrome_done = '1';

  -----------------------------------------------------------------------------
  -- Store received polynomial
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        received <= (others => (others => '0'));
      elsif store_received_poly = '1' and erase = '0' then
        received <= data_in & received(0 to N_LENGTH - 2);
      elsif store_received_poly = '1' and erase = '1' then
        received <= all_zeros & received(0 to N_LENGTH - 2);
      elsif received_is_codeword = '1' or cf_processing = '1' then
        received <= all_zeros & received(0 to N_LENGTH - 2);
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Verify if received polynomial is a codeword
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or output_index = 0 then
        received_is_codeword <= '0';
      elsif syndrome_done = '1' then
        if syndrome_output(0) = all_zeros
          and syndrome_output(1) = all_zeros
          and syndrome_output(2) = all_zeros
          and syndrome_output(3) = all_zeros
          and syndrome_output(4) = all_zeros
          and syndrome_output(5) = all_zeros
          and syndrome_output(6) = all_zeros
          and syndrome_output(7) = all_zeros
          and syndrome_output(8) = all_zeros
          and syndrome_output(9) = all_zeros
          and syndrome_output(10) = all_zeros
          and syndrome_output(11) = all_zeros
          and syndrome_output(12) = all_zeros
          and syndrome_output(13) = all_zeros
          and syndrome_output(14) = all_zeros
          and syndrome_output(15) = all_zeros then
          received_is_codeword <= '1';
        else
          received_is_codeword <= '0';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Enable polynomials determination based on syndrome's result
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or syndrome_done = '0' then
        enable_bm <= '0';
      elsif syndrome_done = '1' and cf_done = '0' then
        if (syndrome_output(0) /= all_zeros
            or syndrome_output(1) /= all_zeros
            or syndrome_output(2) /= all_zeros
            or syndrome_output(3) /= all_zeros
            or syndrome_output(4) /= all_zeros
            or syndrome_output(5) /= all_zeros
            or syndrome_output(6) /= all_zeros
            or syndrome_output(7) /= all_zeros
            or syndrome_output(8) /= all_zeros
            or syndrome_output(9) /= all_zeros
            or syndrome_output(10) /= all_zeros
            or syndrome_output(11) /= all_zeros
            or syndrome_output(12) /= all_zeros
            or syndrome_output(13) /= all_zeros
            or syndrome_output(14) /= all_zeros
            or syndrome_output(15) /= all_zeros)
          and erasures_count < T2 then
          enable_bm <= '1';
        else
          enable_bm <= '0';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Count symbols output when there are no errors
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or output_index = 0 then
        output_index <= to_unsigned(N_LENGTH - 1, SYMBOL_LENGTH);
      elsif received_is_codeword = '1' then
        if output_index > 0 then
          output_index <= output_index - 1;
        else
          output_index <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Verify if estimated codeword is in fact a codeword
  -----------------------------------------------------------------------------
  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or cf_done = '0' then
        fail <= '0';
      elsif syndrome_done = '1' and cf_done = '1' then
        if (cf_done = '1'
            and syndrome_output(0) /= all_zeros
            and syndrome_output(1) /= all_zeros
            and syndrome_output(2) /= all_zeros
            and syndrome_output(3) /= all_zeros
            and syndrome_output(4) /= all_zeros
            and syndrome_output(5) /= all_zeros
            and syndrome_output(6) /= all_zeros
            and syndrome_output(7) /= all_zeros
            and syndrome_output(8) /= all_zeros
            and syndrome_output(9) /= all_zeros
            and syndrome_output(10) /= all_zeros
            and syndrome_output(11) /= all_zeros
            and syndrome_output(12) /= all_zeros
            and syndrome_output(13) /= all_zeros
            and syndrome_output(14) /= all_zeros
            and syndrome_output(15) /= all_zeros)
          or (erasure_done = '1' and erasures_count >= T2) then
          fail <= '1';
        else
          fail <= '0';
        end if;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- Output estimated codeword symbols serially
  -----------------------------------------------------------------------------
  data_out <= received(N_LENGTH - 1) when received_is_codeword = '1' or (cf_root = '0' and cf_processing = '1') else
              received(N_LENGTH - 1) xor cf_magnitude when cf_root = '1' and cf_processing = '1' else
              (others => '0');

  -----------------------------------------------------------------------------
  -- Set done signal
  -----------------------------------------------------------------------------
  done <= '1' when output_index = 0 or cf_done = '1' else
          '0';
  
end architecture;
