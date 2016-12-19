library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is

	generic (
		width  :     positive := 32);
	port(
		signal clk, rst 		: in std_logic
		
	);
end top_level;

architecture STR of top_level is
	     
		 signal alu_op_code_n 	: std_logic_vector(2 downto 0);
		 signal alu_b_mux_sel_n : std_logic;
		 signal branch_n 		: std_logic;
		 signal branch_ne_n 	: std_logic;
		 signal carry_n 		: std_logic;
		 signal data_mem_wren_n : std_logic;
		 signal data_mux_sel_n 	: std_logic_vector(1 downto 0);
		 signal dest_mux_sel_n 	: std_logic_vector(1 downto 0);
		 signal func_n 			: std_logic_vector(5 downto 0);
		 signal inst_mem_en_n 	: std_logic;
		 signal lui_n 			: std_logic;
		 signal load_command_n 	: std_logic_vector(1 downto 0);
		 signal op_code_n 		: std_logic_vector(5 downto 0);
		 signal overflow_n 		: std_logic;
		 signal pc_mux_sel_n 	: std_logic_vector(1 downto 0);
		 signal pc_reg_en_n 	: std_logic;
		 signal reg_file_en_n 	: std_logic;
		 signal sign_n 			: std_logic;
		 signal store_command_n : std_logic_vector(1 downto 0);
		 signal sign_ext_sel_n 	: std_logic;
		 signal if_id_reg_en_n  : std_logic;
		 signal id_ex_reg_en_n	: std_logic;
		 signal ex_mem_reg_en_n : std_logic;
		 signal mem_wb_reg_en_n : std_logic;
		 signal read_en         : std_logic;
		 signal jmp_en          : std_logic;
		 
		 
		

begin

	CTRL : entity work.controller
	port map(
		op_code		  	=> op_code_n,
		carry			=> carry_n,
		overflow        => overflow_n,
		sign            => sign_n,
		alu_op_code     => alu_op_code_n,
		alu_b_mux_sel 	=> alu_b_mux_sel_n,
		branch 		  	=> branch_n,
		branch_ne		=> branch_ne_n,
		data_mem_wren	=> data_mem_wren_n,
		data_mux_sel  	=> data_mux_sel_n,
		dest_mux_sel  	=> dest_mux_sel_n,
		func            => func_n,
		inst_mem_en   	=> inst_mem_en_n,
		lui				=> lui_n,
		load_command    => load_command_n,
		pc_mux_sel    	=> pc_mux_sel_n,
		pc_reg_en     	=> pc_reg_en_n,
		reg_file_en	  	=> reg_file_en_n,
		store_command   => store_command_n,
		sign_ext_sel  	=> sign_ext_sel_n,
		if_id_reg_en    => if_id_reg_en_n,
		id_ex_reg_en	=> id_ex_reg_en_n,
		ex_mem_reg_en   => ex_mem_reg_en_n,
		mem_wb_reg_en   => mem_wb_reg_en_n,
		read_en         => read_en,
		jmp_en          => jmp_en
	);
	
	DPATH : entity work.datapath
	port map(
		mem_clk         => clk,
		rst				=> rst,
		alu_op_code     => alu_op_code_n,
		alu_b_mux_sel   => alu_b_mux_sel_n,
		branch 			=> branch_n,
		branch_ne    	=> branch_ne_n,
		data_mem_wren	=> data_mem_wren_n,
		data_mux_sel	=> data_mux_sel_n,
		dest_mux_sel    => dest_mux_sel_n,
		func 			=> func_n,
		inst_mem_en     => inst_mem_en_n,
		lui				=> lui_n,
		load_command	=> load_command_n,
		pc_mux_sel      => pc_mux_sel_n,
		pc_reg_en		=> pc_reg_en_n,
		reg_file_en		=> reg_file_en_n,
		sign_ext_sel	=> sign_ext_sel_n,
		carry 			=> carry_n,
		op_code			=> op_code_n,
		overflow 		=> overflow_n,
		store_command   => store_command_n,
		sign 			=> sign_n,
		if_id_reg_en    => if_id_reg_en_n,
		id_ex_reg_en	=> id_ex_reg_en_n,
		ex_mem_reg_en   => ex_mem_reg_en_n,
		mem_wb_reg_en   => mem_wb_reg_en_n,
		read_en         => read_en,
		jmp_en          => jmp_en
	);

end STR;
