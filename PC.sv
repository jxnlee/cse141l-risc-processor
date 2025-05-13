// program counter
// supports both relative and absolute jumps
// use either or both, as desired
module PC #(parameter width = 12)(
  input reset,					// synchronous reset
        clk,
		    reljump_en,     // rel. jump enable
        absjump_en,				// abs. jump enable
  input         [width-1:0] target,	// how far/where to jump
  output logic  [width-1:0] prog_ctr
);

  always_ff @(posedge clk)
    if (reset)
	    prog_ctr <= '0;
	  else if (reljump_en)
	    prog_ctr <= target[width-1]? prog_ctr - target : prog_ctr + target;
    else if (absjump_en)
	    prog_ctr <= target;
    else
	    prog_ctr <= prog_ctr + 'b1;

endmodule