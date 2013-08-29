library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

use work.ReedSolomon.all;

entity RS_coder_tb is
end entity;

architecture RS_coder_tb of RS_coder_tb is
  component RS_coder is
    port (
      clock    : in  std_logic;
      reset    : in  std_logic;
      start    : in  std_logic;
      message  : in  field_element;
      done     : out std_logic;
      codeword : out field_element);
  end component;

  signal clk  : std_logic;
  signal rst  : std_logic;
  signal str  : std_logic;
  signal din  : field_element := last_element;
  signal dne  : std_logic;
  signal dout : field_element;

  file fd_in : text open read_mode is "../../Tests/message.txt";
  file fd_out : text open write_mode is "../../Tests/codeword_vhdl.txt";
begin
  coder : RS_coder
    port map (
      clock    => clk,
      reset    => rst,
      start    => str,
      message  => din,
      done     => dne,
      codeword => dout);

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
    str <= '0';
    wait for 20 ns;
    rst <= '0';
    str <= '1';
    wait for 10 ns;
    str <= '0';
    wait;
  end process;

  process
    variable line_num : line;
    variable value : field_element;
  begin
    wait until clk'event and clk = '1' and str = '0' and rst = '0';
    while not endfile(fd_in) loop
      readline (fd_in, line_num);
      read (line_num, value);
      din <= value;
      wait until clk = '1';
    end loop;
  end process;

  process
    variable line_num : line;
  begin
    wait until clk'event and clk = '1' and str = '0' and rst = '0';
    write(line_num, dout);
    writeline(fd_out, line_num);
  end process;
end architecture;
