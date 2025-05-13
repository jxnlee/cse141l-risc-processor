// cache memory/register file
// default address pointer width = 4, for 16 registers
module reg_file #(parameter pw=4)(
  input[7:0] data_in,
  input      clk,
  input      wr_en,           // write enable
  input[pw:0] wr_addr,		  // write address pointer
              rd_addrOpr,		  // read address pointers
	//rd_addrB, if we always read from accumulator (R0), then no need for second read port
  output logic[7:0] opr_out, // read data
                    acc_out);

  logic[7:0] core[2**pw];    // 2-dim array  8 wide  16 deep

// reads are combinational
  assign opr_out = rd_addrOpr? core[rd_addrOpr] : 'b0;
  assign acc_out = core[0];

// writes are sequential (clocked)
  always_ff @(posedge clk)
    if(wr_en)				   // anything but stores or no ops
      core[wr_addr] <= data_in; 

endmodule
/*
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
	  xxxx_xxxx
*/
