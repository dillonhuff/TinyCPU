#include <iostream>
#include <ctime>
#include <cstdlib>

#include "verilator_common.h"
#include "Vregister_file.h"
#include "verilated.h"

using namespace std;

int main(int argc, char** argv) {
  cout << "---- Testing register file" << endl;

  Verilated::commandArgs(argc, argv);
  Vregister_file* top = new Vregister_file;

  HIGH_CLOCK(top);

  top->write_address = 2;
  top->write_data = 538;
  top->write_enable = 1;

  HIGH_CLOCK(top);

  top->read_address_0 = 2;

  HIGH_CLOCK(top);

  assert(top->read_data_0 == 538);

  top->write_address = 15;
  top->write_data = 3;

  HIGH_CLOCK(top);

  top->write_enable = 0;
  top->write_address = 0;
  top->read_address_1 = 15;

  HIGH_CLOCK(top);

  assert(top->read_data_1 == 3);

  top->write_enable = 0;

  top->write_address = 15;
  top->write_data = 0;

  HIGH_CLOCK(top);

  top->read_address_0 = 15;

  HIGH_CLOCK(top);

  assert(top->read_data_0 == 3);
  

  cout << "#### Register file tests pass" << endl;
}
