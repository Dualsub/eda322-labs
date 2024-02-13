library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;

entity tri_state is
    generic (
        N: integer := 8
    );
    port (
        enable: in std_logic;
        input: in std_logic_vector(N-1 downto 0);
        output: out std_logic_vector(N-1 downto 0)
    );
end tri_state;

architecture dataflow of tri_state is
begin
    output <= input when (enable = '1') else (others => 'Z');
end dataflow;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity decoder2to4 is 
    port (
        enable: in std_logic;
        sel: in std_logic_vector(1 downto 0);
        output: out std_logic_vector(3 downto 0)
    );
end decoder2to4;

architecture dataflow of decoder2to4 is
    signal final_out: std_logic_vector(3 downto 0);
begin
    with sel select
        final_out <= "1000" when "00",
                  "0100" when "01",
                  "0010" when "10",
                  "0001" when "11",
                  "0000" when others;

    output <= final_out when enable = '1' else "0000";

end dataflow;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity proc_bus is
    generic (
        N: integer := 8
    );
    port (
        decoEnable: in std_logic;
        decoSel: in std_logic_vector(1 downto 0); 
        imDataOut, dmDataOut, accOut, extIn: in std_logic_vector(N-1 downto 0);
        busOut: out std_logic_vector(N-1 downto 0)
    );
end proc_bus;
    
architecture structural of proc_bus is
    signal imDataOutEnable: std_logic; 
    signal dmDataOutEnable: std_logic; 
    signal accOutEnable: std_logic; 
    signal extInEnable: std_logic;
begin
    decoder2to4_inst: entity work.decoder2to4 port map (
        enable => decoEnable,
        sel => decoSel,
        output(3) => imDataOutEnable,
        output(2) => dmDataOutEnable,
        output(1) => accOutEnable,
        output(0) => extInEnable
    );

    im_ts_inst: entity work.tri_state port map (
        input => imDataOut,
        output => busOut,
        enable => imDataOutEnable
    );

    dm_ts_inst: entity work.tri_state port map (
        input => dmDataOut,
        output => busOut,
        enable => dmDataOutEnable
    );

    acc_ts_inst: entity work.tri_state port map (
        input => accOut,
        output => busOut,
        enable => accOutEnable
    );

    ext_ts_inst: entity work.tri_state port map (
        input => extIn,
        output => busOut,
        enable => extInEnable
    );

end structural;
