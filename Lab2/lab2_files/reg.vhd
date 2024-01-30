library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;

entity reg is
    generic (
        N : integer := 8
    );
    port (
        clk, resetn, loadEnable: in std_logic;
        dataIn: in std_logic_vector(N-1 downto 0);
        dataOut: out std_logic_vector(N-1 downto 0)
    );
end reg;

architecture behavorial of reg is
begin
    reg_proc: process(clk, resetn)
    begin
        -- Async reset, active low
        if resetn = '0' then
            dataOut <= (others => '0');
        elsif rising_edge(clk) and loadEnable = '1' then
            dataOut <= dataIn;
        end if;
    end process; -- register


end behavorial;
