# MIPS32_Pipelined_VHDL
This is a fully pipelined version of the MIPS32 ISA.

This is the processor I designed for my Computer Architecture class. The class has 5 labs that consist of separate portions of the
processor. I accomplished this lab using modelsim and notepad++. All the code is written in VHDL. I chose VHDL as the language due to 
it's "strongly typed" nature. 

The top_level.vhd is the top level entity for all the files in the hierarchy. The top_level_tb is a testbench that simply runs the 
processor. The instruction.mif file is where written programs would be pasted into. 

The MIPS32 pipelined processor consists of 5 stages. The instruction fetch (IF), instruction decode (ID), execution (EX), memory (MEM), 
and write back (WB) stages. These stages are the 5 stages of the pipeline, between each consecutive stage there is a register that propagates
data along the pipeline.

A pipelined processor will run into problems that we call Hazards. Therefore my design also includes a working Hazard Detection Unit 
and a Forwarding unit to deal with these problems.

The book that I used in this class that goes over this processor design in detail is:

Computer Organization and Design, 5th edition, by John L. Hennessey.

I reccommend reading chapter 4 to understand the design.
