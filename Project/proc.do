restart -f -nowave
add wave clk resetn aluOut2seg_tb ds2seg_tb busOut2seg_tb pc2seg_tb imDataOut2seg_tb dmDataOut2seg_tb outState_tb acc2seg_tb master_load_enable 
run 6000ns -all
