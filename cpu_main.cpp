#include <iostream>

#include "verilated.h"
#include "Vcpu.h"

using namespace std;

#define MEM cpu__DOT__main_mem__DOT__mem

uint32_t tiny_CPU_no_op_instr() {
  return 0;
}

void load_increment_program(const int mem_depth, Vcpu* const top) {
  // Set all memory to be no-ops
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op_instr();
    top->MEM[i] = no_op;
  }

  top->MEM[0] = tiny_CPU_load_immediate(0, 0);
  top->MEM[1] = tiny_CPU_load_immediate(1000, 1);
  top->MEM[2] = tiny_CPU_store(0, 1); // mem[1000] = 0
  // Enter loop
  top->MEM[3] = tiny_CPU_load(1, 2); // reg2 <- mem[1000]
  top->MEM[4] = tiny_CPU_load_immediate(1, 3); // reg3 <- 1
  top->MEM[5] = tiny_CPU_binop(TINY_CPU_ADD, 2, 3, 2); // reg2 <- reg2 + 1
  top->MEM[6] = tiny_CPU_store(2, 1); // mem[1000] <= reg2
  
  
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
