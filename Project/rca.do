restart -f -nowave
add wave a b cin s cout

force a 8'b00000000
force b 8'b00000000
force cin 1'b1

run 100ns

force a  8'b00000001
force b  8'b00000001
force cin 1'b0

run 100ns

force a  8'b00000001
force b  8'b00000001
force cin  1'b1

run 100ns

force a  8'b11111111
force b  8'b11111110
force cin  1'b1

run 100ns