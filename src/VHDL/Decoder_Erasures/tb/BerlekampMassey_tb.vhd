library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

use work.ReedSolomon.all;

entity BerlekampMassey_tb is
end entity;

architecture BerlekampMassey_tb of BerlekampMassey_tb is
  component BerlekampMassey is
    port (
      clock          : in std_logic;
      reset          : in std_logic;
      enable         : in std_logic;
      syndrome       : in T2less1_array;
      erasures       : in T2less1_array;
      erasures_count : in unsigned(T downto 0);

      done            : out std_logic;
      error_locator   : out T2less1_array);
  end component;

  signal clk   : std_logic;
  signal rst   : std_logic;
  signal ena   : std_logic;
  signal dne   : std_logic;
  signal syn   : T2less1_array;
  signal eras  : T2less1_array;
  signal count : unsigned(T downto 0);
  signal elp   : T2less1_array;

  file syn_in : text open read_mode is "../../Tests/syndrome_golden.txt";
  file eras_in : text open read_mode is "../../Tests/erasures_golden.txt";
  
begin
  BM : BerlekampMassey
    port map (
      clock           => clk,
      reset           => rst,
      enable          => ena,
      syndrome        => syn,
      erasures        => eras,
      erasures_count  => count,
      done            => dne,
      error_locator   => elp);

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
    variable line_num : line;
    variable value    : field_element;
  begin
    syn <= (others => (others => '0'));

    wait until clk'event and clk = '1' and rst = '0';

    for i in 0 to T2 - 1 loop
      readline (syn_in, line_num);
      read (line_num, value);
      syn(i) <= value;
    end loop;

    wait;
  end process;

  process
    variable line_num : line;
    variable value    : field_element;
  begin
    count <= (others => '0');
    eras <= (others => (others => '0'));

    wait until clk'event and clk = '1' and rst = '0';

    count <= "000000101";
    
    for i in 0 to T2 - 1 loop
      readline (eras_in, line_num);
      read (line_num, value);
      eras(i) <= value;
    end loop;

    wait;
  end process;
end architecture;
