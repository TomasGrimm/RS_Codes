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
      clock          : in  std_logic;
      reset          : in  std_logic;
      enable         : in  std_logic;
      erase          : in  std_logic;
      done           : out std_logic;
      erasures       : out T2_array;
      erasures_count : out unsigned(T downto 0));
  end component;

  signal clk               : std_logic;
  signal rst               : std_logic;
  signal str               : std_logic;
  signal era               : std_logic;
  signal dne               : std_logic;
  signal ers               : T2_array;
  signal cnt               : unsigned(T downto 0);
  signal not_another_alpha : field_element;
  signal counter           : integer;

begin  -- Erasure_tb
  erasurer : Erasure
    port map (
      clock          => clk,
      reset          => rst,
      enable         => str,
      erase          => era,
      done           => dne,
      erasures       => ers,
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

    counter <= 255;

    wait until str = '1';
    wait until str = '0';

    while counter > 0 loop
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
        or counter = 40
      then
        era <= '1';
      end if;

      wait until clk = '1';
      
    end loop;

    wait;
  end process;
end Erasure_tb;
