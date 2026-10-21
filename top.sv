module top;

  logic clk;

  initial clk = 0;
  always #5 clk = ~clk;

  fifo_if #(.FIFO_WIDTH(16)) vif (.clk(clk));

  FIFO #(.FIFO_WIDTH(16), .FIFO_DEPTH(8)) dut (.vif(vif));

  tb      tb_i  (.vif(vif));
  monitor mon_i (.vif(vif));

  always @(negedge vif.rst_n) begin
    #0;
    assert (dut.wr_ptr == 0 && dut.rd_ptr == 0 && dut.count == 0)
      else $error("Asynchronous reset did not immediately clear pointers/counter");
  end

endmodule