library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rotateleft is port(
    a : in std_logic_vector(7 downto 0);
    b : out std_logic_vector(7 downto 0)
);
end rotateleft;

architecture dataflow of rotateleft is
begin
    b <= a(6 downto 0) & a(7);
end dataflow;