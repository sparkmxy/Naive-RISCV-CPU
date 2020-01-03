# Naive-RISCV-CPU
This a naive cpu with RISCV ISA.
It has a direct-mapped cache for instructions, allowing IF stage get an instruction each 2 cycles.
For data hazard, I complemented a simple technique--forwarding. 
A load/store instruction takes more than one cycle in MEM stage, and the pipeline will stall until the MEM stage is done.
To deal with requests of stalling the pipeline from different stages, I designed a module named 'controller' to manage which stages should 
stall. 
