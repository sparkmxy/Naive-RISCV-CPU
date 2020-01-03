# Naive-RISCV-CPU
This a naive cpu with RISCV ISA.

It has a direct-mapped cache for instructions, allowing IF stage get an instruction each 2 cycles.

For data hazard, I complemented a simple technique--forwarding. 

A load/store instruction takes more than one cycle in MEM stage, and the pipeline will stall until the MEM stage is done.
To deal with requests of stalling the pipeline from different stages, I designed a module named 'controller' to manage which stages should 
stall. 

As for branches, I adopted the simpliest method of prediction, that is, the IF contiune to fetch the instruction at pc+4. In another words, the speculation is always 'not taken'. If the branch is unfortunately taken, ID will send a signal to IF, making IF abondon the wrong instruction and set pc to the branch target.
