library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is --This controller is used to control the datapath.

	generic (
		width  :     positive := 32);
	port(	
		op_code		  	 : in std_logic_vector(5 downto 0);
		func             : in std_logic_vector(5 downto 0);
		carry			 : in std_logic;
		overflow         : in std_logic;
		sign             : in std_logic;
		alu_op_code   : out std_logic_vector(2 downto 0);
		alu_b_mux_sel : out std_logic;
		branch 		  : out std_logic;
		branch_ne	  : out std_logic;
		data_mem_wren : out std_logic;
		data_mux_sel  : out std_logic_vector(1 downto 0);
		dest_mux_sel  : out std_logic_vector(1 downto 0);
		inst_mem_en   : out std_logic;
		lui			  : out std_logic;
		load_command  : out std_logic_vector(1 downto 0);
		pc_mux_sel    : out std_logic_vector(1 downto 0);
		pc_reg_en     : out std_logic;
		reg_file_en	  : out std_logic;
		store_command : out std_logic_vector(1 downto 0);
		sign_ext_sel  : out std_logic;
		if_id_reg_en  : out std_logic;
		id_ex_reg_en  : out std_logic;
		ex_mem_reg_en : out std_logic;
		mem_wb_reg_en : out std_logic;
		read_en       : out std_logic; --Doesn't actually enable anything, but tells the hazard unit that we are loading.
		jmp_en        : out std_logic  --Doesn't actually enable anything, but tells the hazard unit that we are taking a jump.
		
		);
	
end controller;

architecture bhv of controller is
	
begin
	
	process(op_code, carry, overflow, sign, func)
	
	begin 
	         
		
		alu_op_code 	<= "000"; -- Addition by default.
		alu_b_mux_sel	<= '1'; -- Select output B from register file on default.
		branch 		  	<= '0'; -- Do not take the branch by default.
		branch_ne  		<= '0'; -- Do not take the branch not equal by default.
		data_mem_wren 	<= '0'; -- Do not write to memory by default.
		data_mux_sel  	<= "00"; -- Data comes from ALU to register file by default.
		dest_mux_sel  	<= "01"; -- Destination register code comes from bits 15 - 11 by default.
		inst_mem_en   	<= '1'; -- Read new instruction on by default.
		lui				<= '0'; -- Turn off shift by 16 by default.
		load_command    <= "00"; -- Load Word by default.
		pc_mux_sel     	<= "00"; -- New PC value comes from Branch mux => PC increment adder by default.
		pc_reg_en     	<= '1'; -- Turn on PC reg by default.
		reg_file_en     <= '0'; -- Turn off writing to reg file by default.
		store_command   <= "00"; -- Store Word by Default.
		sign_ext_sel  	<= '1'; -- Extend immediates signed by default.
		if_id_reg_en    <= '1';
		id_ex_reg_en    <= '1';
		ex_mem_reg_en   <= '1';
		mem_wb_reg_en   <= '1';
		read_en         <= '0';
		jmp_en          <= '0'; 
	
	
	case(op_code) is
		
		when "000000" => -- RTYPE
		
		    reg_file_en <= '1'; -- Enable writing to register file.
			alu_op_code <= "100"; -- RTYPE OP CODE for ALU DECODER
			
			if(func = "001000") then -- JR
				pc_mux_sel <= "10"; -- New PC value comes from ALU.
				jmp_en <= '1';
			end if;
		
		when "001000" => -- ADDI
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			alu_op_code <= "000"; -- Choose ADD for alu op.
			
		when "001001" => -- ADDIU
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			sign_ext_sel <= '0'; -- Extend with 0s.
			alu_op_code <= "000"; -- Choose ADD for alu op.
			
		when "001100" => -- ANDI
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			sign_ext_sel <= '0'; -- Extend with 0s.
			alu_op_code <= "011"; -- Choose AND for alu op.
		
		when "000101" => -- BNE
			alu_op_code <= "001"; -- Do subtract for bne.
			branch_ne <= '1'; -- Send a special signal to the ALU to 'not' the zero flag.
			branch <= '1'; -- If the zero flag is 1 and the branch is 1 then take the branch.
			
		when "000100" => -- BEQ
			alu_op_code <= "001"; -- Do subtract for bne.
			branch <= '1'; -- If the zero flag is 1 and the branch is 1 then take the branch.
			
		when "000011" => -- JAL
			data_mux_sel <= "10"; -- Data from PC+4 to register file.
			dest_mux_sel <= "10"; -- Choose R31 as destination for PC+4.
			--inst_mem_en <= '0'; -- Turn off reading new instruction.
			reg_file_en <= '1'; -- Enable writing to register file.
			pc_mux_sel <= "01"; -- New PC value comes from shift left jump.
			jmp_en <= '1';
			
		when "000010" => -- J
			pc_mux_sel <= "01"; -- New PC value comes from shift left jump.
			jmp_en <= '1';
			
		when "100011" => -- LW
			
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			data_mux_sel <= "01"; -- Data goes from data memory to register file.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			read_en <= '1'; -- Tells hazard unit we are loading.
			
			
		when "100100" => -- LBU
			
			load_command <= "10"; -- Read a byte from address in memory.
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			data_mux_sel <= "01"; -- Data goes from data memory to register file.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			read_en <= '1';
			
		when "100101" => -- LHU
			
			load_command <= "01"; -- Read a half word from address in memory.
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			data_mux_sel <= "01"; -- Data goes from data memory to register file.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			read_en <= '1';
			
		when "001111" => -- LUI
		
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			lui <= '1';	-- Enable shift output by 16 in the ALU.
			sign_ext_sel <= '0'; -- Extend with 0s
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16. 
			reg_file_en <= '1'; -- Enable writing to register file.		
			
		when "001101" => -- ORI
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			sign_ext_sel <= '0'; -- Extend with 0s.
			alu_op_code <= "010"; -- Choose OR for alu op.
			
		when "001010" => -- SLTI
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			alu_op_code <= "101"; -- Choose SLT for alu op.
			
		when "001011" => -- SLTIU
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			dest_mux_sel <= "00"; -- Destination register code comes from bits 20 - 16.
			reg_file_en <= '1'; -- Enable writing to register file.
			sign_ext_sel <= '0'; -- Extend with 0s.
			alu_op_code <= "110"; -- Choose OR for alu op.
			
		when "101011" => -- SW
		
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			data_mem_wren <= '1'; -- Write data to data memory from register file.
			
		when "101000" => -- SB
		
			store_command <= "10"; -- Write a byte to address in memory.
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			data_mem_wren <= '1'; -- Write data to data memory from the register file.
			
		when "101001" => -- SH
			
			store_command <= "01"; -- Write a half word to address in memory.
			alu_b_mux_sel <= '0'; -- Select the immediate value.
			data_mem_wren <= '1'; -- Write data to data memory from the register file.
		
			
			
		
		
		
		when others =>
				null;
		end case;
		
	end process;
	
	



end bhv;