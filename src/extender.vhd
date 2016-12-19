library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity extender is

	port (
		in0  : in std_logic_vector(15 downto 0);
		Sel  : in std_logic;
		out0 : out std_logic_vector(31 downto 0)
		
		);

end extender;

architecture EXT of extender is

begin

process(in0, Sel)

begin

	if(Sel = '0') then
		out0 <= std_logic_vector(x"0000" & in0);
	else
		if(in0(15) = '1') then
			out0 <= std_logic_vector(x"FFFF" & in0);
		else
			out0 <= std_logic_vector(x"0000" & in0);
		end if;
	end if;
	
end process;

end EXT;