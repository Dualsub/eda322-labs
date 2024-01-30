restart -f -nowave
add wave a b e

force a "00100000"
force b "00100000"

run 100ns

# Should be 0 or 00

force a "00100001"
force b "00000001"

run 100ns
