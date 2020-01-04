# Naive-RISCV-CPU
This a naive cpu with RISCV ISA.

I adopted a 6-stage pipeline, since the MEM module is sequential circuit.

The design features **a direct-mapped cache for instructions**, allowing IF stage get an instruction each 2 cycles.

For data hazard, I complemented a simple technique--**forwarding**. 

A load/store instruction takes more than one cycle during MEM stage, and **the pipeline will stall until the load/store operation is done**.
To deal with requests of stalling the pipeline from different stages, I designed a module named 'controller' to manage which stages should 
stall. 

As for branches, I employ the simpliest method of prediction, that is, the IF contiune to fetch the instruction at pc+4. In other words, the speculation is always 'not taken'. **The branch target and whether to take the branch is determined during ID stage**. If the branch is unfortunately taken, ID will send a signal to IF, making IF abondon the wrong instruction and set pc to the branch target.
