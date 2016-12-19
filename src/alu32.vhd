library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu32 is
generic (
			WIDTH : positive := 32);
	port (
		ia  		: in std_logic_vector(WIDTH-1 downto 0);
		ib 			: in std_logic_vector(WIDTH-1 downto 0);
		control  	: in std_logic_vector(3 downto 0);
		shamt		: in std_logic_vector(4 downto 0);
		shdir		: in std_logic;
		lui			: in std_logic;
		bne         : in std_logic;
		o 	: out std_logic_vector(WIDTH-1 downto 0);
		Z 	: out std_logic;
		S   : out std_logic;
		V	: out std_logic;
		C   : out std_logic
		);

end alu32;

architecture ALU of alu32 is

begin

	
process (ia, ib, control, shamt, shdir, lui, bne)

	variable temp_add : unsigned(WIDTH downto 0);
	variable temp_mult_unsigned : unsigned((WIDTH * 2)-1 downto 0);
	variable temp_mult_signed : signed((WIDTH * 2)-1 downto 0);
	variable temp_boolean : unsigned(WIDTH-1 downto 0);
	variable temp_shift : unsigned(WIDTH-1 downto 0);
	variable temp_shift_signed : signed(WIDTH-1 downto 0);
	variable temp_output : std_logic_vector(WIDTH-1 downto 0);
	variable temp_shamt : integer;
	variable temp_lui : unsigned(WIDTH downto 0);
	
	begin
	
	Z <= '0';
	V <= '0';
	C <= '0';
	S <= '0';
	o <= (others => '0');
	
		case control is
			
			when "0000" => --AND
				temp_boolean := unsigned(ia) and unsigned(ib);
				temp_output := std_logic_vector(temp_boolean);
				
			when "0001" => --OR
				temp_boolean := unsigned(ia) or unsigned(ib);
				temp_output := std_logic_vector(temp_boolean);
				
			when "0010" => --ADD
				
				temp_add := ('0' & unsigned(ia)) + ('0' & unsigned(ib));
				temp_output := std_logic_vector(temp_add(WIDTH-1 downto 0));
				
				if(lui = '1') then 
				
					temp_lui := shift_left(temp_add, 16);
					temp_output := std_logic_vector(temp_lui(WIDTH-1 downto 0));
				
				end if;
					
				
				C <= temp_add(32);
				
				if(ia(WIDTH-1) = '1' and ib(WIDTH-1) = '1') then
					if(temp_output(WIDTH-1) = '0') then
						V <= '1';
					end if;
				elsif(ia(WIDTH-1) = '0' and ib(WIDTH-1) = '0') then
					if(temp_output(WIDTH-1) = '1') then
						V <='1';
					end if;
				end if;
				
			when "0011" => --SHFT
			
				if(shdir = '0') then 
					
					temp_shift := shift_left(unsigned(ib), to_integer(unsigned(shamt)));
					temp_output := std_logic_vector(temp_shift);
				else
					temp_shift := shift_right(unsigned(ib), to_integer(unsigned(shamt)));
					temp_output := std_logic_vector(temp_shift);
				end if;
					
			when "0110" => --SUB
			
				temp_add:= ('0' & unsigned(ia)) + not('0' & unsigned(ib)) + 1;
				temp_output := std_logic_vector(temp_add(WIDTH-1 downto 0));
				
				if(ia(WIDTH-1) = '1' and ib(WIDTH-1) = '1') then
					if(temp_output(WIDTH-1) = '0') then
						V <= '1';
					end if;
				elsif(ia(WIDTH-1) = '0' and ib(WIDTH-1) = '0') then
					if(temp_output(WIDTH-1) = '1') then
						V <='1';
					end if;
				end if;
				
				C <= temp_add(32);
				
			when "0111" => -- SLT
			
				if(signed(ia) < signed(ib)) then 
					temp_output := x"00000001";
				else	
					temp_output := x"00000000";
				end if;
				
			when "1100" => -- NOR
				temp_boolean := not(unsigned(ia) or unsigned(ib));
				temp_output := std_logic_vector(temp_boolean);
				
			when "1111" => -- SLTU
				if(unsigned(ia) < unsigned(ib)) then 
					temp_output := x"00000001";
				else	
					temp_output := x"00000000";
				end if;
			
			when others =>
			
				temp_output := x"00000000";
		
		end case;
		
	o <= temp_output;
		
	if(unsigned(temp_output) = 0) then
		if(bne = '1') then
			Z <= '0';
		else
			Z <= '1';
		end if;
	else 
		if(bne = '1') then
			Z <= '1';
		else
			Z <= '0';
		end if;
	end if;
	
	if(temp_output(31) = '1') then
		S <= '1';
	else	
		S <= '0';
	end if;
		
end process;

end ALU;
