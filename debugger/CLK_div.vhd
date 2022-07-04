library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLK_div is

	port(CLK: in  std_logic;
	       Q: out std_logic);

end CLK_div;

architecture behavior of CLK_div is

constant prd: natural := 5000;

signal cnt: natural range 0 to prd;
signal tmp: std_logic := '0';

begin

	process(CLK)

	begin

		if rising_edge(CLK) then

			if (cnt = prd) then

				tmp <= not tmp;
				cnt <= 0;

			else

				cnt <= cnt + 1;

			end if;

		end if;

	end process;

	Q <= tmp;

end behavior;