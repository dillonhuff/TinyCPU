#include <iostream>

#include "verilated.h"
#include "Vcpu.h"

using namespace std;

#define MEM cpu__DOT__main_mem__DOT__mem

#define HIGH_CLOCK(top) assert(top->clk == 0); (top)->clk = 0; (top)->eval(); (top)->clk = 1; (top)->eval(); (top)->clk = 0; top->eval();

enum instruction_type {
  TINY_CPU_INSTRUCTION_NO_OP = 0,
  TINY_CPU_INSTRUCTION_LOAD_IMMEDIATE = 1,
  TINY_CPU_INSTRUCTION_LOAD = 2,
  TINY_CPU_INSTRUCTION_STORE = 3,
  TINY_CPU_INSTRUCTION_JUMP = 4,
  TINY_CPU_INSTRUCTION_ALU_OP = 5,
};

#define TINY_CPU_OR 0
#define TINY_CPU_AND 1
#define TINY_CPU_XOR 2
#define TINY_CPU_ADD 3

uint32_t tiny_CPU_no_op() {
  return 0;
}

void set_instr_type(const instruction_type tp, uint32_t* instr) {
  uint32_t tp_int = (uint32_t) tp;
  *instr = (*instr) | (tp_int << 27);
}

uint32_t tiny_CPU_load_immediate(const int value, const int dest_reg) {
  uint32_t instr = 0;
  set_instr_type(TINY_CPU_INSTRUCTION_LOAD_IMMEDIATE, &instr);

  instr = instr | (value << 11);
  instr = instr | (dest_reg << 6);

  cout << "Load imm = " << bitset<32>(instr) << endl;
  return instr;
}

uint32_t tiny_CPU_binop(const int op_code,
                        const int reg0,
                        const int reg1,
                        const int dest_reg) {
  uint32_t instr = 0;
  set_instr_type(TINY_CPU_INSTRUCTION_ALU_OP, &instr);
  instr = instr | (reg0 << 22);
  instr = instr | (reg1 << 17);
  instr = instr | (dest_reg << 12);
  return instr;
}

uint32_t tiny_CPU_load(const int mem_loc_reg, const int dest_reg) {
  uint32_t instr = 0;
  set_instr_type(TINY_CPU_INSTRUCTION_LOAD, &instr);

  instr = instr | (mem_loc_reg << 22);
  instr = instr | (dest_reg << 17);
  
  return instr;
}

uint32_t tiny_CPU_store(const int data_reg, const int mem_loc_reg) {
  uint32_t instr = 0;
  set_instr_type(TINY_CPU_INSTRUCTION_STORE, &instr);

  instr = instr | (data_reg << 22);
  instr = instr | (mem_loc_reg << 17);
  
  return instr;
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
  // Enter loop
  top->MEM[3] = tiny_CPU_load(1, 2); // reg2 <- mem[1000]
  top->MEM[4] = tiny_CPU_load_immediate(1, 3); // reg3 <- 1
  top->MEM[5] = tiny_CPU_binop(TINY_CPU_ADD, 2, 3, 2); // reg2 <- reg2 + 1
  top->MEM[6] = tiny_CPU_store(2, 1); // mem[1000] <= reg2
  // TODO: Insert jump
  
  
}

void test_PC(const int argc, char** argv) {
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

  top->rst = 1;
  top->clk = 0;
  top->eval();
  
  int n_cycles = 10;
  for (int i = 0; i < n_cycles; i++) {
    top->clk = i % 2;
    top->eval();
  }

  assert(top->PC_value > 0);

  top->final();
}

void test_increment_program(const int argc, char** argv) {
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

  top->rst = 1;
  top->clk = 0;
  top->eval();

  // top->clk = 0;
  // top->eval();

  // top->clk = 1;
  // top->eval();

  HIGH_CLOCK(top);

  // First instruction is load_immediate
  cout << "Current instruction type = " << (int) top->current_instruction_type_dbg << endl;
  assert(top->current_instruction_type_dbg == TINY_CPU_INSTRUCTION_LOAD_IMMEDIATE);

  HIGH_CLOCK(top);
  // top->clk = 0;
  // top->eval();

  // top->clk = 1;
  // top->eval();
  
  int n_cycles = 100;
  for (int i = 0; i < n_cycles; i++) {
    top->clk = i % 2;
    top->eval();

    cout << "At " << i << " instruction type is = " << (int) top->current_instruction_type_dbg << ", PC = " << (int) top->PC_value << endl;
  }

  cout << "top->MEM[1000] = " << ((int)top->MEM[1000]) << endl;
  assert(top->MEM[1000] == 5);

  top->final();
}


int main(const int argc, char** argv) {
  test_PC(argc, argv);
  test_increment_program(argc, argv);

  cout << "$$$$ CPU tests passed" << endl;
}
