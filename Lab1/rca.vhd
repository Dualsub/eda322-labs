library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;

entity rca is 
    port(
        a : in std_logic_vector(7 downto 0); 
        b : in std_logic_vector(7 downto 0);
        cin : in std_logic;
        s : out std_logic_vector(7 downto 0);
        cout : out std_logic
    );
end rca;

architecture structural of rca is
    signal c: std_logic_vector(8 downto 0);

begin

    c(0) <= cin;

    gen_adders: for i in 0 to 7 generate
        fa_inst: entity work.fulladder port map (
            a => a(i),
            b => b(i),
            s => s(i),
            cin => c(i),
            cout => c(i+1)
        );
    end generate gen_adders;

    cout <= c(8);

end structural;