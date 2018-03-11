#include <iostream>
#include <ctime>
#include <cstdlib>

#include "Valu.h"
#include "verilated.h"

using namespace std;

void test_and_out(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Valu* top = new Valu;

  top->eval();

  top->op_select = 1;
  top->in0 = 1;
  top->in1 = 0;

  top->eval();

  assert(top->out == 0);

  top->in1 = 1;

  top->eval();

  assert(top->out == 1);

  top->final();
}

void test_or_out(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Valu* top = new Valu;

  top->eval();

  top->eval();

  top->in0 = 1;
  top->in1 = 0;

  top->eval();

  assert(top->out == 1);

  top->in0 = 0;
  top->in1 = 0;

  top->eval();

  assert(top->out == 0);

  top->final();
}

void test_xor_out(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Valu* top = new Valu;

  top->in0 = 1;
  top->in1 = 0;
  top->op_select = 2;

  top->eval();

  assert(top->out == 1);

  top->in0 = 1;
  top->in1 = 1;

  top->eval();

  assert(top->out == 0);

  top->final();
}

int main(int argc, char** argv) {

  test_and_out(argc, argv);
  test_or_out(argc, argv);
  test_xor_out(argc, argv);

  cout << "$$$$ ALU tests pass" << endl;
}
