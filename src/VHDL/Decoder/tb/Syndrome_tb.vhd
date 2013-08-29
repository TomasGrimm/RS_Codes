library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.ReedSolomon.all;

entity Syndrome_tb is
end entity;

architecture Syndrome_tb of Syndrome_tb is
  component Syndrome is
    port (
      clock           : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;
      received_vector : in field_element;

      done     : out std_logic;
      syndrome : out T2less1_array);
  end component;

  signal clk   : std_logic;
  signal rst   : std_logic;
  signal ena   : std_logic;
  signal dne   : std_logic;
  signal rcv   : field_element;
  signal sdm   : T2less1_array;

  file fd_in  : text open read_mode is "../../Tests/received.txt";
  file fd_out : text open write_mode is "../../Tests/syndrome_vhdl.txt";
  
begin
  synd : Syndrome
    port map (
      clock           => clk,
      reset           => rst,
      enable          => ena,
      received_vector => rcv,
      done            => dne,
      syndrome        => sdm);

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
    rcv <= (others => '0');
    ena <= '0';
    wait until clk'event and clk = '1' and rst = '0';
    wait for 10 ns;
    ena <= '1';
    wait for 10 ns;
    ena <= '0';
    
    while not endfile(fd_in) loop
      readline (fd_in, line_num);
      read (line_num, value);
      rcv <= value;
      wait until clk = '1';
    end loop;
    
    wait;
  end process;

  process
    variable line_num : line;
  begin
    wait until dne = '1';
    write(line_num, sdm(0));
    writeline(fd_out, line_num);
    write(line_num, sdm(1));
    writeline(fd_out, line_num);
    write(line_num, sdm(2));
    writeline(fd_out, line_num);
    write(line_num, sdm(3));
    writeline(fd_out, line_num);
    write(line_num, sdm(4));
    writeline(fd_out, line_num);
    write(line_num, sdm(5));
    writeline(fd_out, line_num);
    write(line_num, sdm(6));
    writeline(fd_out, line_num);
    write(line_num, sdm(7));
    writeline(fd_out, line_num);
    write(line_num, sdm(8));
    writeline(fd_out, line_num);
    write(line_num, sdm(9));
    writeline(fd_out, line_num);
    write(line_num, sdm(10));
    writeline(fd_out, line_num);
    write(line_num, sdm(11));
    writeline(fd_out, line_num);
    write(line_num, sdm(12));
    writeline(fd_out, line_num);
    write(line_num, sdm(13));
    writeline(fd_out, line_num);
    write(line_num, sdm(14));
    writeline(fd_out, line_num);
    write(line_num, sdm(15));
    writeline(fd_out, line_num);
  end process;

end architecture;
