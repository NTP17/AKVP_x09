library ieee;
use ieee.std_logic_1164.all;

entity AKVP_x09 is

	port(                       OSC, CLK, EXE, RSTN: in     std_logic;
	                                     ADDR, DOUT: out    std_logic_vector(8 downto 0);
													       DMID: buffer std_logic_vector(8 downto 0);
	       IR, R0, R1, R2, R3, R4, R5, R6, R7, A, G: out    std_logic_vector(8 downto 0);
	                                     H2, H1, H0: out    std_logic_vector(6 downto 0);
	     IR_in, Z_flag, disp_in,
		  R0_out, R1_out, R2_out, R3_out, R4_out, R5_out, R6_out, R7_out,
		  G_out, DIN_out, incr_pc,
		  R0_in, R1_in, R2_in, R3_in, R4_in, R5_in, R6_in, R7_in,
		  A_in, G_in, AddSub, ADDR_in, DOUT_in, Done: out    std_logic;
		                                         W_D: buffer std_logic;
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

signal DIN, ADRM: std_logic_vector(8 downto 0);
signal      disp: std_logic_vector(8 downto 0);

begin

	proc: enhanced_processor port map(

		XTAL     => OSC,
		CLOCK    => CLK,
		RUN      => EXE,
		CLEAR    => RSTN,
		data_in  => DIN,

		IRd      => IR,
		R0d      => R0,
		R1d      => R1,
		R2d      => R2,
		R3d      => R3,
		R4d      => R4,
		R5d      => R5,
		R6d      => R6,
		R7d      => R7,
		Ad       => A,
		Gd       => G,
		Hd       => disp,
		addr_out => ADRM,
		data_out => DMID,

		IRi      => IR_in,
		R0o      => R0_out,
		R1o      => R1_out,
		R2o      => R2_out,
		R3o      => R3_out,
		R4o      => R4_out,
		R5o      => R5_out,
		R6o      => R6_out,
		R7o      => R7_out,
		Go       => G_out,
		Di       => DIN_out,
		Pc       => incr_pc,
		R0i      => R0_in,
		R1i      => R1_in,
		R2i      => R2_in,
		R3i      => R3_in,
		R4i      => R4_in,
		R5i      => R5_in,
		R6i      => R6_in,
		R7i      => R7_in,
		Ai       => A_in,
		Gi       => G_in,
		Sb       => AddSub,
		Adr      => ADDR_in,
		Do       => DOUT_in,
		Wd       => W_D,
		Zf       => Z_flag,
		Hi       => disp_in,
		Fin      => Done

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