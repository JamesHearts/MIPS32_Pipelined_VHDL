library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu32control is --This decoder determines the select value of the ALU.

	generic (
		width  :     positive := 32);
	port(	
		
			func        : in std_logic_vector(5 downto 0);
			ALUop       : in std_logic_vector(2 downto 0);
			control     : out std_logic_vector(3 downto 0);
			shdir       : out std_logic
		);
	
end alu32control;

architecture bhv of alu32control is

begin

	
	process(ALUop, func)
	
	begin 
	shdir <= '0';

	control <= (others => '0');
	
	case(ALUop) is

		when "000" => -- ADD non R_Type
			control <= "0010";
		when "001" => -- SUB non R_Type
			control <= "0110";
		when "010" => -- OR non R_Type
			control <= "0001";
		when "011" => -- AND non R_Type
			control <= "0000";
		when "100" => -- R_Type
		
			case(func) is
				
				when "000000" => -- SLL
					control <= "0011";
					shdir <= '0';
				when "000010" => -- SRL
					control <= "0011";
					shdir <= '1';
				when "001000" => -- JR
					control <= "0010";
				when "100000" => -- ADD
					control <= "0010";
				when "100001" => -- ADDU
					control <= "0010";
				when "100010" => -- SUB
					control <= "0110";
				when "100011" => -- SUBU
					control <= "0110";
				when "100100" => -- AND
					control <= "0000";
				when "100101" => -- OR
					control <= "0001";
				when "100111" => -- NOR
					control <= "1100";
				when "101010" => -- SLT
					control <= "0111";
				when "101011" => -- SLTU
					control <= "1111";
				when others =>
					control <= "0000";
				null;
				
				end case;
				
		when "101" => -- SLT non R_Type
			control <= "0111";
		when "110" => -- SLTU non R_Type
			control <= "1111";
		
		when others =>
			control <= "0000";
			
		end case;
		
	end process;
	
	



end bhv;