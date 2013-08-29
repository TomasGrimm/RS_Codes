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

      done     : out std_logic;
      equation : out key_equation);
  end component;

  component Chien_Forney is
    port (
      clock         : in std_logic;
      reset         : in std_logic;
      enable        : in std_logic;
      syndrome      : in syndrome_vector;
      error_locator : in key_equation;

      done              : out std_logic;
      errors_magnitudes : out errors_values;
      errors_indices    : out errors_locations);
  end component;

  signal syndrome_done        : std_logic;
  signal bm_done              : std_logic;
  signal cf_done              : std_logic;
  signal decoding_done        : std_logic;
  signal correct_received     : std_logic;
  signal received_is_codeword : std_logic;

  signal syndrome_output : syndrome_vector;
  signal syndrome_reg    : syndrome_vector;

  signal bm_output : key_equation;
  signal bm_reg    : key_equation;

  signal cf_magnitudes : errors_values;
  signal cf_mags_reg   : errors_values;
  signal cf_indices    : errors_locations;
  signal cf_inds_reg   : errors_locations;

  signal received : codeword_array;

  signal errors_counter : integer;
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
      clock    => clock,
      reset    => reset,
      enable   => syndrome_done,
      syndrome => syndrome_reg,
      done     => bm_done,
      equation => bm_output);

  cf_module : Chien_Forney
    port map (
      clock             => clock,
      reset             => reset,
      enable            => bm_done,
      syndrome          => syndrome_reg,
      error_locator     => bm_reg,
      done              => cf_done,
      errors_magnitudes => cf_magnitudes,
      errors_indices    => cf_indices);

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or decoding_done = '1' then
        syndrome_reg     <= (others => (others => '0'));
        bm_reg           <= (others => (others => '0'));
        cf_mags_reg      <= (others => (others => '0'));
        cf_inds_reg      <= (others => 0);
        correct_received <= '0';
      elsif syndrome_done = '1' then
        syndrome_reg <= syndrome_output;
      elsif bm_done = '1' then
        bm_reg <= bm_output;
      elsif cf_done = '1' then
        cf_mags_reg      <= cf_magnitudes;
        cf_inds_reg      <= cf_indices;
        correct_received <= '1';
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
        data_out       <= (others => '0');
        decoding_done  <= '0';
        done           <= '0';
        errors_counter <= 0;
      else
        if received_is_codeword = '1' then
          if output_index >= 0 then
            data_out     <= received(output_index);
            output_index <= output_index - 1;
          else
            decoding_done <= '1';
            done          <= '1';
          end if;
        end if;

        if correct_received = '1' then
          if output_index = cf_inds_reg(errors_counter) then
            data_out       <= cf_mags_reg(errors_counter) xor received(output_index);
            errors_counter <= errors_counter + 1;
          else
            data_out <= received(output_index);
          end if;

          if output_index > 0 then
            output_index <= output_index - 1;
          else
            output_index <= 0;
          end if;
        end if;

        if output_index = 0 then
          decoding_done <= '1';
          done          <= '1';
        end if;
      end if;
    end if;
  end process;
  
end architecture;
