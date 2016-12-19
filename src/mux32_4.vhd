library ieee;
use ieee.std_logic_1164.all;

entity mux32_4 is

	
  port(
    in0    : in  std_logic_vector(31 downto 0); -- Input 0
    in1    : in  std_logic_vector(31 downto 0); -- Input 1
	in2	   : in  std_logic_vector(31 downto 0); -- Input 2
	in3    : in  std_logic_vector(31 downto 0); -- Input 3
    Sel    : in  std_logic_vector(1 downto 0); -- Select
    O : out std_logic_vector(31 downto 0) -- Output
	);
end mux32_4;


architecture MUX_32_4 of mux32_4 is

begin

process(Sel, in0, in1, in2, in3) -- Include all signals used in logic in the sensitivity list.

begin

	if(Sel = "00") then	
		O <= in0;
	elsif(Sel = "01") then 
		O <= in1;
	elsif(Sel = "10") then
		O <= in2;
	else
		O <= in3;
	end if;
	
end process;

end MUX_32_4;