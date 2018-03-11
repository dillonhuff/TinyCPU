#include "verilated.h"
#include "Vmain_memory.h"

using namespace std;

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vmain_memory* top = new Vmain_memory;

  top->clk = 0;
  top->eval();

  top->write_address = 23;
  top->write_data = 345;
  top->write_enable = 1;

  top->clk = 1;
  top->eval();

  top->write_enable = 0;
  top->clk = 0;
  top->read_address = 23;
  top->eval();

  assert(top->read_data == 345);
}
