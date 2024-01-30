restart -f -nowave
add wave a b cin s cout

force a "00000000"
force b "00000000"
force cin "0"

run 100ns

# Should be 0 or 00

force a "00000001"
force b "00000001"
force cin "0"

run 100ns

# Should be 2 or 10

force a "00000001"
force b "00000001"
force cin "1"

run 100ns

# Should be 3 or 11

force a "00010010"
force b "00100010"
force cin "0"

run 100ns

# Should be 52 or 110100