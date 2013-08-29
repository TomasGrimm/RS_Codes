library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

use work.ReedSolomon.all;

entity BerlekampMassey_tb is
end entity;

architecture BerlekampMassey_tb of BerlekampMassey_tb is
  component BerlekampMassey is
    port (
      clock    : in std_logic;
      reset    : in std_logic;
      enable   : in std_logic;
      syndrome : in syndrome_vector;

      done     : out std_logic;
      equation : out key_equation);
  end component;

  signal clk, rst, ena, dne : std_logic;
  signal syn                : syndrome_vector;
  signal equ                : key_equation;

  file fd_in : text open read_mode is "./comparison/syndrome_golden.txt";
  file fd_out : text open write_mode is "./comparison/bm_vhdl.txt";
begin
  BM : BerlekampMassey
    port map (
      clock    => clk,
      reset    => rst,
      enable   => ena,
      syndrome => syn,
      done     => dne,
      equation => equ);

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
    ena <= '0';
    wait for 20 ns;
    rst <= '0';
    ena <= '1';
    wait for 40 ns;
    ena <= '0';
    wait;
  end process;

  process
    variable line_num : line;
    variable value : field_element;
  begin
    wait until clk'event and clk = '1' and ena = '1' and rst = '0';
    readline (fd_in, line_num);
    read (line_num, value);
    syn(0) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(1) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(2) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(3) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(4) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(5) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(6) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(7) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(8) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(9) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(10) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(11) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(12) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(13) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(14) <= value;

    readline (fd_in, line_num);
    read (line_num, value);
    syn(15) <= value;
    wait;
  end process;

  process
    variable line_num : line;
  begin
    wait until clk'event and clk = '1' and ena = '0' and rst = '0' and dne = '1';
    write(line_num, equ(0));
    writeline(fd_out, line_num);

    write(line_num, equ(1));
    writeline(fd_out, line_num);

    write(line_num, equ(2));
    writeline(fd_out, line_num);

    write(line_num, equ(3));
    writeline(fd_out, line_num);

    write(line_num, equ(4));
    writeline(fd_out, line_num);

    write(line_num, equ(5));
    writeline(fd_out, line_num);

    write(line_num, equ(6));
    writeline(fd_out, line_num);

    write(line_num, equ(7));
    writeline(fd_out, line_num);

    write(line_num, equ(8));
    writeline(fd_out, line_num);
  end process;
end architecture;
