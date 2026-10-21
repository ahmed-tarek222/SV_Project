package fifo_scoreboard_pkg;
  import fifo_pkg::*;
  import shared_pkg::*;

  class FIFO_scoreboard;

    parameter FIFO_DEPTH = 8;
    localparam max_fifo_addr = $clog2(FIFO_DEPTH);

    bit [FIFO_WIDTH-1:0]      mem_ref[FIFO_DEPTH];
    bit [max_fifo_addr-1:0]   wr_ptr_ref, rd_ptr_ref;
    bit [max_fifo_addr:0]     count_ref;

    logic [FIFO_WIDTH-1:0] data_out_ref;
    bit full_ref, empty_ref, almostfull_ref, almostempty_ref;
    bit overflow_ref, underflow_ref, wr_ack_ref;

    function new();
      wr_ptr_ref      = 0;
      rd_ptr_ref      = 0;
      count_ref       = 0;
      data_out_ref    = 'x;
      full_ref        = 0;
      empty_ref       = 1;
      almostfull_ref  = 0;
      almostempty_ref = 0;
      overflow_ref    = 0;
      underflow_ref   = 0;
      wr_ack_ref      = 0;
    endfunction

    function void reference_model(FIFO_transaction F_txn);
      bit [FIFO_WIDTH-1:0] rd_snapshot;

      rd_snapshot = mem_ref[rd_ptr_ref];

      if (!F_txn.rst_n) begin
        wr_ptr_ref    = 0;
        rd_ptr_ref    = 0;
        count_ref     = 0;
        wr_ack_ref    = 0;
        overflow_ref  = 0;
        underflow_ref = 0;
      end
      else begin
        if (F_txn.wr_en && count_ref < FIFO_DEPTH) begin
          mem_ref[wr_ptr_ref] = F_txn.data_in;
          wr_ack_ref = 1;
          wr_ptr_ref = wr_ptr_ref + 1;
        end
        else begin
          wr_ack_ref = 0;
          if (full_ref && F_txn.wr_en)
            overflow_ref = 1;
          else
            overflow_ref = 0;
        end

        if (F_txn.rd_en && count_ref != 0) begin
          data_out_ref = rd_snapshot;
          rd_ptr_ref = rd_ptr_ref + 1;
          underflow_ref = 0;
        end
        else if (F_txn.rd_en && count_ref == 0) begin
          underflow_ref = 1;
        end
        else begin
          underflow_ref = 0;
        end

        if (({F_txn.wr_en, F_txn.rd_en} == 2'b10) && !full_ref)
          count_ref = count_ref + 1;
        else if (({F_txn.wr_en, F_txn.rd_en} == 2'b01) && !empty_ref)
          count_ref = count_ref - 1;
      end

      full_ref        = (count_ref == FIFO_DEPTH);
      empty_ref       = (count_ref == 0);
      almostfull_ref  = (count_ref == FIFO_DEPTH-1);
      almostempty_ref = (count_ref == 1);
    endfunction

    function void check_data(FIFO_transaction F_txn);
      reference_model(F_txn);

      if (F_txn.data_out === data_out_ref) begin
        correct_count++;
      end
      else begin
        error_count++;
        $display("SCOREBOARD ERROR: data_out=%0d expected=%0d", F_txn.data_out, data_out_ref);
      end
    endfunction

  endclass

endpackage