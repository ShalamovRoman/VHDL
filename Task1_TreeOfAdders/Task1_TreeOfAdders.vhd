library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package array_package is
        type custom_array is array(natural range <>) of std_logic_vector; --Работает только в VHDL 2008
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.array_package.all;

entity Task1_TreeOfAdders is

	generic (N : positive := 3); 
	port 
	(
		arr: in  custom_array (1 to 8)(N - 1 downto 0);
		res: out integer
		
	);
	
end Task1_TreeOfAdders;

architecture rtl of Task1_TreeOfAdders is 

begin	

	process (arr) is
	
	variable sum11, sum12, sum13, sum14 : integer;
	variable sum21, sum22 : integer;
	
	begin

				sum11 := to_integer(signed(arr(1))) + to_integer(signed(arr(2))); --т.к. в задании говорилось 
				sum12 := to_integer(signed(arr(3))) + to_integer(signed(arr(4))); --про целые числа, то
				sum13 := to_integer(signed(arr(5))) + to_integer(signed(arr(6))); --предполагается, что подаются
				sum14 := to_integer(signed(arr(7))) + to_integer(signed(arr(8))); --битовые знаковые		
				
				sum21 := sum11 + sum12;
				sum22 := sum13 + sum14;
						
				res <= sum21 + sum22;

	end process;
end rtl;