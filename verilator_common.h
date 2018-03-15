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

