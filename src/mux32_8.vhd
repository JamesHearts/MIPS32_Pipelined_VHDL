library ieee;
use ieee.std_logic_1164.all;

entity mux32_8 is
	generic (
		width  :     positive := 32);
	
  port(
    in0    : in  std_logic_vector(width-1 downto 0); -- Input 0
    in1    : in  std_logic_vector(width-1 downto 0); -- Input 1
	in2    : in  std_logic_vector(width-1 downto 0); -- Input 2
	in3    : in  std_logic_vector(width-1 downto 0); -- Input 3
	in4    : in  std_logic_vector(width-1 downto 0); -- Input 4
	in5    : in  std_logic_vector(width-1 downto 0); -- Input 5
	in6    : in  std_logic_vector(width-1 downto 0); -- Input 6
	in7    : in  std_logic_vector(width-1 downto 0); -- Input 7
    Sel    : in  std_logic_vector(2 downto 0); -- Select
    O : out std_logic_vector(width-1 downto 0) -- Output
	);
end mux32_8;


architecture MUX_32_8 of mux32_8 is

begin

process(Sel, in0, in1, in2, in3, in4, in5, in6, in7) -- Include all signals used in logic in the sensitivity list.

begin

	if(Sel = "000") then	
		O <= in0;
	elsif(Sel = "001") then 
		O <= in1;
	elsif(Sel = "010") then
		O <= in2;
	elsif(Sel = "011") then
		O <= in3;
	elsif(Sel = "100") then
		O <= in4;
	elsif(Sel = "101") then
		O <= in5;
	elsif(Sel = "110") then
		O <= in6;
	else
		O <= in7;
	end if;
	
end process;

end MUX_32_8;