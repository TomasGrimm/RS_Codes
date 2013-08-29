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
      clock   : in std_logic;
      reset   : in std_logic;
      enable  : in std_logic;
      data_in : in field_element;

      --        error    : out std_logic;
      done     : out std_logic;
      data_out : out field_element);
  end component;

  signal clk, rst, ena, dne : std_logic;
  signal din, dot           : field_element;

  signal cf_internal : std_logic;

  file fd_in : text open read_mode is "./comparison/received.txt";
  file fd_out : text open write_mode is "./comparison/estimated_vhdl.txt";
  
begin
  decoder : RS_decoder
    port map (
      clock    => clk,
      reset    => rst,
      enable   => ena,
      data_in  => din,
      done     => dne,
      data_out => dot);

  process
  begin
    init_signal_spy("/RS_decoder_tb/decoder/cf_done", "/RS_decoder_tb/cf_internal", 1, 1);
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
    variable value : field_element;
  begin
    ena <= '0';
    wait for 10 ns;
    ena <= '1';

    while not endfile(fd_in) loop
      readline (fd_in, line_num);
      read (line_num, value);
      din <= value;
      wait until clk = '1';
    end loop;
    
    wait for 10 ns;
    ena <= '0';
    wait;
  end process;

  process
    variable line_num : line;
    variable counter : integer := 0;
  begin
    wait until cf_internal = '1';

    while counter < N_LENGTH loop
      write(line_num, dot);
      writeline(fd_out, line_num);
      counter := counter + 1;
      wait until clk = '1';
    end loop;
  end process;
end architecture;
