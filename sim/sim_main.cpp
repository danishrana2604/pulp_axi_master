// sim_main.cpp - Minimal wrapper without tracing for fast compilation
#include "Vuvm_pkg.h"
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    
    Vuvm_pkg* top = new Vuvm_pkg;
    
    vluint64_t sim_time = 0;
    const vluint64_t max_sim_time = 100000;
    
    while (!Verilated::gotFinish() && sim_time < max_sim_time) {
        top->eval();
        sim_time++;
    }
    
    delete top;
    return 0;
}
