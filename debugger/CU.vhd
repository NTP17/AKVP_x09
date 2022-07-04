library ieee;
use ieee.std_logic_1164.all;

entity CU is

	port(                     ENABLE, CLEAR, CLK, Z_flag: in  std_logic;
	                                              CU_ins: in  std_logic_vector(8 downto 0);
	     IR_in, disp_in,
		  R0_out, R1_out, R2_out, R3_out, R4_out, R5_out, R6_out, R7_out,
		  G_out, DIN_out, incr_pc,
		  R0_in, R1_in, R2_in, R3_in, R4_in, R5_in, R6_in, R7_in,
		  A_in, G_in, AddSub, ADDR_in, DOUT_in, W_D, Done: out std_logic);

end CU;

-- CU_ins(8 downto 6) = III
-- CU_ins(5 downto 3) = XXX
-- CU_ins(2 downto 0) = YYY

architecture bunch_of_mess of CU is

signal                   op, step: std_logic_vector(2  downto 0);
signal Ro, Ri, RXo, RXi, RYo, RYi: std_logic_vector(7  downto 0);
signal                       pack: std_logic_vector(16 downto 0);

-- pack(16) = Hi
-- pack(15) = Ii
-- pack(14) = Co
-- pack(13) = Xo
-- pack(12) = Yo
-- pack(11) = Go
-- pack(10) = Di
-- pack(9)  = Xi
-- pack(8)  = Yi
-- pack(7)  = Gi
-- pack(6)  = Ai
-- pack(5)  = Sb
-- pack(4)  = Pc
-- pack(3)  = Ad
-- pack(2)  = Do
-- pack(1)  = We
-- pack(0)  = Dn

component decode38 is

	port(                 C,  B,  A,  E: in  std_logic;
	     Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7: out std_logic);

end component;

component CU_counter is

	port(CNT, RES, ACLR, go: in  std_logic;
	         Q0, Q1, Q2, Q3: out std_logic);

end component;

component signals_register is

	port(            Ds: in  std_logic_vector(27 downto 0);
	     CLKs, RSTs, EN: in  std_logic;
	                 Qs: out std_logic_vector(27 downto 0));

end component;

