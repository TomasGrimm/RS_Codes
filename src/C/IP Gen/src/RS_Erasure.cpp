#include <fstream>

void Write_Erasure()
{
  std::fstream fd;

  fd.open("RS_Erasure.vhd", std::fstream::out);

  fd << "";

  fd.close();
}
