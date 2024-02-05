library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;

entity memory is
    generic (
        width : integer := 8;
        address_size : integer := 8;
        init_file : string := "d_memory_lab2.mif"
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

    impure function init_memory_wfile(mif_file_name : in string) return MEMORY_ARRAY is
        file mif_file : text open read_mode is mif_file_name;
        variable mif_line : line;
        variable temp_bv : bit_vector(DATA_WIDTH-1 downto 0);
        variable temp_mem : MEMORY_ARRAY;
    begin
        for i in MEMORY_ARRAY'range loop
            readline(mif_file, mif_line);
            read(mif_line, temp_bv);
            temp_mem(i) := to_stdlogicvector(temp_bv);
        end loop;
        return temp_mem;
    end function;

    signal mem_array: MEMORY_ARRAY := init_memory_wfile(init_file);
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
