library ieee;
use ieee.std_logic_1164.all;

entity oct_to_7seg is

	port(                d2, d1, d0: in  std_logic;
	     ha, hb, hc, hd, he, hf, hg: out std_logic);

end oct_to_7seg;

architecture behavior of oct_to_7seg is

begin

	ha <= (not d1) and (d2 xor d0);
	hb <= d2 and (d1 xor d0);
	hc <= (not d2) and d1 and (not d0);
	hd <= ((not d1) and (d2 xor d0)) or (d2 and d1 and d0);
	he <= d0 or (d2 and (not d1));
	hf <= ((not d2) and (d1 or d0)) or (d1 and d0);
	hg <= (d2 nor d1) or (d2 and d1 and d0);

end behavior;