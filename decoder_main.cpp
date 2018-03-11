#include <iostream>
#include <ctime>
#include <cstdlib>

#include "Vdecoder.h"
#include "verilated.h"

using namespace std;

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vdecoder* top = new Vdecoder;

  top->eval();

  cout << "$$$$ Decoder passes tests"  << endl;
}
