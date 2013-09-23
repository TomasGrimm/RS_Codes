library IEEE;
library modelsim_lib;
use modelsim_lib.util.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.ReedSolomon.all;

entity RS_decoder_tb is
end entity;

architecture RS_decoder_tb of RS_decoder_tb is
  component RS_decoder is
    port (
      clock       : in  std_logic;
      reset       : in  std_logic;
      start_block : in  std_logic;
      erase       : in  std_logic;
      data_in     : in  field_element;
      fail        : out std_logic;
      done        : out std_logic;
      data_out    : out field_element);
  end component;

  signal clk      : std_logic;
  signal rst      : std_logic;
  signal srt_blk  : std_logic;
  signal era      : std_logic;
  signal fl       : std_logic;
  signal dne      : std_logic;
  signal din, dot : field_element;

  signal counter : integer;

  signal cf_processing   : std_logic;
  signal received_is_codeword : std_logic;

  file fd_in  : text open read_mode is "../../Tests/received.txt";
  file fd_out : text open write_mode is "../../Tests/estimated_vhdl.txt";
  
begin
  decoder : RS_decoder
    port map (
      clock       => clk,
      reset       => rst,
      start_block => srt_blk,
      erase       => era,
      data_in     => din,
      fail        => fl,
      done        => dne,
      data_out    => dot);

  process
  begin
    init_signal_spy("/RS_decoder_tb/decoder/cf_processing", "/RS_decoder_tb/cf_processing", 1, 1);
    init_signal_spy("/RS_decoder_tb/decoder/received_is_codeword", "/RS_decoder_tb/received_is_codeword", 1, 1);
    wait;
  end process;

  process
  begin
    clk <= '1';
    wait for 5 ns;
    clk <= '0';
    wait for 5 ns;
  end process;

  process
  begin
    rst <= '1';
    wait for 10 ns;
    rst <= '0';
    wait;
  end process;

  process
    variable line_num : line;
    variable value    : field_element;
  begin
    era <= '0';
    din <= (others => '0');

    counter <= 255;

    wait until srt_blk = '1';
    wait until srt_blk = '0';

    while not endfile(fd_in) loop
      readline (fd_in, line_num);
      read (line_num, value);
      din <= value;

      counter <= counter - 1;
      
      era <= '0';

      if counter = 241
        or counter = 221
        or counter = 61
        or counter = 41
        or counter = 21
        or counter = 22
        or counter = 23
        or counter = 24
        or counter = 25
        or counter = 26
        or counter = 27
        or counter = 28
        or counter = 29
        or counter = 20
        or counter = 30
--        or counter = 40
      then
        era <= '1';
      end if;

      wait until clk = '1';
    end loop;

    wait;
  end process;

  process
  begin
    srt_blk <= '0';
    wait for 20 ns;
    srt_blk <= '1';
    wait for 10 ns;
    srt_blk <= '0';
    wait;
  end process;

  process
    variable line_num : line;
    variable counter  : integer := 0;
  begin
    wait until cf_processing = '1' or received_is_codeword = '1';

    while counter < N_LENGTH + 1 loop
      write(line_num, dot);
      writeline(fd_out, line_num);
      counter := counter + 1;
      wait until clk = '1';
    end loop;
  end process;
end architecture;
