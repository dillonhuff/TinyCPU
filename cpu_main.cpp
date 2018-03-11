#include <iostream>

#include "verilated.h"
#include "Vcpu.h"

using namespace std;

int main(const int argc, char** argv) {
  Vcpu* top = new Vcpu();

  top->rst = 0;
  top->clk = 0;
  top->eval();

  top->rst = 1;
  top->clk = 0;
  top->eval();

  top->rst = 0;
  top->clk = 0;
  top->eval();

  int n_cycles = 10;
  for (int i = 0; i < n_cycles; i++) {
    top->clk = i % 2;
  }

  assert(top->PC_value > 0);

  cout << "$$$$ CPU tests passed" << endl;
}
