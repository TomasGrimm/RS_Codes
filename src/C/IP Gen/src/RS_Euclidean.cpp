#include <fstream>

void Write_Euclidean()
{
  std::fstream fd;

  fd.open("RS_Euclidean.vhd", std::fstream::out);

  fd << "";

  fd.close();
}
