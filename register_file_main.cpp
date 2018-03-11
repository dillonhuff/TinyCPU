#include <iostream>
#include <ctime>
#include <cstdlib>

#include "Vregister_file.h"
#include "verilated.h"

using namespace std;

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vregister_file* top = new Vregister_file;

  top->clk = 0;
  top->eval();

  top->write_address = 2;
  top->write_data = 538;
  top->write_enable = 1;
  top->clk = 1;
  top->eval();

  top->clk = 0;
  top->read_address_0 = 2;
  top->eval();

  assert(top->read_data_0 == 538);

  top->write_address = 15;
  top->write_data = 3;
  top->clk = 1;
  top->eval();

  top->write_enable = 0;
  top->write_address = 0;
  top->read_address_1 = 15;
  top->clk = 0;
  top->eval();

  assert(top->read_data_1 == 3);

  top->write_enable = 0;
  top->clk = 0;
  top->eval();

  top->clk = 1;
  top->write_address = 15;
  top->write_data = 0;

  top->eval();

  top->clk = 0;
  top->read_address_0 = 15;
  top->eval();

  assert(top->read_data_0 == 3);
  

  cout << "#### Register file tests pass" << endl;
}
