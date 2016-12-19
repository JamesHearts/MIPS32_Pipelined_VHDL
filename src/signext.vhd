library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signext is

	port (
		in0  : in std_logic_vector(15 downto 0);
		out0 : out std_logic_vector(31 downto 0)
		
		);

end signext;

architecture SIGN_EXT of signext is

begin

	process(in0)

	begin

		if(in0(15) = '1') then
			out0 <= x"FFFF" & in0;
		else	
			out0 <= x"0000" & in0;
		end if;

	end process;

end SIGN_EXT;