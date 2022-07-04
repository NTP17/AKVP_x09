library ieee;
use ieee.std_logic_1164.all;

entity AKVP_x09 is

	port(                     OSC, CLK, EXE, RSTN: in     std_logic;
	                                   H2, H1, H0: out    std_logic_vector(6 downto 0);
		                                      LEDs: out    std_logic_vector(8 downto 0));

end AKVP_x09;

architecture showdown of AKVP_x09 is

component enhanced_processor is

	port(                                     XTAL, CLOCK, RUN, CLEAR: in     std_logic;
	                                                          data_in: in     std_logic_vector(8 downto 0);
	     IRd, R0d, R1d, R2d, R3d, R4d, R5d, R6d, R7d, Ad, Gd, Hd     : buffer std_logic_vector(8 downto 0);
	     IRi, R0o, R1o, R2o, R3o, R4o, R5o, R6o, R7o, Go, Di, Do, Pc, Hi,
         Zf, R0i, R1i, R2i, R3i, R4i, R5i, R6i, R7i, Ai, Gi, Sb, Adr: buffer std_logic;
				                                      addr_out, data_out: out    std_logic_vector(8 downto 0);
	                                                          Wd, Fin: out    std_logic);

end component;

component RAM is

	port(    RAM_ADDR: in  std_logic_vector(6 downto 0);
         RAM_DATA_IN: in  std_logic_vector(8 downto 0);
              RAM_WR: in  std_logic;
           RAM_CLOCK: in  std_logic;
        RAM_DATA_OUT: out std_logic_vector(8 downto 0));

end component;

component LED_reg is

	port(            Ds: in  std_logic_vector(8 downto 0);
	     CLKs, RSTs, EN: in  std_logic;
	                 Qs: out std_logic_vector(8 downto 0));

end component;

component oct_to_7seg is

	port(                d2, d1, d0: in  std_logic;
	     ha, hb, hc, hd, he, hf, hg: out std_logic);

end component;

signal ADDR, DOUT, DIN, DMID, ADRM, disp: std_logic_vector(8 downto 0);
signal W_D: std_logic;

begin

	proc: enhanced_processor port map(

		XTAL     => OSC,
		CLOCK    => CLK,
		RUN      => EXE,
		CLEAR    => RSTN,
		data_in  => DIN,

		Hd       => disp,
		addr_out => ADRM,
		data_out => DMID,
		Wd       => W_D

	);

	mem: RAM port map(

		RAM_ADDR     => ADRM(6 downto 0),
		RAM_DATA_IN  => DMID,
		RAM_WR       => (ADRM(7) nor ADRM(8)) and W_D,
		RAM_CLOCK    => CLK,
		RAM_DATA_OUT => DIN

	);

	outs: LED_reg port map(

		Ds   => DMID,

		CLKs => CLK,
		RSTs => RSTN,

		EN   => ((not ADRM(7)) nor ADRM(8)) and W_D,

		Qs   => LEDs

	);

	HEX2: oct_to_7seg port map(

		d2 => disp(8),
		d1 => disp(7),
		d0 => disp(6),

		ha => H2(0),
		hb => H2(1),
		hc => H2(2),
		hd => H2(3),
		he => H2(4),
		hf => H2(5),
		hg => H2(6)

	);

	HEX1: oct_to_7seg port map(

		d2 => disp(5),
		d1 => disp(4),
		d0 => disp(3),

		ha => H1(0),
		hb => H1(1),
		hc => H1(2),
		hd => H1(3),
		he => H1(4),
		hf => H1(5),
		hg => H1(6)

	);

	HEX0: oct_to_7seg port map(

		d2 => disp(2),
		d1 => disp(1),
		d0 => disp(0),

		ha => H0(0),
		hb => H0(1),
		hc => H0(2),
		hd => H0(3),
		he => H0(4),
		hf => H0(5),
		hg => H0(6)

	);

	ADDR <= ADRM;
	DOUT <= DIN;

end showdown;