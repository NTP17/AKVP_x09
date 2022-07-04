library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PISO is

	port(        PI: in     std_logic_vector(28 downto 0);
	       INT, CLR: in     std_logic;
			       CL: buffer std_logic;
	         SO, LT: out    std_logic);

end PISO;

architecture behavior of PISO is

component CLK_div is

	port(CLK: in  std_logic;
	       Q: out std_logic);

end component;

constant lines: natural := 29;

signal count: natural range 0 to lines;

begin

	delay: CLK_div port map(

		CLK => INT,
		Q   => CL

	);

	process(INT, count)
	begin

		if (falling_edge(CL) and (count < lines) and (CLR = '1')) then

			SO    <= PI(count);
			count <= count + 1;
			LT    <= '0';

		end if;

		if (falling_edge(CL) and (count = lines) and (CLR = '1')) then

			LT    <= '1';
			count <=  0;

		elsif (CLR = '0') then

			SO    <= '0';
			count <=  0 ;
			LT    <= '0';

		end if;

	end process;

end behavior;