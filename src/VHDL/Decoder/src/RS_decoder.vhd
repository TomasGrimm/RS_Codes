library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

-- Reed-Solomon (255, 239) Decoder
--
-- Each code symbol has 8 bits.
-- The received vector is decoded following these steps:
--      1. Syndrome calculation
--      2. Inversionless Berlekamp-Massey for the Error Location Polynomial
--      3. Chien's search to determine the Error Location Polynomial's roots
--      4. Forney's algorithm to evaluate the error's values

entity RS_decoder is
  port (
    clock   : in std_logic;
    reset   : in std_logic;
    enable  : in std_logic;
    data_in : in field_element;

--  error    : out std_logic;
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
      no_error : out std_logic;
      syndrome : out syndrome_vector);
  end component;

  component BerlekampMassey is
    port (
      clock    : in std_logic;
      reset    : in std_logic;
      enable   : in std_logic;
      syndrome : in syndrome_vector;

      done            : out std_logic;
      error_locator   : out key_equation;
      error_evaluator : out omega_array);
  end component;

  component Chien_Forney is
    port (
      clock           : in std_logic;   -- clock signal
      reset           : in std_logic;   -- reset signal
      enable          : in std_logic;  -- enables this unit when the key equation is ready
      error_locator   : in key_equation;
      error_evaluator : in omega_array;

      done            : out std_logic;  -- signals when the search is done
      is_root         : out std_logic;
      processing      : out std_logic;
      error_index     : out integer;
      error_magnitude : out field_element);
  end component;

  signal syndrome_done        : std_logic;
  signal bm_done              : std_logic;
  signal cf_done              : std_logic;
  signal cf_processing        : std_logic;
  signal cf_root              : std_logic;
  signal decoding_done        : std_logic;
  signal received_is_codeword : std_logic;

  signal syndrome_output : syndrome_vector;
  signal syndrome_reg    : syndrome_vector;

  signal bm_locator_output   : key_equation;
  signal bm_locator_reg      : key_equation;
  signal bm_evaluator_output : omega_array;
  signal bm_evaluator_reg    : omega_array;

  signal cf_magnitude : field_element;

  signal received : codeword_array;

  signal cf_index       : integer;
  signal output_index   : integer;
  signal received_index : integer;
  
begin
  syndrome_module : Syndrome
    port map (
      clock           => clock,
      reset           => reset,
      enable          => enable,
      received_vector => data_in,
      done            => syndrome_done,
      no_error        => received_is_codeword,
      syndrome        => syndrome_output);

  bm_module : BerlekampMassey
    port map (
      clock           => clock,
      reset           => reset,
      enable          => syndrome_done,
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

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        received       <= (others => (others => '0'));
        received_index <= N_LENGTH - 1;
      elsif enable = '1' then
        received(received_index) <= data_in;
        received_index           <= received_index - 1;
      end if;
    end if;
  end process;

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        output_index   <= N_LENGTH - 1;
        decoding_done  <= '0';
      else
        if received_is_codeword = '1' then
          if output_index >= 0 then
            output_index <= output_index - 1;
          else
            decoding_done <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  data_out <= received(output_index) when received_is_codeword = '1' else
              received(cf_index) xor cf_magnitude when cf_root = '1' and cf_processing = '1' else
              received(cf_index) when cf_processing = '1' else
              (others => '0');

  done <= '1' when decoding_done = '1' or cf_done = '1' else
          '0';
  
end architecture;
