#include <fstream>

void Write_Encoder()
{
  std::fstream fd;

  fd.open("RS_Encoder.vhd", std::fstream::out);

  fd << "library IEEE;\n"
        "use IEEE.std_logic_1164.all;\n"
        "use work.ReedSolomon.all;\n"
        "\n"
        "entity RS_coder is\n"
        "  port (\n"
        "    clock         : in  std_logic;\n"
        "    reset         : in  std_logic;\n"
        "    message_start : in  std_logic;\n"
        "    message       : in  field_element;\n"
        "    done          : out std_logic;\n"
        "    codeword      : out field_element);\n"
        "end entity;\n"
        "\n"
        "architecture RS_coder of RS_coder is\n"
        "  component LFSR\n"
        "    port (\n"
        "      clock          : in  std_logic;\n"
        "      reset          : in  std_logic;\n"
        "      message_start  : in  std_logic;\n"
        "      message        : in  field_element;\n"
        "      codeword       : out field_element;\n"
        "      parity_ready   : out std_logic;\n"
        "      parity_shifted : out std_logic);\n"
        "  end component LFSR;\n"
        "\n"
        "  signal parity_out : field_element;\n"
        "  signal delay      : field_element;\n"
        "\n"
        "  signal par_ready : std_logic;\n"
        "\n"
        "begin\n"
        "  encode : LFSR\n"
        "    port map (\n"
        "      clock          => clock,\n"
        "      reset          => reset,\n"
        "      message_start  => message_start,\n"
        "      message        => message,\n"
        "      codeword       => parity_out,\n"
        "      parity_ready   => par_ready,\n"
        "      parity_shifted => done);\n"
        "\n"
        "  process(clock)\n"
        "  begin\n"
        "    if clock'event and clock = '1' then\n"
        "      if reset = '1' then\n"
        "        delay <= (others => '0');\n"
        "      else\n"
        "        delay <= message;\n"
        "      end if;\n"
        "    end if;\n"
        "  end process;\n"
        "\n"
        "  codeword <= delay when par_ready = '0' else\n"
        "              parity_out;\n"
        "\n"
        "end architecture;\n";

  fd.close();
}

