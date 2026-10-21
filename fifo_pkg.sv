package fifo_pkg;

  parameter FIFO_WIDTH = 16;

  class FIFO_transaction;

    rand bit                     rst_n;
    rand bit                     wr_en;
    rand bit                     rd_en;
    rand bit [FIFO_WIDTH-1:0]    data_in;

    logic [FIFO_WIDTH-1:0]       data_out;
    bit                          full;
    bit                          empty;
    bit                          almostfull;
    bit                          almostempty;
    bit                          overflow;
    bit                          underflow;
    bit                          wr_ack;

    int RD_EN_ON_DIST;
    int WR_EN_ON_DIST;

    function new(int rd_dist = 30, int wr_dist = 70);
      RD_EN_ON_DIST = rd_dist;
      WR_EN_ON_DIST = wr_dist;
    endfunction

    constraint c_reset {
      rst_n dist {1'b1 :/ 90, 1'b0 :/ 10};
    }

    constraint c_wr_en {
      wr_en dist {1'b1 := WR_EN_ON_DIST, 1'b0 := (100 - WR_EN_ON_DIST)};
    }

    constraint c_rd_en {
      rd_en dist {1'b1 := RD_EN_ON_DIST, 1'b0 := (100 - RD_EN_ON_DIST)};
    }

  endclass

endpackage