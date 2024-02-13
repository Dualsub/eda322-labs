library ieee;
use ieee.std_logic_1164.all;

library work;

entity reg is
    generic (width: integer := 8);
    port (
        clk: in std_logic;
        resetn: in std_logic;
        loadEnable: in std_logic;
        dataIn: in std_logic_vector(width-1 downto 0);
        dataOut: out std_logic_vector(width-1 downto 0)
    );
end entity reg;

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