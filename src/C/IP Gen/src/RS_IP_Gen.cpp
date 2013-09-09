#include <iostream>
#include <fstream>

using namespace std;

void Write_Syndrome();
void Write_Chien_Forney(int);

int main(int argc, char * argv[]) {
  // 1. review input arguments and warn if something is missing
  // 1.1. codeword size

  // 1.2. message size

  // 1.3. primitive polynomial

  // 1.4. use of erasure decoding

  // 1.5. generate files for coder, decoder or both

  // 1.6. generate architecture improved for area or for delay
  
  // 2. configure internal variables

  // 3. generate output files
  // 3.1 Write package and auxiliary files
  
  // 3.2 Write coder files

  // 3.3 Write decoder files
  Write_Syndrome();
  Write_Chien_Forney();

  // 4. finish execution
  return 0;
}
