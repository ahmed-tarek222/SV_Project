package fifo_coverage_pkg;
  import fifo_pkg::*;

  class FIFO_coverage;

    FIFO_transaction F_cvg_txn;

    covergroup cvr_gp;
      cx_full:        cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.full;
      cx_empty:       cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.empty;
      cx_almostfull:  cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostfull;
      cx_almostempty: cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostempty;
      cx_overflow:    cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.overflow;
      cx_underflow:   cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.underflow;
      cx_wrack:       cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.wr_ack;
    endgroup

    function new();
      F_cvg_txn = new();
      cvr_gp = new();
    endfunction

    function void sample_data(FIFO_transaction F_txn);
      F_cvg_txn = F_txn;
      cvr_gp.sample();
    endfunction

  endclass

endpackage
