module monitor (fifo_if.MONITOR vif);

  import fifo_pkg::*;
  import fifo_coverage_pkg::*;
  import fifo_scoreboard_pkg::*;
  import shared_pkg::*;

  FIFO_transaction m_txn;
  FIFO_coverage    m_cov;
  FIFO_scoreboard  m_sb;

  initial begin
    m_txn = new();
    m_cov = new();
    m_sb  = new();

    forever begin
      @(sample_event);

      m_txn.rst_n       = vif.rst_n;
      m_txn.wr_en       = vif.wr_en;
      m_txn.rd_en       = vif.rd_en;
      m_txn.data_in     = vif.data_in;
      m_txn.data_out    = vif.data_out;
      m_txn.full        = vif.full;
      m_txn.empty       = vif.empty;
      m_txn.almostfull  = vif.almostfull;
      m_txn.almostempty = vif.almostempty;
      m_txn.overflow    = vif.overflow;
      m_txn.underflow   = vif.underflow;
      m_txn.wr_ack      = vif.wr_ack;

      fork
        m_cov.sample_data(m_txn);
        m_sb.check_data(m_txn);
      join

      if (test_finished) begin
        $display("TEST FINISHED: correct_count=%0d error_count=%0d", correct_count, error_count);
        $stop;
      end
    end
  end

endmodule
