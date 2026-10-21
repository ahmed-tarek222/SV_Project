vlib work
vmap work work

vlog -sv shared_pkg.sv
vlog -sv fifo_pkg.sv
vlog -sv fifo_coverage_pkg.sv
vlog -sv fifo_scoreboard_pkg.sv
vlog -sv +cover=sbtc fifo_if.sv
vlog -sv +cover=sbtc FIFO.sv
vlog -sv monitor.sv
vlog -sv tb.sv
vlog -sv top.sv

vsim -voptargs=+acc -coverage -assertcover work.top

run 0
add wave -radix unsigned top/vif/clk
add wave -radix unsigned top/vif/rst_n
add wave -radix unsigned top/vif/wr_en
add wave -radix unsigned top/vif/rd_en
add wave -radix unsigned top/vif/data_in
add wave -radix unsigned top/vif/data_out
add wave -radix unsigned top/vif/full
add wave -radix unsigned top/vif/empty
add wave -radix unsigned top/vif/almostfull
add wave -radix unsigned top/vif/almostempty
add wave -radix unsigned top/vif/overflow
add wave -radix unsigned top/vif/underflow
add wave -radix unsigned top/vif/wr_ack
add wave -radix unsigned top/dut/wr_ptr
add wave -radix unsigned top/dut/rd_ptr
add wave -radix unsigned top/dut/count

run -all

coverage save -codeAll -cvg -assert fifo_cov.ucdb
vcover report fifo_cov.ucdb -details -output fifo_cov_report.txt
vcover report fifo_cov.ucdb -cvg -details -output fifo_functcov_report.txt
vcover report fifo_cov.ucdb -assert -details -output fifo_assert_report.txt
