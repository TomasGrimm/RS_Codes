#include <fstream>

void Write_BerlekampMassey()
{
  std::fstream fd;

  fd.open("RS_BerlekampMassey.vhd", std::fstream::out);

  fd << "";

  fd.close();
}
