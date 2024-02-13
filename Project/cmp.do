restart -f -nowave
add wave a b e

force a "00000100"
force b "00000100"

run 100ns

force a "00000001"
force b "00000100"

run 100ns