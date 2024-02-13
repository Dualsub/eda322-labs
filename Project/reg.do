restart -f -nowave
add wave clk resetn loadEnable dataIn dataOut

force loadEnable 0
force clk 0 0, 1 50ns -repeat 100ns

force resetn 0
# data out should be 0

run 40ns

# load data
force resetn 1
force loadEnable 1
force dataIn 8'b10101010

run 100ns

# should not change data out
force loadEnable 0
force dataIn 8'b01010101

run 100ns

# should reset data out
force resetn 0
run 100ns