restart -f -nowave
add wave alu_inA alu_inB alu_op alu_out

# ROL

force alu_inA "00001000"
force alu_inB "00010000"
force alu_op "00"

run 100ns

# AND

force alu_inA "00001000"
force alu_inB "00011000"
force alu_op "01"

run 100ns

# ADD

force alu_inA "00001000"
force alu_inB "00011000"
force alu_op "10"

run 100ns

# SUB

force alu_inA "00001000"
force alu_inB "00011000"
force alu_op "11"

run 100ns

