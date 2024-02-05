library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;

entity proc_controller is
    port (
        clk: in std_logic;
        resetn: in std_logic;
        master_load_enable: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        e_flag: in std_logic;
        z_flag: in std_logic;

        decoEnable: out std_logic;
        decoSel: out std_logic_vector(1 downto 0);
        pcSel: out std_logic;
        pcLd: out std_logic;
        imRead: out std_logic;
        dmRead: out std_logic;
        dmWrite: out std_logic;
        aluOp: out std_logic_vector(1 downto 0);
        flagLd: out std_logic;
        accSel: out std_logic;
        accLd: out std_logic;
        dsLd: out std_logic
    );
end proc_controller;

-- Mealy state machine
architecture rtl of proc_controller is
    type state_type is (FE, DE1, DE2, EX, ME);
    signal curr_state : state_type := FE;
    signal next_state : state_type := FE;
    -- Create constants for opcode values
    constant OP_NOOP: std_logic_vector(3 downto 0) := "0000";
    constant OP_IN: std_logic_vector(3 downto 0) := "0001";
    constant OP_DS: std_logic_vector(3 downto 0) := "0010";
    constant OP_MOV: std_logic_vector(3 downto 0) := "0011";
    constant OP_JE: std_logic_vector(3 downto 0) := "0100";
    constant OP_JNE: std_logic_vector(3 downto 0) := "0101";
    constant OP_JZ: std_logic_vector(3 downto 0) := "0110";
    constant OP_CMP: std_logic_vector(3 downto 0) := "0111";
    constant OP_ROL: std_logic_vector(3 downto 0) := "1000";
    constant OP_AND: std_logic_vector(3 downto 0) := "1001";
    constant OP_ADD: std_logic_vector(3 downto 0) := "1010";
    constant OP_SUB: std_logic_vector(3 downto 0) := "1011";
    constant OP_LB: std_logic_vector(3 downto 0) := "1100";
    constant OP_SB: std_logic_vector(3 downto 0) := "1101";
    constant OP_LBI: std_logic_vector(3 downto 0) := "1110";
    constant OP_SBI: std_logic_vector(3 downto 0) := "1111";
begin
    process(clk, resetn)
    begin
        if resetn = '0' then
            curr_state <= FE;
        elsif rising_edge(clk) then
            
            -- Next state logic
            case curr_state is
                when FE => 
                    next_state <= DE1;
                when DE1 =>
                    select opcode is
                        next_state <= FE when OP_NOOP,
                                    EX when OP_IN or OP_DS or OP_MOV or OP_JE or OP_JNE or OP_JZ or OP_CMP or OP_ROL or OP_AND or OP_ADD or OP_SUB or OP_LB,
                                    DE2 when OP_LBI,
                                    ME when OP_SBI or OP_SB,
                                    FE when others;
                when DE2 =>
                    next_state <= EX;
                when EX =>
                    next_state <= FE;
                when ME =>
                    next_state <= FE;
            end case;

        end if;
    end process;

end rtl;