library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fulladder is port(
    a : in std_logic;
    b : in std_logic;
    cin : in std_logic;
    s : out std_logic;
    cout : out std_logic
);
end fulladder;

architecture dataflow of fulladder is
begin
    s <= a xor b xor cin;
    cout <= (a and b) or (cin and (a xor b));
end dataflow;