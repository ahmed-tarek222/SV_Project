module FIFO (fifo_if.DUT vif);

parameter FIFO_WIDTH = 16;
parameter FIFO_DEPTH = 8;

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge vif.clk or negedge vif.rst_n) begin
	if (!vif.rst_n) begin
		wr_ptr <= 0;
	end
	else if (vif.wr_en && count < FIFO_DEPTH) begin
		mem[wr_ptr] <= vif.data_in;
		vif.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin
		vif.wr_ack <= 0;
		if (vif.full & vif.wr_en)
			vif.overflow <= 1;
		else
			vif.overflow <= 0;
	end
end

always @(posedge vif.clk or negedge vif.rst_n) begin
	if (!vif.rst_n) begin
		rd_ptr <= 0;
		vif.underflow <= 0;               // BUG FIX #2: underflow must be sequential, not assign
	end
	else if (vif.rd_en && count != 0) begin
		vif.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		vif.underflow <= 0;               // BUG FIX #2: underflow must be sequential, not assign
	end
	else if (vif.rd_en && count == 0) begin
		vif.underflow <= 1;               // BUG FIX #2: underflow must be sequential, not assign
	end
	else begin
		vif.underflow <= 0;               // BUG FIX #2: underflow must be sequential, not assign
	end
end

always @(posedge vif.clk or negedge vif.rst_n) begin
	if (!vif.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({vif.wr_en, vif.rd_en} == 2'b10) && !vif.full)
			count <= count + 1;
		else if ( ({vif.wr_en, vif.rd_en} == 2'b01) && !vif.empty)
			count <= count - 1;
	end
end

assign vif.full = (count == FIFO_DEPTH)? 1 : 0;
assign vif.empty = (count == 0)? 1 : 0;
assign vif.almostfull = (count == FIFO_DEPTH-1)? 1 : 0;   // BUG FIX #1: was FIFO_DEPTH-2 (off by one)
assign vif.almostempty = (count == 1)? 1 : 0;

property p_reset_behavior;
  @(posedge vif.clk) !vif.rst_n |-> (wr_ptr == 0 && rd_ptr == 0 && count == 0);
endproperty
assert property (p_reset_behavior)
  else $error("Reset behavior violated: pointers/counter not zero during reset");

property p_wr_ack;
  @(posedge vif.clk) disable iff (!vif.rst_n) (vif.wr_en && !vif.full) |=> vif.wr_ack;
endproperty
assert property (p_wr_ack)
  else $error("wr_ack not asserted after a valid write request");

property p_overflow;
  @(posedge vif.clk) disable iff (!vif.rst_n) (vif.wr_en && vif.full) |=> vif.overflow;
endproperty
assert property (p_overflow)
  else $error("overflow not asserted after a write attempt while full");

property p_underflow;
  @(posedge vif.clk) disable iff (!vif.rst_n) (vif.rd_en && vif.empty) |=> vif.underflow;
endproperty
assert property (p_underflow)
  else $error("underflow not asserted after a read attempt while empty");

property p_empty;
  @(posedge vif.clk) disable iff (!vif.rst_n) (count == 0) |-> vif.empty;
endproperty
assert property (p_empty)
  else $error("empty not asserted when count is zero");

property p_full;
  @(posedge vif.clk) disable iff (!vif.rst_n) (count == FIFO_DEPTH) |-> vif.full;
endproperty
assert property (p_full)
  else $error("full not asserted when count equals FIFO_DEPTH");

property p_almostfull;
  @(posedge vif.clk) disable iff (!vif.rst_n) (count == FIFO_DEPTH-1) |-> vif.almostfull;
endproperty
assert property (p_almostfull)
  else $error("almostfull not asserted when count equals FIFO_DEPTH-1");

property p_almostempty;
  @(posedge vif.clk) disable iff (!vif.rst_n) (count == 1) |-> vif.almostempty;
endproperty
assert property (p_almostempty)
  else $error("almostempty not asserted when count equals 1");

property p_wr_ptr_wrap;
  @(posedge vif.clk) disable iff (!vif.rst_n)
    (vif.wr_en && !vif.full && wr_ptr == FIFO_DEPTH-1) |=> (wr_ptr == 0);
endproperty
assert property (p_wr_ptr_wrap)
  else $error("wr_ptr did not wrap around to 0 after reaching FIFO_DEPTH-1");

property p_rd_ptr_wrap;
  @(posedge vif.clk) disable iff (!vif.rst_n)
    (vif.rd_en && !vif.empty && rd_ptr == FIFO_DEPTH-1) |=> (rd_ptr == 0);
endproperty
assert property (p_rd_ptr_wrap)
  else $error("rd_ptr did not wrap around to 0 after reaching FIFO_DEPTH-1");

property p_wr_ptr_range;
  @(posedge vif.clk) disable iff (!vif.rst_n) (wr_ptr < FIFO_DEPTH);
endproperty
assert property (p_wr_ptr_range)
  else $error("wr_ptr exceeded FIFO_DEPTH entries");

property p_rd_ptr_range;
  @(posedge vif.clk) disable iff (!vif.rst_n) (rd_ptr < FIFO_DEPTH);
endproperty
assert property (p_rd_ptr_range)
  else $error("rd_ptr exceeded FIFO_DEPTH entries");

property p_count_range;
  @(posedge vif.clk) disable iff (!vif.rst_n) (count <= FIFO_DEPTH);
endproperty
assert property (p_count_range)
  else $error("count exceeded FIFO_DEPTH");

endmodule
