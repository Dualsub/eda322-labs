library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_textio.all;

LIBRARY std;
USE std.textio.all;

library work;

entity testbench_lab4 is
end entity testbench_lab4;

architecture test_arch of testbench_lab4 is
    constant c_CLK_PERIOD : time := 10 ns;
    constant c_MLE_PERIOD : time := 20 ns;

    constant c_MAX_FILE_LENGTH : integer := 32;
    
    component EDA322_processor is
    generic (dInitFile : string; iInitFile : string);
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);
        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
	    aluOut2seg         : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        ds2seg             : out std_logic_vector(7 downto 0)
    );
    end component EDA322_processor;
    
    signal clk                  : std_logic    := '0';
    signal resetn               : std_logic    := '0';
    signal master_load_enable   : std_logic    := '0';
   
    signal extIn_tb          : std_logic_vector(7 downto 0);
    signal aluOut2seg_tb     : std_logic_vector(7 downto 0);
    signal busOut2seg_tb     : std_logic_vector(7 downto 0);

    -- Signals of interest
    signal pc2seg_tb         : std_logic_vector(7 downto 0);
    signal imDataOut2seg_tb  : std_logic_vector(11 downto 0);
    signal dmDataOut2seg_tb  : std_logic_vector(7 downto 0);
    signal acc2seg_tb        : std_logic_vector(7 downto 0);
    signal ds2seg_tb         : std_logic_vector(7 downto 0);

    type vector_array is array (natural range <>) of std_logic_vector;

    -- Function to read a .trace file and return a vector_array of unspecifed length
    impure function init_trace_wfile(trace_file_name : in string; width: in integer) return vector_array is
        file trace_file : text open read_mode is trace_file_name;
        variable trace_line : line;
        variable temp_bv : bit_vector(width-1 downto 0);
        variable temp_arr : vector_array(0 to c_MAX_FILE_LENGTH-1)(width-1 downto 0);
        variable line_index : integer := 0;
    begin
        while not endfile(trace_file) loop
            readline(trace_file, trace_line);
            read(trace_line, temp_bv);
            temp_arr(line_index) := to_stdlogicvector(temp_bv);
            line_index := line_index + 1;
        end loop;          
        return temp_arr;
    end function;

    signal expected_pc2seg : vector_array(0 to c_MAX_FILE_LENGTH-1)(7 downto 0) := init_trace_wfile("../Lab4/lab4_files/pc2seg.trace", 8);
    signal expected_imDataOut2seg : vector_array(0 to c_MAX_FILE_LENGTH-1)(11 downto 0) := init_trace_wfile("../Lab4/lab4_files/imDataOut2seg.trace", 12);
    signal expected_dmDataOut2seg : vector_array(0 to c_MAX_FILE_LENGTH-1)(7 downto 0) := init_trace_wfile("../Lab4/lab4_files/dmDataOut2seg.trace", 8);
    signal expected_acc2seg : vector_array(0 to c_MAX_FILE_LENGTH-1)(7 downto 0) := init_trace_wfile("../Lab4/lab4_files/acc2seg.trace", 8);
    signal expected_ds2seg : vector_array(0 to c_MAX_FILE_LENGTH-1)(7 downto 0) := init_trace_wfile("../Lab4/lab4_files/ds2seg.trace", 8);
    
begin

    proc_inst: component EDA322_processor
        generic map(dInitFile => "../Lab4/lab4_files/d_memory_lab4.mif", iInitFile => "../Lab4/lab4_files/i_memory_lab4.mif")
        port map(
            clk                 => clk,
            resetn              => resetn,
            master_load_enable  => master_load_enable,

            extIn               => extIn_tb,
            aluOut2seg          => aluOut2seg_tb,
            busOut2seg          => busOut2seg_tb,

            pc2seg              => pc2seg_tb,
            imDataOut2seg       => imDataOut2seg_tb,
            dmDataOut2seg       => dmDataOut2seg_tb,
            acc2seg             => acc2seg_tb,
            ds2seg              => ds2seg_tb
        );

    -- Input generation
    clk <= not clk after c_CLK_PERIOD/2;
    master_load_enable <= not master_load_enable after c_MLE_PERIOD/2;
    resetn <= '0', '1' after 10 ns;
    extIn_tb <= "00001111";

    ---- Output checking

    -- Check pc2seg
    process(pc2seg_tb)
        variable curr_index : integer := 0;
    begin
        if resetn = '1' then
            if pc2seg_tb = expected_pc2seg(curr_index) then
                curr_index := curr_index + 1;
            else
                report "Expected: " & to_string(to_integer(unsigned(expected_pc2seg(curr_index)))) severity note;
                report "Got: " & to_string(to_integer(unsigned(pc2seg_tb))) severity note;
                assert false report "pc2seg test failed" severity failure;
            end if;
        end if;
    end process;

    -- Check imDataOut2seg
    process(imDataOut2seg_tb)
        variable curr_index : integer := 0;
    begin
        if resetn = '1' then
            if imDataOut2seg_tb = expected_imDataOut2seg(curr_index) then
                curr_index := curr_index + 1;
            else
                report "Expected: " & to_string(to_integer(unsigned(expected_imDataOut2seg(curr_index)))) severity note;
                report "Got: " & to_string(to_integer(unsigned(imDataOut2seg_tb))) severity note;
                assert false report "imDataOut2seg_ test failed" severity failure;
            end if;
        end if;
    end process;

    -- Check dmDataOut2seg
    process(dmDataOut2seg_tb)
        variable curr_index : integer := 0;
    begin
        if resetn = '1' then
            if dmDataOut2seg_tb = expected_dmDataOut2seg(curr_index) then
                curr_index := curr_index + 1;
            else
                report "Expected: " & to_string(to_integer(unsigned(expected_dmDataOut2seg(curr_index)))) severity note;
                report "Got: " & to_string(to_integer(unsigned(dmDataOut2seg_tb))) severity note;
                assert false report "dmDataOut2seg test failed" severity failure;
            end if;
        end if;
    end process;

    -- Check acc2seg
    process(acc2seg_tb)
        variable curr_index : integer := 0;
    begin
        if resetn = '1' then
            if acc2seg_tb = expected_acc2seg(curr_index) then
                curr_index := curr_index + 1;
            else
                report "Expected: " & to_string(to_integer(unsigned(expected_acc2seg(curr_index)))) severity note;
                report "Got: " & to_string(to_integer(unsigned(acc2seg_tb))) severity note;
                assert false report "acc2seg test failed" severity failure;
            end if;
        end if;
    end process;

    -- Check ds2seg
    process(ds2seg_tb)
        variable curr_index : integer := 0;
    begin
        if resetn = '1' then
            if ds2seg_tb = expected_ds2seg(curr_index) then
                curr_index := curr_index + 1;
            else
                report "Expected: " & to_string(to_integer(unsigned(expected_ds2seg(curr_index)))) severity note;
                report "Got: " & to_string(to_integer(unsigned(ds2seg_tb))) severity note;
                assert false report "ds2seg test failed" severity failure;
            end if;
        end if;
    end process;

end architecture test_arch;


