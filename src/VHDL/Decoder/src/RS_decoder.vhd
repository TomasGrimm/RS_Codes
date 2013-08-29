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

      done               : out std_logic;
      estimated_codeword : out codeword_array);
  end component;

  signal syndrome_done : std_logic;
  signal bm_done       : std_logic;
  signal cf_done       : std_logic;

  signal decoding_done                : std_logic;
  signal estimated_codeword_shift_out : std_logic;
  signal received_is_codeword         : std_logic;

  signal syndrome_output : syndrome_vector;
  signal bm_output       : key_equation;
  signal cf_output       : codeword_array;
  signal received        : codeword_array;

  signal syndrome_reg : syndrome_vector;
  signal bm_reg       : key_equation;
  signal cf_reg       : codeword_array;

  signal received_index : integer := N_LENGTH - 1;
  signal output_index   : integer := N_LENGTH - 1;
  
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
      clock              => clock,
      reset              => reset,
      enable             => bm_done,
      syndrome           => syndrome_reg,
      error_locator      => bm_reg,
      done               => cf_done,
      estimated_codeword => cf_output);

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' or decoding_done = '1' then
        syndrome_reg                 <= (others => (others => '0'));
        bm_reg                       <= (others => (others => '0'));
        cf_reg                       <= (others => (others => '0'));
        estimated_codeword_shift_out <= '0';
      elsif syndrome_done = '1' then
        syndrome_reg <= syndrome_output;
      elsif bm_done = '1' then
        bm_reg <= bm_output;
      elsif cf_done = '1' then
        cf_reg                       <= cf_output;
        estimated_codeword_shift_out <= '1';
      end if;
    end if;
  end process;

--  syndrome_reg <= (others => (others => '0')) when reset = '1' or decoding_done = '1' else syndrome_output when syndrome_done = '1';
--  bm_reg <= (others => (others => '0')) when reset = '1' or decoding_done = '1' else bm_output when bm_done = '1';
--  cf_reg <= (others => (others => '0')) when reset = '1' or decoding_done = '1' else cf_output when cf_done = '1';
--  estimated_codeword_shift_out <= '0' when reset = '1' or decoding_done = '1' else '1' when cf_done = '1' and CLOCK_50 = '1';
  
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
        output_index  <= N_LENGTH - 1;
        data_out      <= (others => '0');
        decoding_done <= '0';
        done          <= '0';
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

        if estimated_codeword_shift_out = '1' then
          if output_index >= 0 then
            data_out     <= cf_reg(output_index) xor received(output_index);
            output_index <= output_index - 1;
          else
            decoding_done <= '1';
            done          <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
  
end architecture;
