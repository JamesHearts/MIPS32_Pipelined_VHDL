library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branchlogic is
generic (
			WIDTH : positive := 32);
	port (
		
		Z			  : in std_logic;
		branch        : in std_logic;
		output 		  : out std_logic
		
		);

end branchlogic;

architecture BHV of branchlogic is

	

begin
		
		output <= (Z and branch);

	
end BHV;