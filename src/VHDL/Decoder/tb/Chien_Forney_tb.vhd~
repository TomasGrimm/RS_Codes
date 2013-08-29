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
      clock         : in std_logic;
      reset         : in std_logic;
      enable        : in std_logic;
      syndrome      : in syndrome_vector;
      error_locator : in key_equation;

      done               : out std_logic;
      estimated_codeword : out codeword_array);
  end component;

  signal clk, rst, ena, dne : std_logic;
  signal syn                : syndrome_vector;
  signal erl                : key_equation;
  signal est                : codeword_array;

  file fd_syn_in : text open read_mode is "../../Tests/syndrome_vhdl.txt";
  file fd_bm_in : text open read_mode is "../../Tests/bm_vhdl.txt";
  file fd_out : text open write_mode is "../../Tests/chien_vhdl.txt";
  
begin
  CF : Chien_Forney
    port map (
      clock              => clk,
      reset              => rst,
      enable             => ena,
      syndrome           => syn,
      error_locator      => erl,
      done               => dne,
      estimated_codeword => est);

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
    variable value : field_element;
  begin
    ena <= '0';
    syn <= (others => (others => '0'));
    erl <= (others => (others => '0'));
    wait for 20 ns;

    ena    <= '1';
    -- syndrome
    readline (fd_syn_in, line1);
    read (line1, value);
    syn(0) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(1) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(2) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(3) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(4) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(5) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(6) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(7) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(8) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(9) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(10) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(11) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(12) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(13) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(14) <= value;

    readline (fd_syn_in, line1);
    read (line1, value);
    syn(15) <= value;
    
    -- error locator polynomial (Berlekamp output)
    readline (fd_bm_in, line2);
    read (line2, value);
    erl(0) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(1) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(2) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(3) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(4) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(5) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(6) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(7) <= value;

    readline (fd_bm_in, line2);
    read (line2, value);
    erl(8) <= value;

    wait for 10 ns;
    ena <= '0';
    wait;
  end process;

  process
    variable line_num : line;
    variable counter : integer := 0;
  begin
    wait until dne = '1';

    while counter < N_LENGTH loop
      write(line_num, est(counter));
      writeline(fd_out, line_num);
      counter := counter + 1;
    end loop;
  end process;
end architecture;
