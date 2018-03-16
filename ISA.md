# Instructions

* no_op
* load_immediate \<IMM\>, \<REG\>
* load_memory <MEM LOC REG>, <DEST REG>
* store <DATA REG>, <MEM LOC REG>
* jump <CONDITION REG>, <VALUE REG>
* <ALU OP> <OP 0 REG>, <OP 1 REG>, <DEST REG>

# Instruction formats:

32 bits per instruction

[31:0]

[31:27] --> Instruction code

no op: op code 0
No data

load immediate: op code 1
[26:11] --> 16 bit immediate
[10:6] --> 5 bit register ID

load memory: op code 2
[26:22] --> mem location register ID
[21:17] --> dest register ID

store: op code 3
[26:22] --> data register ID
[21:17] --> mem location register ID

jump: op code 4
[26:22] --> condition register ID
[21:17] --> memory location register ID

ALU op: op code 5
[26:22] --> operand0 reg ID
[21:17] --> operand1 reg ID (ignored for unary operators)
[16:12] --> result reg ID
[11:7]  --> ALU operation

ALU codes:
0 -> or
1 -> and
2 -> xor
3 -> add
4 -> sub
5 -> mul
6 -> neq
7 -> logical not