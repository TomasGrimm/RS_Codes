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
      --error    : out std_logic;
      done        : out std_logic;
      data_out    : out field_element);
  end component;

  signal clk      : std_logic;
  signal rst      : std_logic;
  signal srt_blk  : std_logic;
  signal era      : std_logic;
  signal dne      : std_logic;
  signal din, dot : field_element;

  signal cf_processing   : std_logic;
  signal output_codeword : std_logic;

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
      --error => ,
      done        => dne,
      data_out    => dot);

  process
  begin
    init_signal_spy("/RS_decoder_tb/decoder/cf_processing", "/RS_decoder_tb/cf_processing", 1, 1);
    init_signal_spy("/RS_decoder_tb/decoder/output_codeword", "/RS_decoder_tb/output_codeword", 1, 1);
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
    era     <= '0';
    din     <= (others => '0');

    wait until srt_blk = '1';
    
    while not endfile(fd_in) loop
      readline (fd_in, line_num);
      read (line_num, value);
      din <= value;

      era <= '0';

      if din = "11110100" then
        era <= '1';
      elsif din = "00011000" then
        era <= '1';
      elsif din = "11010111" then
        era <= '1';
      elsif din = "10010011" then
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
    wait until cf_processing = '1' or output_codeword = '1';

    while counter < N_LENGTH + 1 loop
      write(line_num, dot);
      writeline(fd_out, line_num);
      counter := counter + 1;
      wait until clk = '1';
    end loop;
  end process;
end architecture;
