library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_package.all;

entity test is end entity;

architecture rtl of test is

	constant N1 : integer := 4;
	constant N2 : integer := 3;
	signal arr1 : custom_array (1 to 8)(N1 - 1 downto 0);
	signal arr2 : custom_array (1 to 8)(N2 - 1 downto 0);
	signal res1 : integer;
	signal res2 : integer;
	
begin
	
	DUT1 : entity work.Task1_TreeOfAdders 
	generic map (N => N1)
	port map (arr => arr1, res => res1);
	 
	process is 

	begin
		
		arr1(1) <= "0001";
		arr1(2) <= "0011";
		arr1(3) <= "1001";
		arr1(4) <= "0001";
		arr1(5) <= "0010";
		arr1(6) <= "0010";
		arr1(7) <= "0001";
		arr1(8) <= "0001";
		
		wait for 5ns;
		
		arr1(1) <= "1000";
		arr1(2) <= "0101";
		arr1(3) <= "0111";
		arr1(4) <= "1000";
		arr1(5) <= "0011";
		arr1(6) <= "0010";
		arr1(7) <= "0001";
		arr1(8) <= "0001";
		
		wait for 5ns;

	end process;
	
	DUT2 : entity work.Task1_TreeOfAdders 
	generic map (N => N2)
	port map (arr => arr2, res => res2);
	 
	process is 
	variable temp_arr : custom_array (1 to 8)(N2 - 1 downto 0);
	begin
		
		arr2(1) <= "101";
		arr2(2) <= "011";
		arr2(3) <= "100";
		arr2(4) <= "001";
		arr2(5) <= "010";
		arr2(6) <= "000";
		arr2(7) <= "001";
		arr2(8) <= "111";
		
		wait for 5ns;
		
		arr2(1) <= "000";
		arr2(2) <= "100";
		arr2(3) <= "001";
		arr2(4) <= "001";
		arr2(5) <= "111";
		arr2(6) <= "001";
		arr2(7) <= "000";
		arr2(8) <= "000";
		
		wait for 5ns;

	end process;
end rtl;	