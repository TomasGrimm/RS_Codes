#include <fstream>

void Write_Package()
{
  std::fstream fd;

  fd.open("RS_Package.vhd", std::fstream::out);

  fd << "";

  fd.close();
}
