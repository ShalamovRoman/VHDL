library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.customData.all;
   
entity Test is end entity;

architecture rtl of Test is

	constant testNum : integer := 10;

	type testDataType is array (0 to testNum - 1) of std_logic_vector (15 downto 0);
	signal testDataContainer : testDataType;
	signal currentTestNum : integer := 0;
	
	signal currentGenStep : integer := 1; --current generated test
	signal currentRecStep : integer := 1; --current recieved test
	
	signal initFinished : boolean;
	signal checkRes : std_logic;
	
	signal in_tvalid :  std_logic;
	signal in_tdata :  std_logic_vector (15 downto 0);
	signal in_tready :  std_logic;
	signal out_tvalid :  std_logic;
	signal out_tdata :  customOutputType;
	signal out_tready :  std_logic;
	signal clk :  std_logic;
	
	signal in_treadyLocal, out_treadyLocal : std_logic; --ready/not to work
	
procedure generateTestData (signal testDataContainer : inout testDataType) is 
	variable tmp : integer := 0;
	variable seed1, seed2 : positive; --need for generate random numbers

impure function randomInteger return integer is 
  variable r : real;

begin
  uniform(seed1, seed2, r);
  return integer(
    round(r * real(65534) + real(-32768) - 0.5)); --maxval - minval + 1 + minval - 0.5
	 
end function;

begin
	for i in 0 to testNum - 1 loop			
--		tmp := randomInteger;
		if (i mod 2 = 0) then	--comment this to get random nums
			tmp := i * 10;			--
		else 							--
			tmp := i * (-10);		--
		end if;
		testDataContainer(i) <= std_logic_vector(to_signed(tmp ,16));
	end loop;

end generateTestData;

--for debugging
procedure clearInput (signal in_tdata : inout std_logic_vector (15 downto 0)) is begin 

	in_tdata <= (others => 'U');
	
end clearInput;

signal pseudoRandom : integer := 2; 
	
begin

	DUT : entity work.Task3_PID_Controller
	port map
	(clk => clk, in_tvalid => in_tvalid, out_tdata => out_tdata, out_tvalid => out_tvalid, in_tready => in_tready, out_tready => out_tready, in_tdata => in_tdata);
	
	process is begin
		clk <= '1';
		wait for 4 ns;
		clk <= '0';
		wait for 4 ns;
	end process;

--process to generate all test data
	process is begin
		generateTestData(testDataContainer);
		initFinished <= true;
		wait;
	end process;	

--GENERATOR
--gives one test to pipe if both ready
--must work until data runs out

	
	in_treadyLocal <= '1' when ((currentGenStep mod 4) /= 0 ) else '0'; --freeze generator
	
	process (clk) is begin 
		if (clk'event) and (clk = '1') and initFinished then
			if (currentTestNum < testNum) then
				if (in_treadyLocal = '0') then 
					in_tvalid <= '0';
					clearInput(in_tdata);
				else
					if (out_treadyLocal = '1') then
						in_tvalid <= '1';
						in_tdata <= testDataContainer(currentTestNum);
						currentTestNum <= currentTestNum + 1;
					else
						in_tvalid <= '0';
						clearInput(in_tdata);
					end if;				
				end if;
				currentGenStep <= currentGenStep + 1;
			else 
				in_tvalid <= '0';
				clearInput(in_tdata);
			end if;
		end if;
	end process;

--RECEIVER
--gets out data from pipe if both ready
--should work while the pipeline is running because it infinite

    process (clk) is 
    begin
      if clk'event and clk = '1' then 
        pseudoRandom <= (pseudoRandom * pseudoRandom) mod 23; 
      end if;
    end process; 

--	out_treadyLocal <= '1' when ((currentRecStep mod 3) /= 0) else '0'; --freeze receiver
	out_treadyLocal <= '1'; --when ((pseudoRandom > 17 )) else '0'; --freeze receiver
	
	process (clk) is 
	
	variable previousErrVal : integer := 0; 

        procedure checkResult (pipelineOutput : in customOutputType; signal checkRes : out std_logic ) is
            
            variable pipeInput : integer := 0;
            variable pipeOutputPrevErr : integer := 0;
            variable currentError : integer := 0;
            variable tmpResult : integer := 0;
            variable tmpResultBit : std_logic_vector (15 downto 0);
            variable P,I,D : integer := 0;
            variable tmpCheck : std_logic := '0';
        
        begin	
            
            pipeInput := to_integer(signed(pipelineOutput.inputVal));
            pipeOutputPrevErr := previousErrVal;
        
            currentError := setPoint - pipeInput;
            previousErrVal := currentError; 			
            P := to_integer(signed(Kp))*currentError;
            I := to_integer(signed(Ki))*(currentError + pipeOutputPrevErr); 
            D := to_integer(signed(Kd))*(currentError - pipeOutputPrevErr);
            tmpResult := (P + I + D)/256;
            --check output for 16-bit range
            if (tmpResult > 32767) then
                     tmpResult := 32767 ;
                end if;     
                if (tmpResult < -32768) then 
                     tmpResult := -32768;
            end if;
            tmpResultBit := std_logic_vector(to_signed(tmpResult ,16));
            
            if (tmpResultBit = pipelineOutput.outputVal) then
                tmpCheck := '1';
            end if;
            
            checkRes <= tmpCheck;
        
        end checkResult;
        

	begin 
		if (clk'event) and (clk = '1') and initFinished then
				out_tready <= out_treadyLocal;
				if (out_tvalid = '1') then 
					checkResult(out_tdata, checkRes);
				else
					checkRes <= 'X';
				end if;
				currentRecStep <= currentRecStep + 1;
		end if;
	end process;
	
end rtl;
