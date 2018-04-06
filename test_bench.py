from testbench_utils import build_module

build_module('cpu_pipelined_basic', '-Icommon -Ipipelined_basic')
build_module('alu', '-Icommon')
build_module('register_file', '-Icommon')
build_module('main_memory', '-Ifirst_cpu')
build_module('decoder', '-Icommon')
build_module('cpu', '-Icommon -Ifirst_cpu')
