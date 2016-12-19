library ieee;
use ieee.std_logic_1164.all;

entity mux1 is
	
  port(
    in0    : in  std_logic; --Input 0
    in1    : in  std_logic; --Input 1
    Sel    : in  std_logic; --Select
    O: out std_logic -- Output
	);
end mux1;


architecture MUX_1 of mux1 is

begin

process(Sel, in0, in1) -- Include all signals used in logic in the sensitivity list.

begin

	if(Sel = '0') then -- If Sel = 0 then we will select in0 as the output. Else, select in1 as the output.
		O <= in0;
	else
		O <= in1;
	end if;

end process;

end MUX_1;
