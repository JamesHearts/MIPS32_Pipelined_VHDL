library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity leftshift26 is
generic (
			WIDTH : positive := 32);
	port (
		input  : in std_logic_vector(25 downto 0);
		output : out std_logic_vector(27 downto 0)
		
		);

end leftshift26;

architecture SHIFTLEFT of leftshift26 is

	

begin
	
		output <= std_logic_vector(shift_left(unsigned("00" & input), 2));
	
end SHIFTLEFT;