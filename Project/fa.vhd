library ieee;
use ieee.std_logic_1164.all;

entity fa is
    port(
        a, b: in std_logic;
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic
    );
end fa;

architecture dataflow of fa is
begin
	s <= a xor b xor cin;
	cout <= (cin and (a xor b)) or (a and b);
end dataflow;