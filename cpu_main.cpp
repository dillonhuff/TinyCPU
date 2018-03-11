#include <iostream>

#include "verilated.h"
#include "Vcpu.h"

using namespace std;

#define MEM cpu__DOT__main_mem__DOT__mem

uint32_t tiny_CPU_no_op_instr() {
  return 0;
}

void load_increment_program(const int mem_depth, Vcpu* const top) {
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op_instr();
    top->MEM[i] = no_op;
  }
}

int main(const int argc, char** argv) {
  Vcpu* top = new Vcpu();

  load_increment_program(2048, top);

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
