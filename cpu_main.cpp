#include <iostream>

#include "verilator_common.h"
#include "verilated.h"
#include "Vcpu.h"

using namespace std;

#define MEM cpu__DOT__main_mem__DOT__mem

void load_or_program(const int mem_depth, Vcpu* const top) {
  // Set all memory to be no-ops
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op();
    top->MEM[i] = no_op;
  }


  // res 1101
  top->MEM[0] = tiny_CPU_load_immediate(0b1000, 12);
  top->MEM[1] = tiny_CPU_load_immediate(0b0101, 13);
  top->MEM[2] = tiny_CPU_binop(TINY_CPU_OR, 12, 13, 14);
  top->MEM[3] = tiny_CPU_load_immediate(234, 20);
  top->MEM[4] = tiny_CPU_store(14, 20);
  
}

void load_loop_program(const int mem_depth, Vcpu* const top) {
  // Set all memory to be no-ops
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op();
    top->MEM[i] = no_op;
  }

  top->MEM[0] = tiny_CPU_load_immediate(0, 0);
  top->MEM[1] = tiny_CPU_load_immediate(1000, 1);
  top->MEM[2] = tiny_CPU_load_immediate(0, 26); // reg26 <- 0, loop count
  top->MEM[3] = tiny_CPU_load_immediate(100, 25); // reg25 <- 100, loop bound
  top->MEM[4] = tiny_CPU_store(0, 1); // mem[1000] = 0
  // Enter loop
  top->MEM[5] = tiny_CPU_load(1, 2); // reg2 <- mem[1000]
  top->MEM[6] = tiny_CPU_load_immediate(1, 3); // reg3 <- 1
  top->MEM[7] = tiny_CPU_binop(TINY_CPU_ADD, 2, 3, 2); // reg2 <- reg2 + 1
  top->MEM[8] = tiny_CPU_store(2, 1); // mem[1000] <= reg2
  top->MEM[9] = tiny_CPU_binop(TINY_CPU_ADD, 26, 3, 26);
  top->MEM[10] = tiny_CPU_binop(TINY_CPU_NEQ, 25, 26, 27);
  top->MEM[11] = tiny_CPU_load_immediate(5, 9); // reg9 <- 5
  top->MEM[12] = tiny_CPU_jump(27, 9); // if loop count != loop bound jump to 5

}

void load_load_store_program(const int mem_depth, Vcpu* const top) {

  // Set all memory to be no-ops
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op();
    top->MEM[i] = no_op;
  }

  top->MEM[0] = tiny_CPU_load_immediate(5, 0);
  top->MEM[1] = tiny_CPU_load_immediate(1000, 1);
  top->MEM[2] = tiny_CPU_store(0, 1); // mem[1000] = 5
}

void load_logical_negation_program(const int mem_depth, Vcpu* const top) {
  // Set all memory to be no-ops
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op();
    top->MEM[i] = no_op;
  }

  top->MEM[0] = tiny_CPU_load_immediate(0, 0); // reg0 <- 0
  top->MEM[1] = tiny_CPU_load_immediate(34, 4); // reg3 <- 34
  top->MEM[2] = tiny_CPU_unop(TINY_CPU_LOGIC_NOT, 2, 3); // reg2 <- reg2 + 1
  top->MEM[3] = tiny_CPU_store(3, 4); // mem[34] <= reg2

}

void load_increment_program(const int mem_depth, Vcpu* const top) {
  // Set all memory to be no-ops
  for (int i = 0; i < mem_depth; i++) {
    uint32_t no_op = tiny_CPU_no_op();
    top->MEM[i] = no_op;
  }

  top->MEM[0] = tiny_CPU_load_immediate(0, 0);
  top->MEM[1] = tiny_CPU_load_immediate(1000, 1);
  top->MEM[2] = tiny_CPU_store(0, 1); // mem[1000] = 0
  top->MEM[3] = tiny_CPU_load(1, 2); // reg2 <- mem[1000]
  top->MEM[4] = tiny_CPU_load_immediate(1, 3); // reg3 <- 1
  top->MEM[5] = tiny_CPU_binop(TINY_CPU_ADD, 2, 3, 2); // reg2 <- reg2 + 1
  top->MEM[6] = tiny_CPU_store(2, 1); // mem[1000] <= reg2
  
}

void test_PC(const int argc, char** argv) {
  Vcpu* top = new Vcpu();

  RESET(top);
  
  int n_cycles = 10;
  for (int i = 0; i < n_cycles; i++) {
    HIGH_CLOCK(top);
  }

  assert(top->PC_value > 0);

  top->final();
}

