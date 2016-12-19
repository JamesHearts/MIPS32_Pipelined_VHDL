library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_reg32 is
 
  port (
    Clk    : in  std_logic;
    clr    : in  std_logic;
    wr     : in  std_logic;
    D  : in  std_logic_vector(31 downto 0);
    Q : out std_logic_vector(31 downto 0));
end pc_reg32;

architecture BHV of pc_reg32 is
begin

  process(Clk, clr)
  begin
   
    if (clr = '1') then	-- Asynchronous Reset (Active-low).
	
      Q   <= x"00400000"; -- Output 32 Zeros if clr is asserted.
	  
    elsif (rising_edge(Clk)) then -- On a rising edge the register will load (Synchronous).
 
      if (wr = '1') then  -- A synchronous write enable. (Inside the clock check).
	  
        Q <= D; -- If write enable is true then we load the input to the output, otherwise the output remains unchanged.
		
      end if;
   
    end if;
   
  end process;
end BHV;