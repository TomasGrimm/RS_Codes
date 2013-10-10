#include <fstream>

void Write_Decoder()
{
  std::fstream fd;

  fd.open("RS_Decoder.vhd", std::fstream::out);

  fd << "";

  fd.close();
}
