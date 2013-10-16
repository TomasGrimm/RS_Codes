library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity KES is
  port (
    clock    : in std_logic;
    reset    : in std_logic;
    enable   : in std_logic;
    syndrome : in T2less1_array;

    done            : out std_logic;
    error_locator   : out T_array;
    error_evaluator : out Tless1_array);
end entity;
