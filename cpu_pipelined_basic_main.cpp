#include <iostream>

#include "verilator_common.h"
#include "verilated.h"
#include "Vcpu_pipelined_basic.h"

#define MEM cpu_pipelined_basic__DOT__main_mem__DOT__mem

using namespace std;

void load_neq_program(const int mem_depth, Vcpu_pipelined_basic* const top) {
  // Set all memory to be no-ops
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op();
    top->MEM[i] = no_op;
  }


  // res 1101
  top->MEM[0] = tiny_CPU_load_immediate(100, 12);
  top->MEM[1] = tiny_CPU_load_immediate(4, 13);
  top->MEM[2] = tiny_CPU_binop(TINY_CPU_NEQ, 12, 13, 14);
  top->MEM[3] = tiny_CPU_load_immediate(58, 20);
  top->MEM[4] = tiny_CPU_store(14, 20);
  
}

void test_neq_alu(const int argc, char** argv) {
  Vcpu_pipelined_basic* top = new Vcpu_pipelined_basic();

  load_neq_program(2048, top);

  cout << "Testing neq" << endl;

  RESET(top);
  
  int n_cycles = 40;
  for (int i = 0; i < n_cycles; i++) {

    HIGH_CLOCK(top);

    cout << "At " << i << " instruction type is = " << (int) top->current_instruction_type_dbg << ", PC = " << (int) top->PC_value << endl;
  }

  cout << "top->MEM[58] = " << ((int)top->MEM[58]) << endl;
  assert(top->MEM[58] == 1);

  top->final();

}


int main() {
}
