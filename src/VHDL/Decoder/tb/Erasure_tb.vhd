library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library modelsim_lib;
use modelsim_lib.util.all;

use work.ReedSolomon.all;

entity Erasure_tb is
end Erasure_tb;

architecture Erasure_tb of Erasure_tb is
  component Erasure is
    port (
      clock         : in  std_logic;
      reset         : in  std_logic;
      start_block   : in  std_logic;
      erase         : in  std_logic;
      done          : out std_logic;
      erasures      : out T2less1_array;
      erasures_count : out unsigned(T downto 0));
  end component;

  signal clk               : std_logic;
  signal rst               : std_logic;
  signal str               : std_logic;
  signal era               : std_logic;
  signal dne               : std_logic;
  signal ers               : T2less1_array;
  signal cnt               : unsigned(T downto 0);
  signal not_another_alpha : field_element;

begin  -- Erasure_tb
  erasurer : Erasure
    port map (
      clock         => clk,
      reset         => rst,
      start_block   => str,
      erase         => era,
      done          => dne,
      erasures      => ers,
      erasures_count => cnt);

  process
  begin
    init_signal_spy("/Erasure_tb/erasurer/alpha", "/Erasure_tb/not_another_alpha", 1, 1);
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
  begin
    str <= '0';

    wait until clk = '1' and rst = '0';

    wait for 20 ns;
    str <= '1';

    wait for 10 ns;
    str <= '0';

    wait;
  end process;

  process
  begin
    era <= '0';

    if not_another_alpha = "11110101" then
      era <= '1';
    elsif not_another_alpha = "00011001" then
      era <= '1';
    elsif not_another_alpha = "11010110" then
      era <= '1';
    elsif not_another_alpha = "10010100" then
      era <= '1';
    end if;

    wait for 10 ns;
  end process;
end Erasure_tb;
