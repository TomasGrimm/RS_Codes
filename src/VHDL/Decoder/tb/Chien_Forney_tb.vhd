library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.ReedSolomon.all;

entity Chien_Forney_tb is
end entity;

architecture Chien_Forney_tb of Chien_Forney_tb is
  component Chien_Forney is
    port (
      clock           : in std_logic;
      reset           : in std_logic;
      enable          : in std_logic;
      error_locator   : in key_equation;
      error_evaluator : in omega_array;

      done            : out std_logic;
      is_root         : out std_logic;
      error_magnitude : out field_element);
  end component;

  signal clk, rst, ena, dne, root : std_logic;
  signal erl                      : key_equation;
  signal eep                      : omega_array;
  signal err_mag                  : field_element;

  file fd_bm_loc_in : text open read_mode is "./comparison/bm_locator.txt";
  file fd_bm_eva_in : text open read_mode is "./comparison/bm_evaluator.txt";
  file fd_out       : text open write_mode is "./comparison/chien_vhdl.txt";
  
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
    variable line1, line2, line3 : line;
    variable value               : field_element;
  begin
    ena <= '0';
    erl <= (others => (others => '0'));
    eep <= (others => (others => '0'));
    wait for 20 ns;

    ena    <= '1';
    -- error locator polynomial (Berlekamp output)
    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(0) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(1) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(2) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(3) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(4) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(5) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(6) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(7) <= value;

    readline (fd_bm_loc_in, line2);
    read (line2, value);
    erl(8) <= value;

    -- error evaluator polynomail (Berlekamp output
    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(0) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(1) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(2) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(3) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(4) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(5) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(6) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(7) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(8) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(9) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(10) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(11) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(12) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(13) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(14) <= value;

    readline (fd_bm_eva_in, line3);
    read (line3, value);
    eep(15) <= value;

    wait for 10 ns;
    ena <= '0';
    wait;
  end process;

  --process
  --  variable line_num : line;
  --  variable counter  : integer := 0;
  --begin
  --  wait until dne = '1';

  --  while counter < N_LENGTH loop
  --    write(line_num, est(counter));
  --    writeline(fd_out, line_num);
  --    counter := counter + 1;
  --  end loop;
  --end process;
end architecture;
