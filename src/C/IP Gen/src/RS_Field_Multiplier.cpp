#include <fstream>

void Write_Multiplier(int primPoly)
{
  std::fstream fd;

  fd.open("RS_Field_Multiplier.vhd", std::fstream::out);

  fd << "library IEEE;\n"
        "use IEEE.std_logic_1164.all;\n"
        "use work.ReedSolomon.all;\n"
        "\n"
        "entity field_element_multiplier is\n"
        "  port (\n"
        "    u : in  field_element;\n"
        "    v : in  field_element;\n"
        "    w : out field_element);\n"
        "end entity;\n"
        "\n"
        "architecture field_element_multiplier of field_element_multiplier is\n"
        "  signal d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, d14 : std_logic;\n"
        "begin\n"
        "  d0  <= (u(0) and v(0));\n"
        "  d1  <= (u(0) and v(1)) xor (u(1) and v(0));\n"
        "  d2  <= (u(0) and v(2)) xor (u(1) and v(1)) xor (u(2) and v(0));\n"
        "  d3  <= (u(0) and v(3)) xor (u(1) and v(2)) xor (u(2) and v(1)) xor (u(3) and v(0));\n"
        "  d4  <= (u(0) and v(4)) xor (u(1) and v(3)) xor (u(2) and v(2)) xor (u(3) and v(1)) xor (u(4) and v(0));\n"
        "  d5  <= (u(0) and v(5)) xor (u(1) and v(4)) xor (u(2) and v(3)) xor (u(3) and v(2)) xor (u(4) and v(1)) xor (u(5) and v(0));\n"
        "  d6  <= (u(0) and v(6)) xor (u(1) and v(5)) xor (u(2) and v(4)) xor (u(3) and v(3)) xor (u(4) and v(2)) xor (u(5) and v(1)) xor (u(6) and v(0));\n"
        "  d7  <= (u(0) and v(7)) xor (u(1) and v(6)) xor (u(2) and v(5)) xor (u(3) and v(4)) xor (u(4) and v(3)) xor (u(5) and v(2)) xor (u(6) and v(1)) xor (u(7) and v(0));\n"
        "  d8  <= (u(7) and v(1)) xor (u(6) and v(2)) xor (u(5) and v(3)) xor (u(4) and v(4)) xor (u(3) and v(5)) xor (u(2) and v(6)) xor (u(1) and v(7));\n"
        "  d9  <= (u(7) and v(2)) xor (u(6) and v(3)) xor (u(5) and v(4)) xor (u(4) and v(5)) xor (u(3) and v(6)) xor (u(2) and v(7));\n"
        "  d10 <= (u(7) and v(3)) xor (u(6) and v(4)) xor (u(5) and v(5)) xor (u(4) and v(6)) xor (u(3) and v(7));\n"
        "  d11 <= (u(7) and v(4)) xor (u(6) and v(5)) xor (u(5) and v(6)) xor (u(4) and v(7));\n"
        "  d12 <= (u(7) and v(5)) xor (u(6) and v(6)) xor (u(5) and v(7));\n"
        "  d13 <= (u(7) and v(6)) xor (u(6) and v(7));\n"
        "  d14 <= (u(7) and v(7));\n"
        "\n";

  if (primPoly == 285) // x^8 + x^4 + x^3 + x^2 + 1
  {
    fd << "  w(0) <= d0 xor d8 xor d12 xor d13 xor d14;\n"
          "  w(1) <= d1 xor d9 xor d13 xor d14;\n"
          "  w(2) <= d2 xor d8 xor d10 xor d12 xor d13;\n"
          "  w(3) <= d3 xor d8 xor d9 xor d11 xor d12;\n"
          "  w(4) <= d4 xor d8 xor d9 xor d10 xor d14;\n"
          "  w(5) <= d5 xor d9 xor d10 xor d11;\n"
          "  w(6) <= d6 xor d10 xor d11 xor d12;\n"
          "  w(7) <= d7 xor d11 xor d12 xor d13;\n";
  }
  else if (primPoly == 391) // x^8 + x^7 + x^2 + x + 1
  {
    fd << "  w(0) <= d0 xor ;\n"
          "  w(1) <= d1 xor ;\n"
          "  w(2) <= d2 xor ;\n"
          "  w(3) <= d3 xor ;\n"
          "  w(4) <= d4 xor ;\n"
          "  w(5) <= d5 xor ;\n"
          "  w(6) <= d6 xor ;\n"
          "  w(7) <= d7 xor ;\n";
  }

  fd << "\n"
        "end architecture;\n";

  fd.close();
}
