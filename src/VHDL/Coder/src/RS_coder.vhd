library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity RS_coder is
  port (
    clock   : in std_logic;             -- clock signal
    reset   : in std_logic;  -- signal used to clear all registers and the ready signal
    start   : in std_logic;  -- indicates when a new message is ready to be encoded
    message : in field_element;         -- message to be encoded

    done     : out std_logic;           -- signals when the processing is done
    codeword : out field_element);  -- codeword containing the message and the calculated parity bits
end entity;

architecture RS_coder of RS_coder is
  component LFSR
    port (
      clock          : in  std_logic;
      reset          : in  std_logic;
      start          : in  std_logic;
      message        : in  field_element;
      codeword       : out field_element;
      parity_ready   : out std_logic;
      parity_shifted : out std_logic);
  end component LFSR;

  signal parity_out : field_element;  -- shifts out the parity bits, one by one
  signal delay      : field_element;

  signal par_ready   : std_logic;
  signal par_shifted : std_logic;
  
begin  -- RS
  encode : LFSR
    port map (
      clock          => clock,
      reset          => reset,
      start          => start,
      message        => message,
      codeword       => parity_out,
      parity_ready   => par_ready,
      parity_shifted => par_shifted);

  process(clock)
  begin
    if clock'event and clock = '1' then
      if reset = '1' then
        delay <= (others => '0');
      else
        delay <= message;
      end if;
    end if;
  end process;

  codeword <= delay when par_ready = '0' else
              parity_out;

  done <= '1' when par_shifted = '1' else
          '0';
  
end architecture;
