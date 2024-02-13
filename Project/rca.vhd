library ieee;
use ieee.std_logic_1164.all;

entity rca is
    port(
        a, b: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        s: out std_logic_vector(7 downto 0)
    );
end rca;

architecture structural of rca is
	signal c: std_logic_vector(8 downto 0);
begin
	c(0) <= cin;
	gen_adders: for i in 0 to 7 generate
		fa_inst: entity work.fa port map (
			a => a(i),
			b => b(i),
			s => s(i),
			cin => c(i),
			cout => c(i+1)
		);
	end generate gen_adders;
	cout <= c(8);
end structural;