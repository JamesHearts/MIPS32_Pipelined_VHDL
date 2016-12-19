library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is -- This datapath will be used with a controller.

	generic (
		width  :     positive := 32);
	port(
			mem_clk          : in std_logic;
			rst				 : in std_logic;
			
			alu_op_code      : in std_logic_vector(2 downto 0);
			alu_b_mux_sel    : in std_logic;
			branch 			 : in std_logic;
			branch_ne        : in std_logic;
			data_mem_wren	 : in std_logic;
			data_mux_sel	 : in std_logic_vector(1 downto 0);
			dest_mux_sel     : in std_logic_vector(1 downto 0);
			inst_mem_en      : in std_logic;
			lui 			 : in std_logic;
			load_command	 : in std_logic_vector(1 downto 0);
			pc_mux_sel       : in std_logic_vector(1 downto 0);
			pc_reg_en		 : in std_logic;
			reg_file_en		 : in std_logic;
			sign_ext_sel	 : in std_logic;
			store_command    : in std_logic_vector(1 downto 0);
			read_en          : in std_logic;
			jmp_en           : in std_logic;
			
			--PIPELINE REGISTER ENABLES--
			if_id_reg_en     : in std_logic;
			id_ex_reg_en	 : in std_logic;
			ex_mem_reg_en    : in std_logic;
			mem_wb_reg_en    : in std_logic;
			
			--OUTPUTS TO CONTROLLER--
			func        : out std_logic_vector(5 downto 0);
			carry 		: out std_logic;
			op_code		: out std_logic_vector(5 downto 0);
			overflow 	: out std_logic;
			sign 		: out std_logic
		);
	
end datapath;

architecture str of datapath is
	
	signal clk 				: std_logic;
	
	signal alu_b_mux_out_n  : std_logic_vector(width-1 downto 0);
	signal alu_out_n 		: std_logic_vector(width-1 downto 0);
	signal alu_ctrl_out_n 	: std_logic_vector(3 downto 0);
	signal alu_ctrl_shdir_n : std_logic;
	signal br_mux_sel_n		: std_logic;
	signal br_mux_out_n 	: std_logic_vector(width-1 downto 0);
	signal br_add_out_n 	: std_logic_vector(width-1 downto 0);
	signal data_mem_out_n 	: std_logic_vector(width-1 downto 0);
	signal data_mux_out_n   : std_logic_vector(width-1 downto 0);
	signal dest_mux_out_n   : std_logic_vector(4 downto 0);
	signal dest_padded		: std_logic_vector(width-1 downto 0);
	signal extender_out_n 	: std_logic_vector(width-1 downto 0);
	signal increment		: std_logic_vector(width-1 downto 0);
	signal instruction_n 	: std_logic_vector(width-1 downto 0);
	signal instruction_reg_out_n : std_logic_vector(width-1 downto 0);
	signal fwd_a_mux_out_n  : std_logic_vector(width-1 downto 0);
	signal fwd_b_mux_out_n  : std_logic_vector(width-1 downto 0);
	signal pc_out_n 		: std_logic_vector(width-1 downto 0);
	signal pc_mux_in1		: std_logic_vector(width-1 downto 0);
	signal pc_mux_out_n     : std_logic_vector(width-1 downto 0);
	signal pc_inc_out_n 	: std_logic_vector(31 downto 0);
	signal regfile_out_a_n 	: std_logic_vector(width-1 downto 0);
	signal regfile_out_b_n 	: std_logic_vector(width-1 downto 0);
	signal return_reg		: std_logic_vector(4 downto 0);
	signal sl_br_out_n		: std_logic_vector(width-1 downto 0);
	signal sl_jmp_out_n     : std_logic_vector(27 downto 0);
	signal zero_n		    : std_logic;
	
	
	--PIPELINE SIGNALS--
	--REGISTER INPUT AND OUTPUTS--
	signal if_id_reg_in_n	: std_logic_vector(63 downto 0);
	signal if_id_reg_out_n  : std_logic_vector(63 downto 0);
	signal id_ex_reg_in_n	: std_logic_vector(192 downto 0);
	signal id_ex_reg_out_n  : std_logic_vector(192 downto 0);
	signal ex_mem_reg_in_n  : std_logic_vector(111 downto 0);
	signal ex_mem_reg_out_n : std_logic_vector(111 downto 0);
	signal mem_wb_reg_in_n  : std_logic_vector(103 downto 0);
	signal mem_wb_reg_out_n : std_logic_vector(103 downto 0);
	
	--FWD SIGNALS--
	
	signal fwd_a_sel : std_logic_vector(1 downto 0);
	signal fwd_b_sel : std_logic_vector(1 downto 0);
	signal rafm_sel : std_logic_vector(1 downto 0);
	signal rbfm_sel : std_logic_vector(1 downto 0);
	signal rafm_mux_out : std_logic_vector(31 downto 0);
	signal rbfm_mux_out : std_logic_vector(31 downto 0);
	
	--HZRD SIGNALS--
	
	signal data_mem_wren_mux : std_logic;
	signal reg_file_en_mux: std_logic;
	signal stall_n : std_logic;
	signal pc_reg_en_mux : std_logic;
	signal if_id_reg_en_mux : std_logic;
	signal flush_mux_in : std_logic_vector(63 downto 0);
	signal flush_mux_out : std_logic_vector(63 downto 0);
	signal stall_reg_n : std_logic;
	signal pc_reg_en_br : std_logic;
	signal reg_en_jmp : std_logic;	

