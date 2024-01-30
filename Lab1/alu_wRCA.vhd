library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;

entity alu_wRCA is
    port(
        alu_inA, alu_inB: in std_logic_vector(7 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        alu_out: out std_logic_vector(7 downto 0);
        C: out std_logic;
        E: out std_logic;
        Z: out std_logic
    );
end alu_wRCA;

architecture dataflow of alu_wRCA is

    signal out_rol: std_logic_vector(7 downto 0);
    signal out_addsub: std_logic_vector(7 downto 0);
    signal out_final: std_logic_vector(7 downto 0);

    signal sig_B: std_logic_vector(7 downto 0);

begin

    with alu_op select
        out_final <= out_rol when "00",
                    (alu_inA and alu_inB) when "01",
                    out_addsub when "10",
                    out_addsub when "11",
                    "00000000" when others;                

    Z <= '1' when out_final = "00000000" else '0';

    -- 2's compliment
    sig_B <= alu_inB when alu_op(1) = '0' else not alu_inB;

    addsub_inst: entity work.ripplecarryadder port map (
        a => alu_inA,
        b => sig_B,
        s => out_addsub,
        cin => alu_op(1), -- +1 if sub to find 2's compliment
        cout => C
    );

    cmp_inst: entity work.comparator port map (
        a => alu_inA,
        b => alu_inB,
        e => E
    );

    rol_inst: entity work.rotateleft port map (
        a => alu_inA,
        b => out_rol
    );

    alu_out <= out_final;

end dataflow;