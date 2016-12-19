library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is -- This datapath will be used with a controller.

	generic (
		width  :     positive := 32);
	port(
			mem_clk          : in std_logic;
			address          : in std_logic_vector(7 downto 0); -- 8 bit address input.
			data			 : in std_logic_vector(Width-1 downto 0); -- 32 bit data input.
			wren			 : in std_logic; -- Main wren.
			store_command    : in std_logic_vector(1 downto 0); 
			load_command     : in std_logic_vector(1 downto 0);
			q				 : out std_logic_vector(Width-1 downto 0) -- 32 bit output.
		);
	
end data_memory;

architecture str of data_memory is
	
	signal address_bits_n 	 : std_logic_vector(5 downto 0);
	signal data_mem_wren_1_n : std_logic;
	signal data_mem_wren_2_n : std_logic;
	signal data_mem_wren_3_n : std_logic;
	signal data_mem_wren_4_n : std_logic;
	signal load_mux_sel_n    : std_logic_vector(2 downto 0);
	signal store_mux_sel_1_n : std_logic_vector(1 downto 0);
	signal store_mux_sel_2_n : std_logic_vector(1 downto 0);
	signal store_mux_sel_3_n : std_logic_vector(1 downto 0);
	signal store_mux_sel_4_n : std_logic_vector(1 downto 0);
	signal store_mux_out_1_n : std_logic_vector(7 downto 0);
	signal store_mux_out_2_n : std_logic_vector(7 downto 0);
	signal store_mux_out_3_n : std_logic_vector(7 downto 0);
	signal store_mux_out_4_n : std_logic_vector(7 downto 0);
	signal data_mem_out_1_n : std_logic_vector(7 downto 0);
	signal data_mem_out_2_n : std_logic_vector(7 downto 0);
	signal data_mem_out_3_n : std_logic_vector(7 downto 0);
	signal data_mem_out_4_n : std_logic_vector(7 downto 0);
	
	signal load_word   : std_logic_vector(width-1 downto 0);
	signal load_half_1 : std_logic_vector(width-1 downto 0);
	signal load_half_2 : std_logic_vector(width-1 downto 0);
	signal load_byte_1 : std_logic_vector(width-1 downto 0);
	signal load_byte_2 : std_logic_vector(width-1 downto 0);
	signal load_byte_3 : std_logic_vector(width-1 downto 0);
	signal load_byte_4 : std_logic_vector(width-1 downto 0);
	
	

begin

	DATA_MEM_CONT: entity work.data_control
		port map(
			wren             => wren,
			address          => address,
			address_bits     => address_bits_n,
			store_command    => store_command,
			load_command     => load_command,
			data_mem_wren_1  => data_mem_wren_1_n, 
			data_mem_wren_2  => data_mem_wren_2_n,
			data_mem_wren_3  => data_mem_wren_3_n,
			data_mem_wren_4  => data_mem_wren_4_n,
			store_mux_sel_1  => store_mux_sel_1_n,
			store_mux_sel_2  => store_mux_sel_2_n,
			store_mux_sel_3  => store_mux_sel_3_n,
			store_mux_sel_4  => store_mux_sel_4_n,
			load_mux_sel     => load_mux_sel_n
		);
		
	DATA_MEM_1 : entity work.data_mem_block
		port map(
			address	=>  address_bits_n(5 downto 0),
			clock	=>	mem_clk,
			data	=>  store_mux_out_1_n,
			wren	=>	data_mem_wren_1_n,
			q		=>  data_mem_out_1_n
		);
		
	DATA_MEM_2 : entity work.data_mem_block
		port map(
			address	=>  address_bits_n(5 downto 0),
			clock	=>	mem_clk,
			data	=>  store_mux_out_2_n,
			wren	=>	data_mem_wren_2_n,
			q		=>  data_mem_out_2_n
		);
		
	DATA_MEM_3 : entity work.data_mem_block
		port map(
			address	=>  address_bits_n(5 downto 0),
			clock	=>	mem_clk,
			data	=>  store_mux_out_3_n,
			wren	=>	data_mem_wren_3_n,
			q		=>  data_mem_out_3_n
		);
		
	DATA_MEM_4 : entity work.data_mem_block
		port map(
			address	=>  address_bits_n(5 downto 0),
			clock	=>	mem_clk,
			data	=>  store_mux_out_4_n,
			wren	=>	data_mem_wren_4_n,
			q		=>  data_mem_out_4_n
		);
		
	-- Stores data in little endian, least significant bit first.
		
	STORE_MUX_1 : entity work.mux8_4
		port map(
			in0     => data(7 downto 0), -- Word 1st Byte
			in1     => data(7 downto 0), -- Halfword Start,
			in2     => data(7 downto 0), -- Byte
			in3		=> data(7 downto 0), -- Byte
			Sel     => store_mux_sel_1_n,
			O 	    => store_mux_out_1_n
	);
	
	STORE_MUX_2 : entity work.mux8_4
		port map(
			in0     => data(15 downto 8), -- Word 2nd Byte
			in1     => data(15 downto 8), -- Halfword End,
			in2     => data(7 downto 0), -- Byte
			in3		=> data(7 downto 0), -- Byte
			Sel     => store_mux_sel_2_n,
			O 	    => store_mux_out_2_n
	);
	
	STORE_MUX_3 : entity work.mux8_4
		port map(
			in0     => data(23 downto 16), -- Word 3rd Byte
			in1     => data(7 downto 0), -- Halfword Start,,
			in2     => data(7 downto 0), -- Byte
			in3		=> data(7 downto 0), -- Byte
			Sel     => store_mux_sel_3_n,
			O 	    => store_mux_out_3_n
	);
	
	STORE_MUX_4 : entity work.mux8_4
		port map(
			in0     => data(Width-1 downto 24),
			in1     => data(15 downto 8), -- Halfword End,,
			in2     => data(7 downto 0), -- Byte
			in3		=> data(7 downto 0), -- Byte
			Sel     => store_mux_sel_4_n,
			O 	    => store_mux_out_4_n
	);
	
	LOAD_MUX : entity work.mux32_8 -- For loading half word, word and byte
		port map(
			in0     => load_word,
			in1     => load_half_1,
			in2     => load_half_2,
			in3		=> load_byte_1,
			in4     => load_byte_2,
			in5     => load_byte_3,
			in6     => load_byte_4,
			in7     => load_byte_4,
			Sel     => load_mux_sel_n,
			O 	    => q
		);
	
	load_word <= data_mem_out_4_n & data_mem_out_3_n & data_mem_out_2_n & data_mem_out_1_n;
	load_half_1 <= x"0000" & data_mem_out_2_n & data_mem_out_1_n;
	load_half_2 <= x"0000" & data_mem_out_4_n & data_mem_out_3_n;
	load_byte_1 <= x"000000" & data_mem_out_1_n;
	load_byte_2 <= x"000000" & data_mem_out_2_n;
	load_byte_3 <= x"000000" & data_mem_out_3_n;
	load_byte_4 <= x"000000" & data_mem_out_4_n;
		
end str;