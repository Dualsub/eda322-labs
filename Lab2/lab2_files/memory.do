restart -f -nowave
add wave clk readEn writeEn address dataIn dataOut

force clk 0 0, 1 50ns -repeat 100ns

run 40ns

# write to 20 address 10
force address 8'b00000010
force dataIn 8'b00001100
force writeEn 1
force readEn 0

run 100ns

# read from 20 address 10
force address 8'b00000010
force writeEn 0
force readEn 1

run 100ns



