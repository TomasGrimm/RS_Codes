library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.ReedSolomon.all;

entity Chien_Forney_tb is
end entity;

architecture Chien_Forney_tb of Chien_Forney_tb is
  component Chien_Forney is
    port (
      clock           : in std_logic;   -- clock signal
      reset           : in std_logic;   -- reset signal
      enable          : in std_logic;  -- enables this unit when the key equation is ready
      error_locator   : in T_array;
      error_evaluator : in T2less1_array;

      done            : out std_logic;  -- signals when the search is done
      is_root         : out std_logic;
      processing      : out std_logic;
      error_index     : out unsigned(T - 1 downto 0);
      error_magnitude : out field_element);
  end component;

  signal clk     : std_logic;
  signal rst     : std_logic;
  signal ena     : std_logic;
  signal erl     : T_array;
  signal eep     : T2less1_array;

  signal dne     : std_logic;
  signal root    : std_logic;
  signal working : std_logic;
  signal index   : unsigned(T - 1 downto 0);
  signal err_mag : field_element;

  file fd_loc_in : text open read_mode is "../../Tests/locator_golden.txt";
  file fd_eva_in : text open read_mode is "../../Tests/evaluator_golden.txt";
--  file fd_out       : text open write_mode is "./files/chien_vhdl.txt";
  
begin
  CF : Chien_Forney
    port map (
      clock           => clk,
      reset           => rst,
      enable          => ena,
      error_locator   => erl,
      error_evaluator => eep,
      done            => dne,
      is_root         => root,
      processing      => working,
      error_index     => index,
      error_magnitude => err_mag);

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
    variable line1, line2 : line;
    variable value        : field_element;
  begin
    ena <= '0';
    erl <= (others => (others => '0'));
    eep <= (others => (others => '0'));
    wait for 20 ns;
    ena    <= '1';

    -- error locator polynomial (Berlekamp output)
    for i in 0 to T loop
      readline (fd_loc_in, line1);
      read (line1, value);
      erl(i) <= value;
    end loop;  -- i

    -- error evaluator polynomail (Berlekamp output
    for i in 0 to T2 - 1 loop
      readline (fd_eva_in, line2);
      read (line2, value);
      eep(i) <= value;
    end loop;  -- i
    
    wait for 10 ns;
    ena <= '0';

    wait;
  end process;
end architecture;
