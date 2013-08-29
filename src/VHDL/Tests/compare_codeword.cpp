#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[])
{
  int counter;
  int errors_count;
  ifstream golden;
  ifstream output;
  string golden_line;
  string output_line;

  golden.open(argv[1], ifstream::in);
  output.open(argv[2], ifstream::in);

  counter = 0;
  errors_count = 0;

  output >> output_line;
  output >> output_line;

  while (!golden.eof())
  {
    golden >> golden_line;
    output >> output_line;

    if (golden_line != output_line)
      {
      cout << counter << ' ' << golden_line << ' ' << output_line << endl;
      errors_count++;
      }

    counter++;
  }

  golden.close();
  output.close();

  if (errors_count == 0)
    cout << "No errors!" << endl;
      
  return 0;
}
