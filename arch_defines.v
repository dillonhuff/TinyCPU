`define BUS_WIDTH(w) [$clog2(w - 1) : 0]

// `define STAGE_INSTR_FETCH 0
// `define STAGE_REGISTER_READ 1
// `define STAGE_MEMORY 2
// `define STAGE_REGISTER_UPDATE 3
// `define STAGE_PC_UPDATE 4

// `define STAGE_PC_UPDATE 0
// `define STAGE_INSTR_FETCH 1
// `define STAGE_REGISTER_READ 2
// `define STAGE_MEMORY 3
// `define STAGE_REGISTER_UPDATE 4

`define STAGE_PC_UPDATE 0
`define STAGE_REGISTER_READ 1
`define STAGE_MEMORY 2
`define STAGE_REGISTER_UPDATE 3

`define NUM_STAGES 4


`define STAGE_WIDTH `BUS_WIDTH(`NUM_STAGES)

`define INSTR_NO_OP 0
`define INSTR_LOAD_IMMEDIATE 1
`define INSTR_LOAD 2
`define INSTR_STORE 3
`define INSTR_JUMP 4
`define INSTR_ALU_OP 5

`define ALU_OP_OR 0
`define ALU_OP_AND 1
`define ALU_OP_XOR 2
`define ALU_OP_ADD 3
`define ALU_OP_SUB 4
`define ALU_OP_MUL 5
