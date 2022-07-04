library ieee;
use ieee.std_logic_1164.all;

entity debugger is

	port(                            PUL, EN, CK, RESET: in     std_logic;
		                              reg_LEDs, LEDs_reg: out    std_logic_vector(8 downto 0);
												  HEX2, HEX1, HEX0: out    std_logic_vector(6 downto 0);
										CU_D, CU_O, RAM_D, RAM_O: out    std_logic;
										                VCC, GND: out    std_logic;
	                                        CU_C, RAM_C: buffer std_logic;
		  R0_s, R1_s, R2_s, R3_s, R4_s, R5_s, R6_s, R7_s,
		                    IR_s,  A_s,  G_s, AD_s, DO_s: buffer std_logic);

end debugger;

architecture display of debugger is

component AKVP_x09 is

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

end component;

component ring_counter is

	port(                                             XTAL, RES: in  std_logic;
	     L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12, L13: out std_logic);

end component;

component PISO is

	port(        PI: in     std_logic_vector(28 downto 0);
	       INT, CLR: in     std_logic;
			       CL: buffer std_logic;
	         SO, LT: out    std_logic);

end component;

component half_sec is

	port(S:     in  std_logic;
	     PULSE: in  std_logic;
	     T:     out std_logic);

end component;

--signal                                                                        CK: std_logic;
signal IRi_c, R0o_c, R1o_c, R2o_c, R3o_c, R4o_c, R5o_c, R6o_c, R7o_c, Go_c, Di_c,
        PC_c, R0i_c, R1i_c, R2i_c, R3i_c, R4i_c, R5i_c, R6i_c, R7i_c, Ai_c, Gi_c,
                                    Sb_c,  Ad_c,  Do_c,  We_c, Zf_c,  Hx_c, Dn_c: std_logic;
signal IR_d,  R0_d,  R1_d,  R2_d,  R3_d,  R4_d,  R5_d,  R6_d,  R7_d,  A_d,  G_d,
                                                               Ad_d,  Do_d, Ro_d: std_logic_vector(8  downto 0);
signal                                                                      pack: std_logic_vector(12 downto 0);

begin

	VCC <= '1';
	GND <= '0';

--	auto: half_sec port map(

--		S     => '1',
--		PULSE => PUL,
--		T     => CK

--	);

	signals: ring_counter port map(

		XTAL  => PUL,
		RES   => '1',

		L1    => IR_s,
		L2    => R0_s,
		L3    => R1_s,
		L4    => R2_s,
		L5    => R3_s,
		L6    => R4_s,
		L7    => R5_s,
		L8    => R6_s,
		L9    => R7_s,
		L10   => A_s,
		L11   => G_s,
		L12   => AD_s,
		L13   => DO_s

	);

	pack <= IR_s & R0_s & R1_s & R2_s & R3_s & R4_s & R5_s & R6_s & R7_s & A_s & G_s & AD_s & DO_s;

	data: AKVP_x09 port map(

		OSC     => PUL,
		CLK     => CK,
		EXE     => EN,
		RSTN    => RESET,

		IR      => IR_d,
		R0      => R0_d,
		R1      => R1_d,
		R2      => R2_d,
		R3      => R3_d,
		R4      => R4_d,
		R5      => R5_d,
		R6      => R6_d,
		R7      => R7_d,
		A       => A_d,
		G       => G_d,
		ADDR    => Ad_d,
		DMID    => Do_d,
		DOUT    => Ro_d,

		H2      => HEX2,
		H1      => HEX1,
		H0      => HEX0,

		IR_in   => IRi_c,
		R0_out  => R0o_c,
		R1_out  => R1o_c,
		R2_out  => R2o_c,
		R3_out  => R3o_c,
		R4_out  => R4o_c,
		R5_out  => R5o_c,
		R6_out  => R6o_c,
		R7_out  => R7o_c,
		G_out   => Go_c,
		DIN_out => Di_c,
		incr_pc => PC_c,
		R0_in   => R0i_c,
		R1_in   => R1i_c,
		R2_in   => R2i_c,
		R3_in   => R3i_c,
		R4_in   => R4i_c,
		R5_in   => R5i_c,
		R6_in   => R6i_c,
		R7_in   => R7i_c,
		A_in    => Ai_c,
		G_in    => Gi_c,
		AddSub  => Sb_c,
		ADDR_in => Ad_c,
		DOUT_in => Do_c,
		W_D     => We_c,
		Z_flag  => Zf_c,
		disp_in => Dn_c,
		Done    => Hx_c,

		LEDs    => LEDs_reg

	);

	controls: PISO port map(

		PI(28) => IRi_c,
		PI(27) => R0o_c,
		PI(26) => R1o_c,
		PI(25) => R2o_c,
		PI(24) => R3o_c,
		PI(23) => R4o_c,
		PI(22) => R5o_c,
		PI(21) => R6o_c,
		PI(20) => R7o_c,
		PI(19) => Go_c,
		PI(18) => Di_c,
		PI(17) => PC_c,
		PI(16) => R0i_c,
		PI(15) => R1i_c,
		PI(14) => R2i_c,
		PI(13) => R3i_c,
		PI(12) => R4i_c,
		PI(11) => R5i_c,
		PI(10)  => R6i_c,
		PI(9)  => R7i_c,
		PI(8)  => Ai_c,
		PI(7)  => Gi_c,
		PI(6)  => Sb_c,
		PI(5)  => Ad_c,
		PI(4)  => Do_c,
		PI(3)  => We_c,
		PI(2)  => Zf_c,
		PI(1)  => Hx_c,
		PI(0)  => Dn_c,

		INT    => PUL,
		CLR    => '1',
		CL     => CU_C,
		SO     => CU_D,
		LT     => CU_O

	);

	memory: PISO port map(

		PI(28) => Ad_d(6),
		PI(27) => Ad_d(5),
		PI(26) => Ad_d(4),
		PI(25) => Ad_d(3),
		PI(24) => Ad_d(2),
		PI(23) => Ad_d(1),
		PI(22) => Ad_d(0),

		PI(21) => Ro_d(8),
		PI(20) => Ro_d(7),
		PI(19) => Ro_d(6),
		PI(18) => Ro_d(5),
		PI(17) => Ro_d(4),
		PI(16) => Ro_d(3),
		PI(15) => Ro_d(2),
		PI(14) => Ro_d(1),
		PI(13) => Ro_d(0),

		INT    => PUL,
		CLR    => '1',
		CL     => RAM_C,
		SO     => RAM_D,
		LT     => RAM_O

	);

	reg_LEDs <= IR_d when (pack = "0111111111111") else
	            R0_d when (pack = "1011111111111") else
			      R1_d when (pack = "1101111111111") else
			      R2_d when (pack = "1110111111111") else
			      R3_d when (pack = "1111011111111") else
			      R4_d when (pack = "1111101111111") else
			      R5_d when (pack = "1111110111111") else
			      R6_d when (pack = "1111111011111") else
			      R7_d when (pack = "1111111101111") else
			      A_d  when (pack = "1111111110111") else
			      G_d  when (pack = "1111111111011") else
			      Ad_d when (pack = "1111111111101") else
			      Do_d when (pack = "1111111111110") else (others => '0');

end display;