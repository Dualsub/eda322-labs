library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rippleCarryAdder is 
    port(
        a : in std_logic_vector(7 downto 0); 
        b : in std_logic_vector(7 downto 0);
        cin : in std_logic;
        s : out std_logic_vector(7 downto 0);
        cout : out std_logic
    );
end rippleCarryAdder;

architecture structural of rippleCarryAdder is
    signal c: std_logic_vector(7 downto 0);

begin

    gen_adders: for i in 0 to 7 generate
        fca_inst: fca port map (
            a => a(i),
            b => b(i),
            s => s(i),
            cin => i = 0 when cin else c(i-1),
            cout => i = 7 when cout else c(i)
        );
    end generate gen_adders;

end structural;