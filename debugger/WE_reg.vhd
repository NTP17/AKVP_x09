library ieee;
use ieee.std_logic_1164.all;

entity WE_reg is

	port(D, CK, RS: in  std_logic;
	             Q: out std_logic);

end WE_reg;

architecture behavior of WE_reg is

begin

	process(D, CK, RS)

	begin

		if (rising_edge(CK) and (RS = '1')) then
			Q <= D;
		end if;
		
		if (RS = '0') then
			Q <= '0';
		end if;

	end process;

end behavior;