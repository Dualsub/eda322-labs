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
    -- Register
    process(clk, resetn)
    begin
        if resetn = '0' then
            curr_state <= FE;
        elsif rising_edge(clk) then
            curr_state <= next_state;
        end if;
    end process;

    -- State transition logic
    process(curr_state, opcode)
    begin
        case curr_state is
            when FE => 
                next_state <= DE1;
            when DE1 =>
                case opcode is
                    when OP_NOOP =>
                        next_state <= FE;
                    when OP_IN | OP_DS | OP_MOV | OP_JE | OP_JNE | OP_JZ | OP_CMP | OP_ROL | OP_AND | OP_ADD | OP_SUB | OP_LB =>
                        next_state <= EX;
                    when OP_LBI =>
                        next_state <= DE2;
                    when OP_SBI | OP_SB =>
                        next_state <= ME;
                    when others =>
                        next_state <= FE;
                end case;

            when DE2 =>
                next_state <= EX;
            when EX =>
                next_state <= FE;
            when ME =>
                next_state <= FE;
            when others =>
                next_state <= FE;
        end case;
    end process;

    -- Output logic
    process(curr_state, opcode, master_load_enable, e_flag, z_flag)
    begin
        case curr_state is
            when FE =>
                pcSel <= '0';
                if master_load_enable = '1' then
                    imRead <= '1';
                    pcLd <= '1';
                end if;
            when DE1 =>
                if opcode = OP_CMP or opcode = OP_AND or opcode = OP_ADD or opcode = OP_SUB or opcode = OP_LB or opcode = OP_LBI or opcode = OP_SBI then
                    decoEnable <= '1';
                    decoSel <= "00";
                    if master_load_enable = '1' then
                        dmRead <= '1';
                    end if;
                end if;
            when DE2 =>
                if opcode = OP_LBI then
                    decoEnable <= '1';
                    decoSel <= "01";
                    if master_load_enable = '1' then
                        dmRead <= '1';
                    end if;
                end if;
            when EX => 
                -- Data movement operations
                if opcode = OP_IN or opcode = OP_MOV then
                    decoEnable <= '1';
                    decoSel <= "11";
                    accSel <= '1';
                    if master_load_enable = '1' then
                        accLd <= '1';
                    end if;
                
                -- Jump operations
                elsif opcode = OP_DS and master_load_enable = '1' then
                    dsLd <= '1';
                elsif (opcode = OP_JE and e_flag = '1') or (opcode = OP_JNE and e_flag = '0') or (opcode = OP_JZ and z_flag = '1') then
                    decoEnable <= '1';
                    decoSel <= "00";
                    pcSel <= '1';
                    if master_load_enable = '1' then
                        pcLd <= '1';
                    end if;
                elsif opcode = OP_CMP then
                    decoEnable <= '1';
                    decoSel <= "01";
                    if master_load_enable = '1' then
                        flagLd <= '1';
                    end if;

                -- ALU operations
                elsif opcode = OP_ROL then
                    decoEnable <= '0';
                    accSel <= '0';
                    aluOp <= "00";
                    if master_load_enable = '1' then
                        flagLd <= '1';
                        accLd <= '1';
                    end if;
                elsif opcode = OP_AND or opcode = OP_ADD or opcode = OP_SUB then
                    decoEnable <= '1';
                    decoSel <= "01";
                    accSel <= '0';

                    if opcode = OP_AND then
                        aluOp <= "00";
                    elsif opcode = OP_ADD then
                        aluOp <= "01";
                    else
                        aluOp <= "10";
                    end if;
                    
                    if master_load_enable = '1' then
                        flagLd <= '1';
                        accLd <= '1';
                    end if;
                
                -- Memory operations
                elsif opcode = OP_LB or opcode = OP_LBI then
                    decoEnable <= '1';
                    decoSel <= "01";
                    accSel <= '1';
                    aluOp <= "11";
                    if master_load_enable = '1' then
                        accLd <= '1';
                    end if;
                end if;
            when ME => 
                if opcode = OP_SBI or opcode = OP_SB then
                    decoEnable <= '1';
                    if opcode = OP_SBI then
                        decoSel <= "01";
                    else
                        decoSel <= "00";
                    end if;
                    if master_load_enable = '1' then
                        dmWrite <= '1';
                    end if;
                end if;
        end case;

    end process;
                
end rtl;