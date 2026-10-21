module tb (fifo_if.TB vif);

  import fifo_pkg::*;
  import shared_pkg::*;

  FIFO_transaction t_txn;

  initial begin
    t_txn = new();

    vif.rst_n   = 0;
    vif.wr_en   = 0;
    vif.rd_en   = 0;
    vif.data_in = 0;
    repeat (2) @(negedge vif.clk);
    vif.rst_n = 1;

    repeat (2000) begin
      assert(t_txn.randomize());

      vif.rst_n   = t_txn.rst_n;
      vif.wr_en   = t_txn.wr_en;
      vif.rd_en   = t_txn.rd_en;
      vif.data_in = t_txn.data_in;

      @(negedge vif.clk);
      ->sample_event;
    end

    vif.wr_en = 0;
    vif.rd_en = 0;
    @(negedge vif.clk);
    test_finished = 1;
    ->sample_event;
  end

endmodule
