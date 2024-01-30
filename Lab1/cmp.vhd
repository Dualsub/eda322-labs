library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_MISC.ALL;

entity comparator is port(
    a : in std_logic_vector(7 downto 0); 
    b : in std_logic_vector(7 downto 0);
    e : out std_logic
);
end comparator;

architecture dataflow of comparator is
begin
    e <= and_reduce(a xnor b);
end dataflow;