#include <iostream>
#include <fstream>

using namespace std;

void Write_Package(/* muitos argumentos */);
void Write_Multiplier(int);
void Write_Inversion_Table(int);
void Write_Encoder();
void Write_Decoder();
void Write_Syndrome();
void Write_Erasure();
void Write_BerlekampMassey();
void Write_Euclidean();
void Write_Chien_Forney(int);

int main(int argc, char * argv[])
{
  // 1. review input arguments and warn if something is missing
  // 1.1. codeword size

  // 1.2. message size

  // 1.3. primitive polynomial

  // 1.4. use of erasure decoding

  // 1.5. generate coder, decoder or both
  
  // 2. configure internal variables

  // 3. generate output files
  // 3.1 Write package and auxiliary files
  Write_Package(/* muitos argumentos */);
  Write_Multiplier(primPoly);
  Write_Inversion_Table(primPoly);
  
  // 3.2 Write coder files
  Write_Encoder();

  // 3.3 Write decoder files
  Write_Decoder();
  Write_Syndrome();
  Write_Erasure();

  //Write_BerlekampMassey();
  //Write_Euclidean();
  
  Write_Chien_Forney(t);

  // 4. finish execution
  return 0;
}
