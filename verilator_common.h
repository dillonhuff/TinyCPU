#define RESET(top)   (top)->rst = 0;            \
  (top)->clk = 0;                               \
  (top)->eval();                                \
  (top)->rst = 1;                               \
  (top)->clk = 0;                               \
  (top)->eval();                                \
  (top)->rst = 0;                               \
  (top)->clk = 0;                               \
  (top)->eval();                                \
  (top)->rst = 1;                               \
  (top)->clk = 0;                               \
  (top)->eval();

#define HIGH_CLOCK(top) assert(top->clk == 0); (top)->eval(); (top)->clk = 1; (top)->eval(); (top)->clk = 0; top->eval();

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
#define TINY_CPU_SUB 4
#define TINY_CPU_MUL 5
#define TINY_CPU_NEQ 6
#define TINY_CPU_LOGIC_NOT 7

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

  return instr;
}

uint32_t tiny_CPU_unop(const int op_code,
                       const int reg0,
                       const int dest_reg) {
  uint32_t instr = 0;
  set_instr_type(TINY_CPU_INSTRUCTION_ALU_OP, &instr);
  instr = instr | (reg0 << 22);
  instr = instr | (dest_reg << 12);
  instr = instr | (op_code << 7);
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
  instr = instr | (op_code << 7);
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

uint32_t tiny_CPU_jump(const int condition_reg, const int destination_reg) {
  uint32_t instr = 0;
  set_instr_type(TINY_CPU_INSTRUCTION_JUMP, &instr);
  instr = instr | (condition_reg << 22);
  instr = instr | (destination_reg << 17);
  return instr;
}
