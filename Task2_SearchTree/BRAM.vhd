library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.customData.all;

entity BRAM is
  generic 
  (
    addrWidth : integer := 10;
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
end entity;

architecture rtl of BRAM is

 type ramType is array (0 to 1023) of nodeType;
 signal ramPort : ramType;

begin
	process(clk) is
	begin 
		if (clk'event and clk = '1') then
			if (we = '1') then
			  ramPort(to_integer(unsigned(addr))) <= din;
			end if;
			  dout <= ramPort(to_integer(unsigned(addr))); --I don’t know why it doesn’t work
		end if;
	end process;

end rtl;