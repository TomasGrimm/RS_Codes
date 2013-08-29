library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

use work.ReedSolomon.all;

entity Euclidean_tb is
end Euclidean_tb;

architecture Euclidean_tb of Euclidean_tb is
  component Euclidean
    port (
      clock    : in std_logic;
      reset    : in std_logic;
      enable   : in std_logic;
      syndrome : in T2less1_array;

      --error    : out std_logic;
      done            : out std_logic;
      error_locator   : out T_array;
      error_evaluator : out T2less1_array);
  end component;

  signal clk : std_logic;
  signal rst : std_logic;
  signal ena : std_logic;
  signal syn : T2less1_array;
  signal dne : std_logic;
  signal erl : T_array;
  signal ere : T2less1_array;

  file fd_in : text open read_mode is "../../Tests/syndrome_golden.txt";
--  file fd_out : text open write_mode is "../../Tests/_vhdl.txt";
  
begin
  euclids : Euclidean
    port map (
      clock           => clk,
      reset           => rst,
      enable          => ena,
      syndrome        => syn,
      done            => dne,
      error_locator   => erl,
      error_evaluator => ere);

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
    wait for 10 ns;
    ena <= '0';
    wait;
  end process;

  process
    variable line_num : line;
    variable value : field_element;
  begin
    syn <= (others => (others => '0'));
            
    wait until clk'event and clk = '1' and ena = '1' and rst = '0';

    for i in 0 to T2 - 1 loop
      readline(fd_in, line_num);
      read(line_num, value);
      syn(i) <= value;
    end loop;

    wait;
  end process;
end Euclidean_tb;
