library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
  port(
		clk : in std_logic;
		div_clk : out std_logic
	);
end clk_divider;


architecture SEQ of clk_divider is

	signal clk_counter : unsigned(1 downto 0) := "00";
	signal div_clk_temp : std_logic := clk;
	
begin

--Create the clock enable:
process(clk)
begin

  if(rising_edge(clk)) then
  
    clk_counter <= clk_counter + 1;
	
    if(clk_counter = "10") then
      div_clk_temp <= div_clk_temp xor '1'; 
	  clk_counter <= (others => '0');
    end if;
  end if;
  
  div_clk <= div_clk_temp;
  
end process;
end SEQ;