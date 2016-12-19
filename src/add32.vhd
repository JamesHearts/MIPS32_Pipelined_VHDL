library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add32 is

generic (
    WIDTH  :     positive := 32);
	
  port(
    in0    : in  std_logic_vector(WIDTH-1 downto 0);
	in1    : in	 std_logic_vector(WIDTH-1 downto 0);
    sum    : out std_logic_vector(WIDTH-1 downto 0)
	);
end add32;


architecture ADD of add32 is

begin

		sum <= std_logic_vector(unsigned(in0) + unsigned(in1));
	
end ADD;