library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.ReedSolomon.all;

entity Omega_tb is
end Omega_tb;

architecture Omega_tb of Omega_tb is
  component Omega is
    port (
      clock         : in std_logic;
      reset         : in std_logic;
      enable        : in std_logic;
      syndrome      : in T2less1_array;
      error_locator : in T2_array;

      done            : out std_logic;
      error_evaluator : out T2less1_array);
  end component;

  signal clk : std_logic;
  signal rst : std_logic;
  signal ena : std_logic;
  signal dne : std_logic;
  signal syn : T2less1_array;
  signal elp : T2_array;
  signal eep : T2less1_array;

  file syn_in     : text open read_mode is "../../Tests/syndrome_golden.txt";
  file err_loc_in : text open read_mode is "../../Tests/locator_golden.txt";

begin
  eval_gen : Omega
    port map (
      clock           => clk,
      reset           => rst,
      enable          => ena,
      syndrome        => syn,
      error_locator   => elp,
      done            => dne,
      error_evaluator => eep);

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
    wait for 20 ns;
    ena <= '1';
    wait for 10 ns;
    ena <= '0';
    wait;
  end process;

  process
    variable line1, line2   : line;
    variable value1, value2 : field_element;
  begin
    syn <= (others => (others => '0'));
    elp <= (others => (others => '0'));

    wait until clk'event and clk = '1' and rst = '0';

    for i in 0 to T2 - 1 loop
      readline (syn_in, line1);
      read (line1, value1);
      syn(i) <= value1;
    end loop;

    for i in 0 to T2 loop
      readline (err_loc_in, line2);
      read (line2, value2);
      elp(i) <= value2;
    end loop;

    wait;
  end process;
end Omega_tb;

