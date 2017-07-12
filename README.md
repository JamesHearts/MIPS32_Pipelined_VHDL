# MIPS32_Pipelined_VHDL
This is a fully pipelined version of the MIPS32 ISA.

This is the processor I designed for my Computer Architecture class. The class has 5 labs that consist of separate portions of the
processor. I accomplished this lab using modelsim and notepad++. All the code is written in VHDL. I chose VHDL as the language due to 
it's "strongly typed" nature. 

How to run the processor
------------------------------------------------------------------------------------------------------------------------------------------

The top_level.vhd is the top level entity for all the files in the hierarchy. The top_level_tb is a testbench that simply runs the 
processor. The instruction.mif file is where written programs would be pasted into. In order to run the processor use Modelsim. Create a new project and import all the source files. Compile all the files and then start simulation. When the simulation is started it will need a test file to simulation. Select top_level_tb file in order to start the simulation. 

How to write programs
------------------------------------------------------------------------------------------------------------------------------------------

The easiest way to do this is to use write programs in MIPS assembly. Use my compiler to transform the assembly into machine code. Copy and paste the output code into the instruction.mif file and follow the instructions above.

What is MIPS?
------------------------------------------------------------------------------------------------------------------------------------------

MIPS is a reduced instruction set computer (RISC) instruction set architecture (ISA). It was the first RISC processor to be developed. It was developed at Stanford University by John L. Hennessey and his colleagues. The importance of the RISC is that the processor could do more with less instructions, instead of creating instructions for every process we could now combine multiple instructions to complete a process. This allowed for a smaller instruction set and allowed the processor to make use of a 32-bit instruction space.

There are 3 different hardware implementations of the MIPS ISA; single-cycle, multi-cycle and pipelined. This particular implementation is pipelined. The pipelined processor consists of 5 stages. The instruction fetch (IF), instruction decode (ID), execution (EX), memory (MEM), and write back (WB) stages. These stages are the 5 stages of the pipeline, between each consecutive stage there is a register that propagates data along the pipeline.

A pipelined processor will run into problems that we call Hazards. Therefore my design also includes a working Hazard Detection Unit 
and a Forwarding unit to deal with these problems.


The book that I used as a reference that goes over this processor design in detail is:

Computer Organization and Design, 5th edition, by John L. Hennessey.

I reccommend reading chapter 4 to understand the design.
