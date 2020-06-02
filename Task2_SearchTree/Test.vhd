library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use work.customData.all;
   
entity Test is end entity;

architecture rtl of Test is
		
		signal rst, clk : std_logic;
		
		signal input : nodeType;
		signal add : std_logic;
		signal find : std_logic;
		
		signal done : std_logic;
		signal found : std_logic;
		

procedure delay ( n : integer; signal clk : std_logic ) is begin
	for i in 1 to n loop
		wait until rising_edge(clk);
	end loop;
end delay;
	
begin

	DUT : entity work.Task2_SearchTree
	port map
	(
		clk => clk, 
		rst => rst, 
		input => input,
		add => add, 
		find => find, 
		done => done, 
		found => found
	);
	
	process is begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;

	process is begin 
		rst <= '0';
		wait; --for 100 ns; (testing)
--		rst <= '1';
--		wait for 100ns;
	end process;
	
	process is 	
		variable tmpInp1, tmpInp2, tmpInp3 : integer := 0;
		variable tmpInpCov1 : unsigned (31 downto 0);
	begin
	
		delay(2,clk);
		
		--add Test
		add <= '1';
		tmpInp1 := 3;
		tmpInp2 := 1;
		input <= (keyV => to_unsigned(tmpInp1,32), dataV => std_logic_vector(to_unsigned(tmpInp2,64)), valid => '1'); --root
		delay(1,clk);
		add <= '0';
		
		delay(10,clk);
		add <= '1';
		tmpInp1 := 5;
		tmpInp2 := 2;
		input <= (keyV => to_unsigned(tmpInp1,32), dataV => std_logic_vector(to_unsigned(tmpInp2,64)), valid => '1'); --right lvl1
		delay(1,clk);
		add <= '0';
		
		delay(10,clk);
		add <= '1';
		tmpInp1 := 10;
		tmpInp2 := 44;
		input <= (keyV => to_unsigned(tmpInp1,32), dataV => std_logic_vector(to_unsigned(tmpInp2,64)), valid => '1'); --right right lvl2		
		delay(1,clk);
		add <= '0';
		
		delay(10,clk);
		add <= '1';
		tmpInp1 := 1;
		tmpInp2 := 44;
		input <= (keyV => to_unsigned(tmpInp1,32), dataV => std_logic_vector(to_unsigned(tmpInp2,64)), valid => '1'); --left lvl1
		delay(1,clk);
		add <= '0';
		
		delay(10,clk);
		add <= '1';
		tmpInp1 := 4;
		tmpInp2 := 20;
		input <= (keyV => to_unsigned(tmpInp1,32), dataV => std_logic_vector(to_unsigned(tmpInp2,64)), valid => '1'); --right left lvl2
		delay(1,clk);
		add <= '0';
		
		--find Test
		delay(10,clk);
		find <= '1';
		input <= (keyV => to_unsigned(tmpInp1,32), dataV => std_logic_vector(to_unsigned(0,64)), valid => '1'); --true
		delay(1,clk);
		find <= '0';
		
		delay(10,clk);
		find <= '1';
		tmpInp1 := 8;
		tmpInp2 := 0;
		input <= (keyV => to_unsigned(tmpInp1,32), dataV => std_logic_vector(to_unsigned(tmpInp2,64)), valid => '1'); --false
		delay(1,clk);
		find <= '0';
		
		wait;
	end process;			
end rtl;
