// sample top level design
module top_level(
  input         clk,
                reset,
                req, 
  output logic  done
  );

  parameter PC_WIDTH = 12,          // program counter width
            ALU_CMD_WIDTH = 4;      // ALU command bit width
  wire [PC_WIDTH-1:0]   target,     // jump 
                        prog_ctr;   // program counter
  wire                  RegWrite;
  wire [7:0]            data_accum,       // data from RegFile
                        data_op,		// data from RegFile
                        muxB, 
			            result,               // alu output
                        immed;
  logic sc_in,                  // shift/carry out from/to ALU
   		pariQ,              	  // registered parity flag from ALU
		zeroQ;                  // registered zero flag from ALU 
  wire  relj;                   // from control to PC; relative jump enable
  wire  pari,
        zero,
		sc_clr,
		sc_en,
        MemWrite,
        ALUSrc;		              // immediate switch
  wire  ld_immed,
        shift_dir;
    wire [2:0]  shift_amnt;
  wire  [ALU_CMD_WIDTH-1:0] alu_cmd;
  wire  [8:0]               mach_code;        //  9 bit machine code
  wire  [3:0]               reg_addr;// address pointers to reg_file
  logic [2:0]               how_high;
// fetch subassembly
  PC #(.width(PC_WIDTH)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk              ,
		 .reljump_en (relj),
		 .absjump_en (absj),
		 .target           ,
		 .prog_ctr          );

// lookup table to facilitate jumps/branches

  //PC_LUT #(.width(PC_WIDTH))
  //  pl1 (.addr  (how_high),
  //       .target          );   

// contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

// control decoder
  Control ctl1(.instr(),
  .RegDst  (), 
  .Branch  (relj)  , 
  .How_high(how_high) ,
  .MemWrite , 
  .ALUSrc   , 
  .RegWrite   ,     
  .MemtoReg(),
  .ALUOp());

  assign reg_addr = mach_code[3:0];
  assign alu_cmd  = mach_code[7:4];
  assign ld_immed = mach_code[8];
  assign immed = mach_code[7:0];
  

  reg_file #(.pw(3)) rf1(.dat_in(regfile_dat),	   // loads, most ops
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(rd_addrA),
              .rd_addrB(rd_addrB),
              .wr_addr (rd_addrB),      // in place operation
              .datA_out(datA),
              .datB_out(datB)); 

  assign muxB = ALUSrc? immed : datB;

  alu alu1(.alu_cmd(),
    .inA    (datA),
    .inB    (muxB),
    .sc_i   (sc),   // output from sc register
    .result       ,
    .sc_o   (sc_o), // input to sc register
    .pari  );  

  dat_mem dm1(.dat_in(datB)  ,  // from reg_file
    .clk           ,
		.wr_en  (MemWrite), // stores
		.addr   (datA),
    .dat_out());        // FIX THIS!  No Connects

// registered flags from ALU
  always_ff @(posedge clk) begin
    pariQ <= pari;
	zeroQ <= zero;
    if(sc_clr)
	  sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_o;
  end

  assign done = prog_ctr == 128;
 
endmodule