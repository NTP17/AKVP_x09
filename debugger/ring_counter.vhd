library ieee;
use ieee.std_logic_1164.all;

--

entity ring_counter is

	port(                                             XTAL, RES: in     std_logic;
	     L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12, L13: out    std_logic);

end ring_counter;

--

architecture FFs of ring_counter is

signal                                                   RSTs, SETs: std_logic_vector(13 downto 1);
signal d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11, d12, d13, trig: std_logic;
signal                                                            C: std_logic;
signal                                                        count: natural range 0 to 1;

component D_FF is

	port(D, CLK, RST, SET: in  std_logic;
	                    Q: out std_logic);

end component;

component CLK_div is

	port(CLK: in  std_logic;
	       Q: out std_logic);

end component;

--

begin

	micro: CLK_div port map(

		CLK => XTAL,
		Q   => C

	);

	IR: D_FF port map(
		D   => d13,
		CLK => C and trig,
		RST => RSTs(1),
		SET => SETs(1),
		Q   => d1
	);

	R0: D_FF port map(
		D   => d1,
		CLK => C and trig,
		RST => RSTs(2),
		SET => SETs(2),
		Q   => d2
	);

	R1: D_FF port map(
		D   => d2,
		CLK => C and trig,
		RST => RSTs(3),
		SET => SETs(3),
		Q   => d3
	);

	R2: D_FF port map(
		D   => d3,
		CLK => C and trig,
		RST => RSTs(4),
		SET => SETs(4),
		Q   => d4
	);

	R3: D_FF port map(
		D   => d4,
		CLK => C and trig,
		RST => RSTs(5),
		SET => SETs(5),
		Q   => d5
	);

	R4: D_FF port map(
		D   => d5,
		CLK => C and trig,
		RST => RSTs(6),
		SET => SETs(6),
		Q   => d6
	);

	R5: D_FF port map(
		D   => d6,
		CLK => C and trig,
		RST => RSTs(7),
		SET => SETs(7),
		Q   => d7
	);

	R6: D_FF port map(
		D   => d7,
		CLK => C and trig,
		RST => RSTs(8),
		SET => SETs(8),
		Q   => d8
	);

	R7: D_FF port map(
		D   => d8,
		CLK => C and trig,
		RST => RSTs(9),
		SET => SETs(9),
		Q   => d9
	);

	A: D_FF port map(
		D   => d9,
		CLK => C and trig,
		RST => RSTs(10),
		SET => SETs(10),
		Q   => d10
	);

	S: D_FF port map(
		D   => d10,
		CLK => C and trig,
		RST => RSTs(11),
		SET => SETs(11),
		Q   => d11
	);

	G: D_FF port map(
		D   => d11,
		CLK => C and trig,
		RST => RSTs(12),
		SET => SETs(12),
		Q   => d12
	);

	B: D_FF port map(
		D   => d12,
		CLK => C and trig,
		RST => RSTs(13),
		SET => SETs(13),
		Q   => d13
	);

	process(C, count, RES)
	begin

		if (RES = '0') then

			SETs <= (others => '1');
			RSTs <= (others => '0');
			trig <= '0';

		elsif (count = 0) then

			SETs <= (1 => '0', others => '1');
			RSTs <= (1 => '1', others => '0');
			trig <= '0';

		else

			SETs <= (others => '1');
			RSTs <= (others => '1');
			trig <= '1';

		end if;

		if ((rising_edge(C)) and (count = 0)) then

			count <= count + 1;

		end if;

	end process;

	L1  <= not d1;
	L2  <= not d2;
	L3  <= not d3;
	L4  <= not d4;
	L5  <= not d5;
	L6  <= not d6;
	L7  <= not d7;
	L8  <= not d8;
	L9  <= not d9;
	L10 <= not d10;
	L11 <= not d11;
	L12 <= not d12;
	L13 <= not d13;

end FFs;