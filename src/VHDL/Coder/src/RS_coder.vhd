library IEEE;
use IEEE.std_logic_1164.all;
use work.ReedSolomon.all;

entity RS_coder is
  port (
    CLOCK_50 : in std_logic;             -- clock signal
    SW       : in std_logic_vector(17 downto 0);
	 LEDR     : out std_logic_vector(17 downto 0));
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
      clock          => CLOCK_50,
      reset          => SW(0),
      start          => SW(1),
      message        => SW(9 downto 2),
      codeword       => parity_out,
      parity_ready   => par_ready,
      parity_shifted => par_shifted);

  process(CLOCK_50, SW(0))
  begin
    if CLOCK_50'event and CLOCK_50 = '1' then
      if SW(0) = '1' then
        delay <= (others => '0');
      else
        delay <= SW(9 downto 2);
      end if;
    end if;
  end process;

  LEDR(7 downto 0) <= delay when par_ready = '0' else
              parity_out;

  LEDR(17) <= '1' when par_shifted = '1' else
          '0';
  
end architecture;
