library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_control is --This controller is used to control the datapath.

	generic (
		width  :     positive := 32);
	port(	
		wren 			: in std_logic;
		address         : in std_logic_vector(7 downto 0);
		store_command   : in std_logic_vector(1 downto 0);
		load_command    : in std_logic_vector(1 downto 0);
		address_bits    : out std_logic_vector(5 downto 0);
		data_mem_wren_1 : out std_logic;
		data_mem_wren_2 : out std_logic;
		data_mem_wren_3 : out std_logic;
		data_mem_wren_4 : out std_logic;
		store_mux_sel_1 : out std_logic_vector(1 downto 0);
		store_mux_sel_2 : out std_logic_vector(1 downto 0);
		store_mux_sel_3 : out std_logic_vector(1 downto 0);
		store_mux_sel_4 : out std_logic_vector(1 downto 0);
		load_mux_sel    : out std_logic_vector(2 downto 0)
		);
	
end data_control;

architecture bhv of data_control is
	
	signal enable_bits : std_logic_vector(1 downto 0);
	
begin
	
	process(address, store_command, load_command, wren, enable_bits)
	
	begin 
	         
		data_mem_wren_1 <= '0';
		data_mem_wren_2 <= '0';
		data_mem_wren_3 <= '0';
		data_mem_wren_4 <= '0';
		store_mux_sel_1 <= "00";
		store_mux_sel_2 <= "00";
		store_mux_sel_3 <= "00";
		store_mux_sel_4 <= "00";
		load_mux_sel <= "000"; -- Output all bytes incase.
	
	case(enable_bits) is
		
		when "00" => -- Word, Half Word, Byte
			if(load_command = "00") then -- LW
				load_mux_sel <= "000";
			elsif(load_command = "01") then -- LHU
				load_mux_sel <= "001";
			elsif(load_command = "10") then -- LBU
				load_mux_sel <= "011";
			end if;
		
			if(wren = '1') then 
				if(store_command = "00") then    -- Word
					data_mem_wren_1 <= '1';
					data_mem_wren_2 <= '1';
					data_mem_wren_3 <= '1';
					data_mem_wren_4 <= '1';
					
				elsif(store_command = "01") then -- Half Word
					data_mem_wren_1 <= '1';
					data_mem_wren_2 <= '1';
					store_mux_sel_1 <= "01"; 
					store_mux_sel_2 <= "01";
				else							 -- Byte
					data_mem_wren_1 <= '1';
					store_mux_sel_1 <= "10";
				end if;
			end if;
		
		
		when "01" => -- Byte
			
			load_mux_sel <= "100";
			
			if(wren = '1') then 
				data_mem_wren_2 <= '1'; -- Byte
				store_mux_sel_2 <= "10";
			end if;
			
		when "10" => -- Half Word, Byte
			
			if(load_command = "01") then -- LHU
				load_mux_sel <= "010";
			else
				load_mux_sel <= "101";
			end if;
			
			if(wren = '1') then
				if(store_command = "01") then -- Half Word
					data_mem_wren_3 <= '1';
					data_mem_wren_4 <= '1';
					store_mux_sel_3 <= "01";
					store_mux_sel_4 <= "01";
				else						  -- Byte
					data_mem_wren_3 <= '1';
					store_mux_sel_3 <= "10";
				end if;
			end if;
			
		when "11" =>
			
			load_mux_sel <= "110";
			
			if(wren = '1') then 
				data_mem_wren_4 <= '1'; -- Byte
				store_mux_sel_4 <= "10";
			end if;
			
		when others =>
				null;
		end case;
		
	end process;
	

	enable_bits <= address(1 downto 0); -- These bits enable the correct ram.
	address_bits <= address(7 downto 2); -- These bits right to the correct memory in that ram.



end bhv;