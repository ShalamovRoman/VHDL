library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

package customData is
 	constant maxint : integer := 16#ffff#;
	--coefficients are taken randomly but there are ways to choose them more correctly
   constant Kp : std_logic_vector (15 downto 0) := "0000000000000101";		--proportional constant := 5
	constant Ki : std_logic_vector (15 downto 0) := "0000000000000001";		--integral constant := 1
   constant Kd : std_logic_vector (15 downto 0) := "0000000000001010";		--differential constant := 10
	constant setPoint : integer := 500; --point to which the PID tries to reach
	
	type customOutputType is record
		outputVal :  std_logic_vector (15 downto 0); --manipulated value
		inputVal : std_logic_vector (15 downto 0); --measurement
		inputValid : std_logic; --check if data is valid (instead using "UUUU")
		previousErrVal : std_logic_vector (15 downto 0); --previous measurement error 
	end record customOutputType;

end customData;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.customData.all;

entity Task3_PID_Controller is 

	port 
	(
		in_tvalid : in std_logic; --generator has input data in current tact
		in_tdata : in std_logic_vector (15 downto 0); --8.8 fixpoint notation
		in_tready : out std_logic; --pipe can get data next tact
		out_tvalid : out std_logic; --pipe has data to send in current tact
		out_tdata : out customOutputType; 
		out_tready : in std_logic; --reciever can get data next tact
		clk : in std_logic
	);
	
end entity;

architecture rtl of Task3_PID_Controller is

	signal P1,P2,P3 : integer := 0; --Proportional, Derivative, Integral errors
	signal I1,I2 : integer := 0; 	  --the number of signals due to the need to
	signal D1 : integer := 0; 	  	  --drag them to output
	signal sum : integer := 0; --coeff sum
	signal inp1, inp2, inp3, inp4 : customOutputType; --drug input to output
	signal currentError1, currentError2 : integer := 0; --contains the deviation of the input from the setPoint
	signal tempSum1, currErrOldErrDiff, currErrOldErrDiff2 : integer := 0; --to reduce critical path
	
begin	
	--recieve data when reciever is ready
	in_tready <= out_tready;
	
	process(inp1,clk) is begin
		if (clk'event) and (clk = '1') then 
			if (out_tready = '1') then
				inp2 <= inp1;
			end if;
		end if;
	end process;
	
	process(inp2,clk) is begin
	if (clk'event) and (clk = '1') then
		if (out_tready = '1') then
			inp3 <= inp2;
		end if;
	end if;
	end process;
	
	process(inp3,clk) is begin
	if (clk'event) and (clk = '1') then
		if (out_tready = '1') then
			inp4 <= inp3;
		end if;
	end if;
	end process;
	
	process(P1,clk) is 
	begin
	if (clk'event) and (clk = '1') then
		if (out_tready = '1') then
			P2 <= P1;			
			I1 <= to_integer(signed(Ki))*currErrOldErrDiff2;--(currentError1 + currentError2); --dt=1
			currErrOldErrDiff <= currentError1 - currentError2;
		end if;
	end if;
	end process;
	
	process(P2,clk) is begin
	if (clk'event) and (clk = '1') then
		if (out_tready = '1') then
			P3 <= P2;
		end if;
	end if;
	end process;

	process(I1,clk) is begin
	if (clk'event) and (clk = '1') then
		if (out_tready = '1') then
			I2 <= I1;
			tempSum1 <= I1 + P2;
			D1 <= to_integer(signed(Kd))*currErrOldErrDiff;
		end if;
	end if;
	end process;
	
	process(D1, clk) is 
		variable tmp : integer := 0;
	begin 
		if (clk'event) and (clk = '1') then
			if (out_tready = '1') then
				sum <= tempSum1 + D1;
			end if;
		end if;
	end process;
	
	process(sum,clk) is 
		variable outputConverted : std_logic_vector (15 downto 0);
		variable oldErrorConverted, oldError6Converted, oldError5Converted : std_logic_vector (15 downto 0);
		variable sumVar : integer := 0;
		variable inp4DataVar : std_logic_vector (15 downto 0);
		
	begin
	if (clk'event) and (clk = '1') then
			if (out_tready = '1') then
				if (inp4.inputValid = '1') then --if ready to send check for valid data
					inp4DataVar := inp4.inputVal;
					--check output for 16-bit range
					sumVar := sum;
					if (sumVar > 32767*256) then
							 outputConverted := std_logic_vector(to_signed(32767 ,16)) ;
					elsif (sumVar < -32768*256) then 
							 outputConverted := std_logic_vector(to_signed(-32768 ,16));
					else
						outputConverted := std_logic_vector(to_signed(sumVar/256 ,16));	
					end if;
					
					out_tvalid <= '1';
					out_tdata.outputVal <= outputConverted;
					out_tdata.inputVal <= inp4DataVar;
					out_tdata.previousErrVal <= inp4.previousErrVal;
					out_tdata.inputValid <= '1';
				else 
					out_tvalid <= '0';
					out_tdata.outputVal <= "UUUUUUUUUUUUUUUU";
					out_tdata.inputVal <= "UUUUUUUUUUUUUUUU";
					out_tdata.previousErrVal <= "UUUUUUUUUUUUUUUU";
					out_tdata.inputValid <= '0';
				end if;
			else 
				out_tvalid <= '0';
				out_tdata.outputVal <= "UUUUUUUUUUUUUUUU";
				out_tdata.inputVal <= "UUUUUUUUUUUUUUUU";
				out_tdata.previousErrVal <= "UUUUUUUUUUUUUUUU";
				out_tdata.inputValid <= '0';
			end if;
	end if;
	
	end process;
	
	process (currentError1,clk) is begin
		if (clk'event) and (clk = '1') then 
			if (out_tready = '1') then
				currentError2 <= currentError1;
			end if;
		end if;
	end process;
				
	process(clk) is
		variable currInput : integer := 0;
		variable currError : integer := 0;
		variable oldError : std_logic_vector (15 downto 0);
	begin				
		if (clk'event) and (clk = '1') then
			if (out_tready = '1') then
				if (in_tvalid = '1') then					
						currInput := to_integer(signed(in_tdata));
						currError := setPoint - currInput;
						oldError := std_logic_vector(to_signed(currentError1 ,16));
						inp1 <= (inputVal => in_tdata, inputValid => '1', previousErrVal => oldError, outputVal => "UUUUUUUUUUUUUUUU");
						currErrOldErrDiff2 <= currError + currentError1;
						P1 <= to_integer(signed(Kp))*currError;
						currentError1 <= currError;
				else
					--need the pipeline to work correctly when the data is over
					inp1.outputVal <= "UUUUUUUUUUUUUUUU";
					inp1.inputVal <= "UUUUUUUUUUUUUUUU";
					inp1.previousErrVal <= "UUUUUUUUUUUUUUUU";
					inp1.inputValid <= '0';
				end if;
			end if;
		end if;						
	end process;
	
end rtl;	