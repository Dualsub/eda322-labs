library ieee;
use ieee.std_logic_1164.all;

entity rotateleft is
    port(   
    	    a: in   std_logic_vector (7 downto 0);
    	    r: out  std_logic_vector (7 downto 0)
   	);
end rotateleft;

architecture dataflow of rotateleft is
begin
	r <= a(6 downto 0) & a(7);
end dataflow;