begin

	PC_INC : entity work.add32 -- The adder to calculate PC increment. (PC + 4)
		port map(
			in0     => pc_out_n,
			in1     => increment,
			sum     => pc_inc_out_n
		);

	ALU	: entity work.alu32 -- The ALU entity.
		port map(
			ia  	=> fwd_a_mux_out_n,
			ib 		=> alu_b_mux_out_n,
			control => alu_ctrl_out_n,
			shamt	=> id_ex_reg_out_n(25 downto 21),
			shdir	=> alu_ctrl_shdir_n,
			lui     => id_ex_reg_out_n(148),
			bne     => id_ex_reg_out_n(147),
			o 	    => alu_out_n,
			Z 	    => zero_n,
			S       => sign,
			V	    => overflow,
			C       => carry
		);
		
	ALU_B_MUX : entity work.mux32 -- The mux that feeds the B input to the ALU.
		port map(
			in0     => id_ex_reg_out_n(46 downto 15),
			in1     => fwd_b_mux_out_n,
			Sel     => id_ex_reg_out_n(146),
			O       => alu_b_mux_out_n
		);
		
	ALU_CONT : entity work.alu32control -- The ALU control.
		port map(
			func    => id_ex_reg_out_n(20 downto 15),
			ALUop   => id_ex_reg_out_n(145 downto 143),
			control => alu_ctrl_out_n,
			shdir   => alu_ctrl_shdir_n
		);
		
	BR_EN : entity work.branchlogic -- Logic that selects the branch value to the pc register.
		port map(
			Z       => zero_n,--ex_mem_reg_out_n(69),
			branch  => id_ex_reg_out_n(151),--ex_mem_reg_out_n(102),
			output  => br_mux_sel_n
		);	
		
	BRANCH_ADD : entity work.add32 -- The adder to calculate branches.
		port map(
			in0     => if_id_reg_out_n(63 downto 32),--id_ex_reg_out_n(142 downto 111),
			in1     => sl_br_out_n,
			sum     => br_add_out_n
		);
		
	BRANCH_MUX : entity work.mux32 -- The mux that selects between the jump address or branch address.
		port map(
			in0     => pc_inc_out_n,
			in1     => id_ex_reg_out_n(142 downto 111),--ex_mem_reg_out_n(101 downto 70),
			Sel     => br_mux_sel_n,
			O       => br_mux_out_n
		);
		
	SHIFT_LEFT_BRANCH : entity work.leftshift32 -- This module performs a left shift twice.
		port map(
			input   => extender_out_n,--id_ex_reg_out_n(46 downto 15),
			output  => sl_br_out_n
		);

	CLK_DIV : entity work.clk_divider -- This entity divides the clock memory.
		port map(
			clk 	=> mem_clk,
			div_clk => clk
		);
		
	DATA_MUX : entity work.mux32_4 -- The mux that feeds the data input on the register file.
		port map(
			in0     => mem_wb_reg_out_n(36 downto 5),
			in1     => mem_wb_reg_out_n(68 downto 37),
			in2 	=> mem_wb_reg_out_n(103 downto 72),
			in3		=> mem_wb_reg_out_n(103 downto 72),
			Sel     => mem_wb_reg_out_n(71 downto 70),
			O       => data_mux_out_n
		);
	
	DEST_MUX : entity work.mux5_4 -- The mux that feeds the destination register in the register file.
		port map(
			in0     => id_ex_reg_out_n(9 downto 5),
			in1     => id_ex_reg_out_n(4 downto 0),
			in2     => return_reg,
			in3 	=> return_reg,
			Sel     => id_ex_reg_out_n(150 downto 149),
			O       => dest_mux_out_n
		);	
		
	HAZARD : entity work.hazard_detection
		port map(
			ID_EX_rt          => id_ex_reg_out_n(9 downto 5),
			IF_ID_rs          => if_id_reg_out_n(25 downto 21),
			IF_ID_rt          => if_id_reg_out_n(20 downto 16),
			EX_MEM_rd   	  => ex_mem_reg_out_n(4 downto 0),
			ID_EX_rd          => instruction_n(15 downto 11),
			ID_EX_reg_file_en => id_ex_reg_out_n(157),
			read_en           => id_ex_reg_out_n(160),
			read_en_mem       => ex_mem_reg_out_n(111),
			alu_b_mux_sel     => alu_b_mux_sel,
			branch            => branch,
			stall             => stall_n,
			stall_reg         => stall_reg_n,
			branch_ex         => id_ex_reg_out_n(151),
			jmp_en            => jmp_en
		);
		
	FWD_UNIT: entity work.forward
		port map(
			EX_MEM_rd => ex_mem_reg_out_n(4 downto 0),
			MEM_WR_rd => mem_wb_reg_out_n(4 downto 0),
			EX_MEM_reg_file_en => ex_mem_reg_out_n(108),
			MEM_WR_reg_file_en => mem_wb_reg_out_n(69),
			ID_EX_rs => id_ex_reg_out_n(14 downto 10),
			ID_EX_rt => id_ex_reg_out_n(9 downto 5),
			IF_ID_rs => if_id_reg_out_n(25 downto 21),
			IF_ID_rt => if_id_reg_out_n(20 downto 16),
			fwd_b_sel => fwd_b_sel,
			fwd_a_sel => fwd_a_sel,
			rafm_sel => rafm_sel,
			rbfm_sel => rbfm_sel
		);
		
	FWD_A_MUX: entity work.mux32_4
		port map(
			in0     => id_ex_reg_out_n(110 downto 79),
			in1     => data_mux_out_n(31 downto 0),
			in2 	=> ex_mem_reg_out_n(68 downto 37),
			in3		=> ex_mem_reg_out_n(68 downto 37),
			Sel     => fwd_a_sel,
			O       => fwd_a_mux_out_n
		);
		
	FWD_B_MUX: entity work.mux32_4
		port map(
			in0     => id_ex_reg_out_n(78 downto 47),
			in1     => data_mux_out_n(31 downto 0),
			in2 	=> ex_mem_reg_out_n(68 downto 37),
			in3		=> ex_mem_reg_out_n(68 downto 37),
			Sel     => fwd_b_sel,
			O       => fwd_b_mux_out_n
		);
		
	INST_MEM : entity work.instruction_memory -- The instruction register.
		port map(
			address		=> pc_out_n(9 downto 2),
			clock		=> mem_clk,
			rden		=> inst_mem_en,
			q			=> instruction_reg_out_n
		);
		
	PC_REG : entity work.pc_reg32 -- The PC register.
		port map(
			Clk     => clk,
			clr     => rst,
			wr      => pc_reg_en_br,
			D       => pc_mux_out_n,
			Q       => pc_out_n
		);
		
	PC_MUX : entity work.mux32_4 -- The mux that feeds the PC register.
		port map(
			in0     => br_mux_out_n,
			in1     => pc_mux_in1,
			in2     => regfile_out_a_n,
			in3		=> alu_out_n,
			Sel     => pc_mux_sel,
			O 	    => pc_mux_out_n
		);
		
	REG_FILE : entity work.registerFile -- register file entity.
		port map(
			q0      => regfile_out_a_n,
			q1      => regfile_out_b_n,
			d       => data_mux_out_n,
			wr      => mem_wb_reg_out_n(69),
			rr0   	=> instruction_n(25 downto 21),
			rr1   	=> instruction_n(20 downto 16),
			rw	  	=> mem_wb_reg_out_n(4 downto 0),
			clk     => clk,
			rst     => rst
		);
		
	REG_A_FWD_MUX : entity work.mux32_4
		port map(
				in0     => regfile_out_a_n,
			    in1     => data_mux_out_n,
				in2     => ex_mem_reg_out_n(68 downto 37),
				in3     => ex_mem_reg_out_n(68 downto 37),
			    Sel     => rafm_sel,
			    O       => rafm_mux_out
		);
		
	REG_B_FWD_MUX : entity work.mux32_4
		port map(
				in0     => regfile_out_b_n,
			    in1     => data_mux_out_n,
				in2     => ex_mem_reg_out_n(68 downto 37),
				in3     => ex_mem_reg_out_n(68 downto 37),
			    Sel     => rbfm_sel,
			    O       => rbfm_mux_out
		);
	
	SIGN_EXT : entity work.extender -- This module does sign extension. Could also use ALU for this.
		port map(
			in0  	=> instruction_n(15 downto 0),
			Sel		=> sign_ext_sel,
			out0	=> extender_out_n
		);
		
	SHIFT_LEFT_JUMP : entity work.leftshift26 -- This module performs a left shift twice. 
		port map(
			input   => instruction_n(25 downto 0),
			output  => sl_jmp_out_n
		);
		
	DATA_MEM : entity work.data_memory -- Not sure if the RAM implementation is the correct one but needed to compile datapath.
		port map(
			mem_clk          => mem_clk,
			address          => ex_mem_reg_out_n(44 downto 37),
			data			 => ex_mem_reg_out_n(36 downto 5),
			wren			 => ex_mem_reg_out_n(107),
			store_command    => ex_mem_reg_out_n(106 downto 105),
			load_command     => ex_mem_reg_out_n(104 downto 103),
			q				 => data_mem_out_n -- 32 bit output.
		);
		
	-- PIPELINE REGISTERS --
		
	IF_ID_REG : entity work.reg -- The PC register.
		generic map(width => 64)
		port map(
			clk     => clk,
			rst     => rst,
			en      => if_id_reg_en_mux,
			input   => flush_mux_out,--if_id_reg_in_n,
			output  => if_id_reg_out_n
		);
		
	ID_EX_REG : entity work.reg -- The PC register.
		generic map(width => 193)
		port map(
			clk     => clk,
			rst     => rst,
			en      => id_ex_reg_en,
			input   => id_ex_reg_in_n,
			output  => id_ex_reg_out_n
		);
		
	EX_MEM_REG : entity work.reg
		generic map(width => 112)
		port map(
			clk     => clk,
			rst     => rst,
			en      => ex_mem_reg_en,
			input   => ex_mem_reg_in_n,
			output  => ex_mem_reg_out_n
		);
		
	MEM_WB_REG : entity work.reg
		generic map(width => 104)
		port map(
			clk     => clk,
			rst     => rst,
			en      => mem_wb_reg_en,
			input   => mem_wb_reg_in_n,
			output  => mem_wb_reg_out_n
		);
		
	DATA_EN_MUX : entity work.mux1
		port map(
			in0   => data_mem_wren,
			in1   => '0',
			Sel   => stall_n,
			O => data_mem_wren_mux
		);
		
	REG_EN_MUX : entity work.mux1
		port map(
			in0   => reg_file_en,
			in1   => '0',
			Sel   => stall_n,
			O => reg_file_en_mux
		);
		
	PCREG_EN_MUX : entity work.mux1
		port map(
			in0   => pc_reg_en,
			in1   => '0',
			Sel   => stall_n,
			O => pc_reg_en_mux
		);
		
	IFID_REG_EN_MUX : entity work.mux1
		port map(
			in0   => if_id_reg_en,
			in1   => '0',
			Sel   => stall_reg_n,
			O     => if_id_reg_en_mux
		);
		
	FLUSH_MUX : entity work.mux32
		generic map(width => 64)
		port map(
			in0   => flush_mux_in,
			in1   => (others => '0'),
			Sel   => stall_n,
			O     => flush_mux_out
		);
	
	-- PIPELINE REGISTER INPUT SIGNALS --
	flush_mux_in    <= pc_inc_out_n & instruction_reg_out_n;
	if_id_reg_in_n  <= flush_mux_out;
	id_ex_reg_in_n  <= if_id_reg_out_n(63 downto 32) & read_en & data_mux_sel & reg_en_jmp & data_mem_wren_mux & store_command & load_command & branch & dest_mux_sel & lui & branch_ne & alu_b_mux_sel & alu_op_code & br_add_out_n & rafm_mux_out & rbfm_mux_out & extender_out_n & instruction_n(25 downto 11); -- br_add_out_n used to be if_id_reg_out_n(63 downto 32)
	ex_mem_reg_in_n <= id_ex_reg_out_n(160 downto 152) & '0' & id_ex_reg_out_n(192 downto 161) & '0' & alu_out_n & id_ex_reg_out_n(78 downto 47) & dest_mux_out_n; -- used to be 151, br_add_out_n, zero_n
	mem_wb_reg_in_n <= ex_mem_reg_out_n(101 downto 70) & ex_mem_reg_out_n(110 downto 108) & data_mem_out_n & ex_mem_reg_out_n(68 downto 37) & ex_mem_reg_out_n(4 downto 0);
	
	instruction_n <= if_id_reg_out_n(31 downto 0);
	
	-- OTHER STUFF --
	increment <= x"00000004"; 
	return_reg <= "11111";
	pc_mux_in1 <= pc_inc_out_n(31 downto 28) & sl_jmp_out_n;
	op_code <= instruction_n(31 downto 26);
	func <= instruction_n(5 downto 0);
	
	
	pc_reg_en_br <= pc_reg_en_mux or br_mux_sel_n or jmp_en;
	reg_en_jmp <= reg_file_en_mux or jmp_en;
	
end str;