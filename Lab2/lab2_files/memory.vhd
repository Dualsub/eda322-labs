library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;

entity memory is
    generic (
        width : integer := 8;
        address_size : integer := 8
    );
    port (
        clk, readEn: in std_logic; 
        writeEn: in std_logic := 'X';
        address: in std_logic_vector(address_size-1 downto 0);
        dataIn: in std_logic_vector(width-1 downto 0) := (others => 'X');
        dataOut: out std_logic_vector(width-1 downto 0)
    );
    end memory;
    
architecture behavorial of memory is
    type MEMORY_ARRAY is ARRAY (0 to (2**address_size) - 1) of std_logic_vector(width-1 downto 0); 
    signal mem_array: MEMORY_ARRAY := (others => (others => '0'));
begin 
    memory: process(clk)
    begin
        if rising_edge(clk) then
            if readEn = '1' then
                dataOut <= mem_array(to_integer(unsigned(address)));
            end if;
            if writeEn = '1' then
                mem_array(to_integer(unsigned(address))) <= dataIn;
            end if;
        end if;
    end process; -- memory


end behavorial;
