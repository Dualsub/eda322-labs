restart -f -nowave
add wave clk master_load_enable resetn pc2seg_tb imDataOut2seg_tb[11:8] imDataOut2seg_tb[7:0] acc2seg_tb aluOut2seg_tb busOut2seg_tb 
run 1700ns -all