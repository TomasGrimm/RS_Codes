#include <fstream>

void Write_Chien_Forney(int t)
{
  std::fstream fd;

  fd.open("RS_chien_forney.vhd", std::fstream::out);

  fd << "";

  fd.close();
}
