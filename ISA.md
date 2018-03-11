# Instructions

* load_immediate <IMM>, <REG>
* load_memory <MEM LOC REG>, <DEST REG>
* store <DATA REG>, <MEM LOC REG>
* jump <CONDITION REG>, <VALUE REG>
* <BINOP> <OP 0 REG>, <OP 1 REG>, <DEST REG>
* no_op

# Instruction formats:

32 bits per instruction

[31:0]

[31:27] --> Instruction code

load immediate
[26:11] --> 16 bit immediate
[10:6] --> 5 bit register ID

load memory
[26:22] --> mem location register ID
[21:17] --> dest register ID

store
[26:22] --> data register ID
[21:17] --> mem location register ID

jump
[26:22] --> condition register ID
[21:17] --> memory location register ID

binop
[26:22] --> operand0 reg ID
[21:17] --> operand1 reg ID
[16:12] --> result reg ID
[11:9]  --> ALU operation

no op
No entries