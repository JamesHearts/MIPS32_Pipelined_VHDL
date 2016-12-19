library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hazard_detection is
port
(
	ID_EX_rt, IF_ID_rs, IF_ID_rt, EX_MEM_rd, ID_EX_rd : in std_logic_vector(4 downto 0); --destinations and sources
	ID_EX_reg_file_en : in std_logic;
	read_en : in std_logic;
	read_en_mem : in std_logic;
	branch : in std_logic;
	branch_ex : in std_logic;
	alu_b_mux_sel : in std_logic;
	jmp_en : in std_logic;
	stall : out std_logic;
	stall_reg : out std_logic
);
end hazard_detection;

architecture BHV of hazard_detection is
begin
	process(jmp_en, alu_b_mux_sel, ID_EX_rt, IF_ID_rs, IF_ID_rt, EX_MEM_rd, ID_EX_rd, read_en, read_en_mem, branch, branch_ex)
	begin
		stall <= '0';
		stall_reg <= '0';
		
		-- -- if(branch = '1' and ID_EX_reg_file_en = '1') then --we need to stall
			-- -- if(read_en = '1') then --operation immediately following is a load so result goes in Rt
				-- -- if((unsigned(IF_ID_rs) = unsigned(ID_EX_rt)) or (unsigned(IF_ID_rt) = unsigned(ID_EX_rt))) then
					-- -- stall <= '1';
				-- -- end if;
			-- -- end if;
			
			-- -- if(read_en_mem = '1') then --operation 2 ahead is a load result in it's rt (this would be a second stall)
				-- -- if((unsigned(IF_ID_rs) = unsigned(EX_MEM_rd)) or (unsigned(IF_ID_rt) = unsigned(EX_MEM_rd))) then
					-- -- stall <= '1';
				-- -- end if;
			-- -- end if;
				
			
			-- -- if(read_en = '0') then --operation immediately following is not a load so result goes in Rd
				-- -- if(unsigned(IF_ID_rs) = unsigned(ID_EX_rd) or (unsigned(IF_ID_rt) = unsigned(ID_EX_rd))) then
					-- -- stall <= '1';
				-- -- end if;
			-- -- end if;
		-- -- end if;
		
		if (branch = '1' or branch_ex = '1') then
			stall <= '1';
		end if;
		
		if (jmp_en = '1') then
			stall <= '1';
		end if;
		
		if (read_en = '1') then
			if ((unsigned(ID_EX_rt) = unsigned(IF_ID_rs)) or (unsigned(ID_EX_rt) = unsigned(IF_ID_rt))) then
				--HAZARD. Time to stall
				stall <= '1';
				stall_reg <= '1';
			elsif((unsigned(ID_EX_rt) = unsigned(IF_ID_rs)) and alu_b_mux_sel = '0') then
				stall <= '1';
				stall_reg <= '1';
			end if;
		end if;
		
		
	end process;	
end BHV;