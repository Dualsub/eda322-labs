library ieee;
use ieee.std_logic_1164.all;

library work;

entity EDA322_processor is
    generic (dInitFile : string := "d_memory_lab3.mif";
             iInitFile : string := "i_memory_lab3.mif");
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);
        outState           : out std_logic_vector(2 downto 0);
        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        ds2seg             : out std_logic_vector(7 downto 0)
    );
end EDA322_processor;

architecture structural of EDA322_processor is
    signal opcode: std_logic_vector(3 downto 0);
    signal e_flag: std_logic;
    signal z_flag: std_logic;

    signal decoEnable: std_logic;
    signal decoSel: std_logic_vector(1 downto 0);
    
    signal pcSel: std_logic;
    signal pcLd: std_logic;
    signal pcOut: std_logic_vector(7 downto 0);
    signal nextPc: std_logic_vector(7 downto 0);
    signal pcIncrOut: std_logic_vector(7 downto 0);
    signal jumpAddr: std_logic_vector(7 downto 0);
    signal jumpAddrB: std_logic_vector(7 downto 0);

    signal imRead: std_logic;
    
    signal dmRead: std_logic;
    signal dmWrite: std_logic;
    
    signal aluOp: std_logic_vector(1 downto 0);
    signal aluOut: std_logic_vector(7 downto 0);
    signal aluOut_e_flag: std_logic;
    signal aluOut_z_flag: std_logic;
    signal flagLd: std_logic;
    signal accSel: std_logic;
    signal accLd: std_logic;
    signal dsLd: std_logic;

    signal imDataOut: std_logic_vector(11 downto 0);
    signal dmDataOut: std_logic_vector(7 downto 0);
    signal accOut: std_logic_vector(7 downto 0);
    signal accIn: std_logic_vector(7 downto 0);
    signal internalBusOut: std_logic_vector(7 downto 0);
begin

    ---- Controller
    controller_inst: entity work.proc_controller port map (
        clk => clk,
        resetn => resetn,
        master_load_enable => master_load_enable,
        opcode => opcode,
        e_flag => e_flag,
        z_flag => z_flag,

        outState => outState,

        decoEnable => decoEnable,
        decoSel => decoSel,
        pcSel => pcSel,
        pcLd => pcLd,
        imRead => imRead,
        dmRead => dmRead,
        dmWrite => dmWrite,
        aluOp => aluOp,
        flagLd => flagLd,
        accSel => accSel,
        accLd => accLd,
        dsLd => dsLd  
    );

    ---- Internal bus
    internal_bus_inst: entity work.proc_bus generic map (8)
    port map (
        decoEnable => decoEnable,
        decoSel => decoSel, 
        imDataOut => imDataOut(7 downto 0),
        dmDataOut => dmDataOut,
        accOut => accOut,
        extIn => extIn,
        busOut => internalBusOut
    );

    busOut2seg <= internalBusOut;

    ---- Instruction memory
    im_inst: entity work.memory generic map (12, 8, iInitFile)
    port map (
        clk => clk,
        readEn => imRead,
	writeEn => '0',
        address => pcOut,
        dataOut => imDataOut,
        dataIn => (others => 'X')
    );

    opcode <= imDataOut(11 downto 8);
    imDataOut2seg <= imDataOut;
    
    ---- Data memory
    dm_inst: entity work.memory generic map (8, 8, dInitFile)
    port map (
        clk => clk,
        readEn => dmRead,
        writeEn => dmWrite,
        dataOut => dmDataOut,
        address => internalBusOut,
        dataIn => accOut
    );
        
    dmDataOut2seg <= dmDataOut;

    ---- Program counter

    with internalBusOut(7) select
    jumpAddrB <= '0' & internalBusOut(6 downto 0) when '0',
                '1' & (not internalBusOut(6 downto 0)) when '1',
                "00000000" when others;     

    jump_addr_inst: entity work.rca port map (
        a => pcOut,
        b => jumpAddrB,
        cin => internalBusOut(7),
        cout => open,
        s => jumpAddr
    );

    pc_incer_inst: entity work.rca port map (
        a => pcOut,
        b => "00000001",
        cin => '0',
        cout => open,
        s => pcIncrOut
    );

    pc_mux_inst: entity work.mux2 generic map (8)
    port map (
        s => pcSel,
        i0 => pcIncrOut,
        i1 => jumpAddr,
        o => nextPc
    );

    pc_inst: entity work.reg generic map (8)
    port map (
        clk => clk,
        resetn => resetn,
        loadEnable => pcLd,
        dataIn => nextPc,
        dataOut => pcOut
    );

    pc2seg <= pcOut;

    ---- ALU

    alu_inst: entity work.alu_wRCA port map (
        alu_inA => accOut,
        alu_inB => internalBusOut,
        alu_op => aluOp,
        E => aluOut_e_flag,
        C => open,
        Z => aluOut_z_flag,
        alu_out => aluOut
    );

    aluOut2seg <= "000000" & e_flag & z_flag;

    acc_mux_inst: entity work.mux2 generic map (8)
    port map (
        s => accSel,
        i0 => aluOut,
        i1 => internalBusOut,
        o => accIn
    );

    acc_inst: entity work.reg generic map (8)
    port map (
        clk => clk,
        resetn => resetn,
        loadEnable => accLd,
        dataIn => accIn,
        dataOut => accOut
    );

    acc2seg <= accOut;

    ---- Flags

    e_flag_inst: entity work.reg generic map (1)
    port map (
        clk => clk,
        resetn => resetn,
        loadEnable => flagLd,
        dataIn(0) => aluOut_e_flag,
        dataOut(0) => e_flag
    );

    -- No carry flag??
    -- c_flag_inst: entity work.reg generic map (1)
    -- port map (
    --     clk => clk,
    --     resetn => resetn,
    --     loadEnable => flagLd,
    --     dataIn(0) => internalBusOut(7),
    --     dataOut(0) => c_flag
    -- );

    z_flag_inst: entity work.reg generic map (1)
    port map (
        clk => clk,
        resetn => resetn,
        loadEnable => flagLd,
        dataIn(0) => aluOut_z_flag,
        dataOut(0) => z_flag
    );

    ---- Data segment
    ds_inst: entity work.reg generic map (8)
    port map (
        clk => clk,
        resetn => resetn,
        loadEnable => dsLd,
        dataIn => accOut,
        dataOut => ds2seg
    );

end structural;