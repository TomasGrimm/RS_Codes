library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity Chien_Forney is
  port (
    clock           : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;
    error_locator   : in T_array;
    error_evaluator : in Tless1_array;

    done            : out std_logic;
    is_root         : out std_logic;
    processing      : out std_logic;
    error_magnitude : out field_element);
end entity;
