restart -f -nowave
add wave decoEnable decoSel imDataOut dmDataOut accOut extIn busOut

force decoEnable 0
force decoSel 2'b00

force imDataOut 8'b00000001
force dmDataOut 8'b00000010
force accOut 8'b00000011
force extIn 8'b00000100

run 100ns

force decoEnable 1

force decoSel 2'b00
run 100ns

force decoSel 2'b01
run 100ns

force decoSel 2'b10
run 100ns

force decoSel 2'b11
run 100ns

force decoEnable 0
run 100ns
