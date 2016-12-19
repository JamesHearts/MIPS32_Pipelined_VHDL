library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity forward is
generic (
			WIDTH : positive := 32);
	port (
		
			EX_MEM_rd, MEM_WR_rd : in std_logic_vector(4 downto 0);
			EX_MEM_reg_file_en, MEM_WR_reg_file_en : in std_logic; 
	
			ID_EX_rs, ID_EX_rt: in std_logic_vector(4 downto 0);
			IF_ID_rs, IF_ID_rt : in std_logic_vector(4 downto 0);
			
			fwd_b_sel : out std_logic_vector(1 downto 0);
			fwd_a_sel : out std_logic_vector(1 downto 0);
			rafm_sel : out std_logic_vector(1 downto 0);
			rbfm_sel : out std_logic_vector(1 downto 0)
		
		);

end forward;

architecture BHV of forward is

	

begin
		
			process(EX_MEM_rd, MEM_WR_rd, EX_MEM_reg_file_en, MEM_WR_reg_file_en, ID_EX_rs, ID_EX_rt, IF_ID_rs, IF_ID_rt)
			
			begin
			
			fwd_a_sel <= "00";
			fwd_b_sel <= "00";
			rafm_sel <= "00";
			rbfm_sel <= "00";
			
			if(EX_MEM_reg_file_en = '1') then
				--forwards from the EX_MEM register to the ALU inputs
				if(unsigned(EX_MEM_rd) = unsigned(ID_EX_rs)) then
					fwd_a_sel <= "10";
				end if;
				if(unsigned(EX_MEM_rd) = unsigned(ID_EX_rt)) then
					fwd_b_sel <= "10";
				end if;
				
				if(unsigned(EX_MEM_rd) = unsigned(IF_ID_rs)) then
					rafm_sel <= "10";
				--end if;
				elsif(unsigned(MEM_WR_rd) = unsigned(IF_ID_rs)) then
					fwd_a_sel <= "10";
				end if;
				if(unsigned(EX_MEM_rd) = unsigned(IF_ID_rt)) then
					rbfm_sel <= "10";
				--end if;
				elsif(unsigned(MEM_WR_rd) = unsigned(IF_ID_rt)) then
					fwd_b_sel <= "10";
				end if;			
			elsif(MEM_WR_reg_file_en = '1') then
				--forwards from the WB_stage to the ALU inputs
				if(unsigned(MEM_WR_rd) = unsigned(ID_EX_rs)) then
					fwd_a_sel <= "01";
				end if;
				
				if(unsigned(MEM_WR_rd) = unsigned(ID_EX_rt)) then
					fwd_b_sel <= "01";
				end if;
				
				if(unsigned(MEM_WR_rd) = unsigned(IF_ID_rs)) then
					rafm_sel <= "01";
				end if;
				
				if(unsigned(MEM_WR_rd) = unsigned(IF_ID_rt)) then
					rbfm_sel <= "01";
				end if;	
			end if;
			
			end process;

	
end BHV;