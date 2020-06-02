library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

package customData is

	type nodeType is record
		keyV :  unsigned(31 downto 0);
		dataV : std_logic_vector(63 downto 0);
		valid : std_logic;
	end record nodeType;

end customData;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.customData.all;

entity Task2_SearchTree is

	generic 
	(
		addrWidth : integer := 32;
		dataWidth : integer := 64 
	);

	port 
	(
		rst, clk : in std_logic;
		
		input : in nodeType;
		
		add : in std_logic;
		find : in std_logic;
		
		done : out std_logic;
		found : out std_logic
		
	);
	
end entity;

architecture rtl of Task2_SearchTree is

	component BRAM
		generic 
		(
			addrWidth : integer := 32;
			dataWidth : integer := 64 
		);
		port
		(
			clk: in std_logic;
			we : in std_logic;
			addr : in std_logic_vector(addrWidth - 1 downto 0);
			din : in nodeType; 
			dout : out nodeType
		);		
	end component BRAM;

	 type statetypes is 
	 (
		Start,
		SendAddrToRam,
		GetRAMData,
		SearchNode,
		Finish
	 );
			
	signal weL : std_logic;     
   signal addrL: std_logic_vector(addrWidth - 1 downto 0);  
	signal dinL : nodeType;
	signal doutL  : nodeType;
	signal inputL : nodeType;	
	signal currIndex : integer := 0;
	signal currentState : statetypes := Start; --,nextState     	
	signal addL, findL : std_logic := '0';
	
begin	

memory_component : BRAM 

	generic map 
	( 
		addrWidth => addrWidth,
		dataWidth => dataWidth
	)
	port map 
	(
		clk => clk, 
		we => weL,
		addr => addrL, 
		din => dinL,
		dout => doutL
	);

process (clk, rst) is

variable currentIndexVar : integer := 0;

begin 
	if (clk'event and clk = '1') then
		
		if (rst = '1') then
		
			weL <= '0';
			addrL <= (others => '0');
			dinL <= (keyV => (others => '0'), dataV => (others => '0'), valid => '0');			
			currentState <= Start;
			done <= '0';
			found <= '0';
			addL <= '0';
			findL <= '0';
			currIndex <= 0;
			
		end if;
		
		if (rst = '0') then
		
			case currentState is
			
				when Start =>
					
					if ((add = '1' or find = '1') and input.valid = '1') then
					
						if (add = '1') then
							addL <= '1';
						end if;
						if (find = '1') then
							findL <= '1';
						end if;
						
						inputL <= input;
						currIndex <= 0;
						currentState <= SendAddrToRam;
					end if;
				
				when SendAddrToRam => 
				
					addrL <= std_logic_vector(to_unsigned(currIndex, addrWidth));
					currentState <= GetRAMData;
				
				when GetRAMData => 
					
					if (addL = '1' or findL = '1') then
						currentState <= SearchNode;
					end if;
					
				when SearchNode =>
					currentIndexVar := currIndex;			
					if (doutL.Valid = '1') then 
						if (inputL.keyV > doutL.keyV) then    --right subtree
							currIndex <= 2*currentIndexVar + 2;
							currentState <= SendAddrToRam;
						elsif (inputL.keyV < doutL.keyV) then --left subtree
							currIndex <= 2*currentIndexVar + 1;
							currentState <= SendAddrToRam;		
						else
							if (addL = '1') then
								weL <= '1';
								dinL <= input;
								currentState <= Finish;
							elsif (findL = '1') then
								found <= '1';
								currentState <= Finish;
							end if;
						end if;
					else										--no root
							if (addL = '1') then
								weL <= '1';
								dinL <= input;
								currentState <= Finish;
								done <= '1';
							elsif (findL = '1') then
								found <= '0';
								currentState <= Finish;
								done <= '1';
							end if;
					end if;	
					
				when Finish =>
				
					weL <= '0';
					done <= '0';
					currIndex <= 0;
					addrL <= (others => '0');
					inputL <= (keyV => (others => '0'), dataV => (others => '0'), valid => '0');
					addL <= '0';
					findL <= '0';
					
					currentState <= Start;				
			end case;
		end if;
	end if;
end process;
	
end rtl;	