void test_or_alu(const int argc, char** argv) {
  Vcpu* top = new Vcpu();

  load_or_program(2048, top);

  RESET(top);
  
  int n_cycles = 40;
  for (int i = 0; i < n_cycles; i++) {

    HIGH_CLOCK(top);

    cout << "At " << i << " instruction type is = " << (int) top->current_instruction_type_dbg << ", PC = " << (int) top->PC_value << endl;
  }

  cout << "top->MEM[234] = " << ((int)top->MEM[234]) << endl;
  assert(top->MEM[234] == 0b1101);

  top->final();

}

void test_load_store_program(const int argc, char** argv) {
  cout << "Testing load immediate then storing it back" << endl;

  Vcpu* top = new Vcpu();

  load_load_store_program(2048, top);

  RESET(top);
  HIGH_CLOCK(top);

  // First instruction is load_immediate
  cout << "Current instruction type = " << (int) top->current_instruction_type_dbg << endl;
  assert(top->current_instruction_type_dbg == TINY_CPU_INSTRUCTION_LOAD_IMMEDIATE);

  HIGH_CLOCK(top);
  
  int n_cycles = 40;
  // Q: How many cycles are needed to increment 2 times?
  for (int i = 0; i < n_cycles; i++) {

    HIGH_CLOCK(top);

    cout << "At " << i << " instruction type is = " << (int) top->current_instruction_type_dbg << ", PC = " << (int) top->PC_value << endl;
  }

  cout << "top->MEM[1000] = " << ((int)top->MEM[1000]) << endl;
  assert(top->MEM[1000] == 5);

  top->final();
}

void test_increment_program(const int argc, char** argv) {
  cout << "Testing increment" << endl;

  Vcpu* top = new Vcpu();

  load_increment_program(2048, top);

  RESET(top);
  HIGH_CLOCK(top);

  // First instruction is load_immediate
  cout << "Current instruction type = " << (int) top->current_instruction_type_dbg << endl;
  assert(top->current_instruction_type_dbg == TINY_CPU_INSTRUCTION_LOAD_IMMEDIATE);

  HIGH_CLOCK(top);
  
  int n_cycles = 40;
  // Q: How many cycles are needed to increment 2 times?
  for (int i = 0; i < n_cycles; i++) {

    HIGH_CLOCK(top);

    cout << "At " << i << " instruction type is = " << (int) top->current_instruction_type_dbg << ", PC = " << (int) top->PC_value << endl;
  }

  cout << "top->MEM[1000] = " << ((int)top->MEM[1000]) << endl;
  assert(top->MEM[1000] == 1);

  top->final();
}

void test_increment_loop(const int argc, char** argv) {
  Vcpu* top = new Vcpu();

  load_loop_program(2048, top);

  RESET(top);

  // Cycles needed to get to MEM[1000] = K
  // Startup cycles + (N_STAGES*loop_length*K)
  int K = 3;
  int N_STAGES = 5;
  int startup_cycles = 5;
  int loop_length = 8; // TODO: Set correctly
  int n_cycles = startup_cycles + N_STAGES*loop_length*K;
  for (int i = 0; i < n_cycles; i++) {

    HIGH_CLOCK(top);

    cout << "At " << i << " instruction type is = " << (int) top->current_instruction_type_dbg << ", PC = " << (int) top->PC_value << endl;
  }

  cout << "top->MEM[1000] = " << ((int)top->MEM[1000]) << endl;
  assert(top->MEM[1000] == K);

  top->final();
}

void test_logical_negation(const int argc, char** argv) {
  Vcpu* top = new Vcpu();

  load_logical_negation_program(2048, top);

  RESET(top);

  int n_cycles = 50;
  for (int i = 0; i < n_cycles; i++) {
    HIGH_CLOCK(top);
  }
  cout << "top->MEM[34] = " << ((int)top->MEM[34]) << endl;
  assert(top->MEM[34] == 1);

  top->final();
}

void load_neq_program(const int mem_depth, Vcpu* const top) {
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
  Vcpu* top = new Vcpu();

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

int main(const int argc, char** argv) {
  test_logical_negation(argc, argv);
  test_neq_alu(argc, argv);
  test_PC(argc, argv);
  test_or_alu(argc, argv);
  test_load_store_program(argc, argv);
  test_increment_program(argc, argv);
  test_increment_loop(argc, argv);

  cout << "$$$$ CPU tests passed" << endl;
}
