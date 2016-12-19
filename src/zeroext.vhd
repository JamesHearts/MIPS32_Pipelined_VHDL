library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity zeroext is

	port (
		in0  : in std_logic_vector(15 downto 0);
		out0 : out std_logic_vector(31 downto 0)
		);

end zeroext;

architecture ZERO_EXT of zeroext is

begin

		out0 <= std_logic_vector(x"0000" & in0);

end ZERO_EXT;