begin

	op <= CU_ins(8 downto 6);

	ustep: CU_counter port map(
		CNT  => CLK,
		RES  => pack(0),
		ACLR => CLEAR,
		go   => ENABLE,
		Q0   => step(0),
		Q1   => step(1),
		Q2   => step(2)
	);

	process(op, step)
	begin

	if (ENABLE = '1') then

		if (step = "000") then -- T0 is always R7_out, ADDR_in

			pack <= (14|3 => '1', others => '0');

		elsif (step = "001") then -- T1 is always IR_out, incr_pc

			pack <= (15|4 => '1', others => '0');

		else

			case op is

				when "000" => -- mv

					case step is

						when "010"  => pack <= (12|9|0 => '1', others => '0');
						when others =>	pack <= (others => '0');

					end case;

				when "001" => -- mvi

					case step is

						when "010"  => pack <= (14|3     => '1', others => '0');
						when "011"  => pack <= (10|9|4|0 => '1', others => '0');
						when others => pack <= (others   => '0');

					end case;

				when "010" => -- add

					case step is

						when "010"  => pack <= (13|6   => '1', others => '0');
						when "011"  => pack <= (12|7   => '1', others => '0');
						when "100"  => pack <= (11|9|0 => '1', others => '0');
						when others =>	pack <= (others => '0');

					end case;

				when "011" => -- sub

					case step is

						when "010"  => pack <= (13|6   => '1', others => '0');
						when "011"  => pack <= (12|7|5 => '1', others => '0');
						when "100"  => pack <= (11|9|0 => '1', others => '0');
						when others =>	pack <= (others => '0');

					end case;

				when "100" => -- ld

					case step is

						when "010"  => pack <= (12|3   => '1', others => '0');
						when "011"  => pack <= (10|9|0 => '1', others => '0');
						when others => pack <= (others => '0');

					end case;

				when "101" => -- st

					case step is

						when "010"  => pack <= (13|2     => '1', others => '0');
						when "011"  => pack <= (12|3|1|0 => '1', others => '0');
						when others => pack <= (others   => '0');

					end case;

				when "110" => -- mvnz

					if (Z_flag = '0') then

						case step is

							when "010"  => pack <= (12|9|0 => '1', others => '0');
							when others =>	pack <= (others => '0');

						end case;

					else pack <= (0 => '1', others => '0');

					end if;

				when "111" => -- out

					case step is

						when "010"  => pack <= (16|13|0 => '1', others => '0');
						when others => pack <= (others => '0');

					end case;

			end case;

		end if;

	end if;

	end process;

	RX_out: decode38 port map(
		C  => CU_ins(5),
		B  => CU_ins(4),
		A  => CU_ins(3),

		E  => pack(13),

		Y7 => RXo(7),
		Y6 => RXo(6),
		Y5 => RXo(5),
		Y4 => RXo(4),
		Y3 => RXo(3),
		Y2 => RXo(2),
		Y1 => RXo(1),
		Y0 => RXo(0)
	);

	RY_out: decode38 port map(
		C  => CU_ins(2),
		B  => CU_ins(1),
		A  => CU_ins(0),

		E  => pack(12),

		Y7 => RYo(7),
		Y6 => RYo(6),
		Y5 => RYo(5),
		Y4 => RYo(4),
		Y3 => RYo(3),
		Y2 => RYo(2),
		Y1 => RYo(1),
		Y0 => RYo(0)
	);

	RX_in: decode38 port map(
		C  => CU_ins(5),
		B  => CU_ins(4),
		A  => CU_ins(3),

		E  => pack(9),

		Y7 => RXi(7),
		Y6 => RXi(6),
		Y5 => RXi(5),
		Y4 => RXi(4),
		Y3 => RXi(3),
		Y2 => RXi(2),
		Y1 => RXi(1),
		Y0 => RXi(0)
	);

	RY_in: decode38 port map(
		C  => CU_ins(2),
		B  => CU_ins(1),
		A  => CU_ins(0),

		E  => pack(8),

		Y7 => RYi(7),
		Y6 => RYi(6),
		Y5 => RYi(5),
		Y4 => RYi(4),
		Y3 => RYi(3),
		Y2 => RYi(2),
		Y1 => RYi(1),
		Y0 => RYi(0)
	);

	Ro <= RXo xor RYo;
	Ri <= RXi xor RYi;

	ready: signals_register port map(
		Ds(27)           => pack(16),
	   Ds(26)           => pack(15),
		Ds(25 downto 19) => Ro(7 downto 1),
		Ds(18)           => Ro(0) xor pack(14),
		Ds(17)           => pack(11),
		Ds(16)           => pack(10),
		Ds(15)           => pack(4),
		Ds(14 downto 7)  => Ri(7 downto 0),
		Ds(6)            => pack(6),
		Ds(5)            => pack(7),
		Ds(4)            => pack(5),
		Ds(3)            => pack(3),
		Ds(2)            => pack(2),
		Ds(1)            => pack(1),
		Ds(0)            => pack(0),
		
		CLKs             => CLK,
		RSTs             => CLEAR,
		EN               => ENABLE,

		Qs(27)           => disp_in,
		Qs(26)           => IR_in,
		Qs(25)           => R0_out,
		Qs(24)           => R1_out,
		Qs(23)           => R2_out,
		Qs(22)           => R3_out,
		Qs(21)           => R4_out,
		Qs(20)           => R5_out,
		Qs(19)           => R6_out,
		Qs(18)           => R7_out,
		Qs(17)           => G_out,
		Qs(16)           => DIN_out,
		Qs(15)           => incr_pc,
		Qs(14)           => R0_in,
		Qs(13)           => R1_in,
		Qs(12)           => R2_in,
		Qs(11)           => R3_in,
		Qs(10)           => R4_in,
		Qs(9)            => R5_in,
		Qs(8)            => R6_in,
		Qs(7)            => R7_in,
		Qs(6)            => A_in,
		Qs(5)            => G_in,
		Qs(4)            => AddSub,
		Qs(3)            => ADDR_in,
		Qs(2)            => DOUT_in,
		Qs(1)            => W_D,
		Qs(0)            => Done
	);

end bunch_of_mess;