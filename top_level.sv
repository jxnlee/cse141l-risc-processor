// sample top level design
module top_level(
  input         clk,
                reset,
                start, 
  output logic  done
  );

  parameter PC_WIDTH = 12,          // program counter width
            ALU_CMD_WIDTH = 4;      // ALU command bit width
  wire [PC_WIDTH-1:0]   target,     // jump 
                        prog_ctr;   // program counter
  wire                  RegWrite;
  wire [7:0]            oprData,		// data from operand reg
                        accData,   // data from accumulator
                        regWrite_data,  // data to RegFile
                        muxB, 
			                  aluResult,               // alu output
                        immed;
  logic sc_in,                  // shift/carry out from/to ALU
   		  pariQ,              	  // registered parity flag from ALU
		    zeroQ,                  // registered zero flag from ALU 
        sc_out;
  wire  relj_en;                   // from control to PC; relative jump enable
  wire  pari,
        zero,
        sc_clr,
        sc_en,
        MemWrite,
        MemtoReg,
        RegDst,
        ALUSrc;		              // immediate switch
  wire  ldImmed,
        shift_dir;
    wire [2:0]  shift_amnt;
  wire  [ALU_CMD_WIDTH-1:0] aluOp,
                            opcode;
  wire  [8:0]               mach_code;        //  9 bit machine code
  wire  [3:0]               oprAddr,
                            muxRegDst; // address pointers to reg_file
  // contains machine code
  instr_ROM ir1
  (
    .prog_ctr   (prog_ctr), // input: program counter
    .mach_code  (mach_code) // output: machine code
  );

  assign opcode = mach_code[7:4];
  assign oprAddr = mach_code[3:0];
  assign ldImmed = mach_code[8];
  assign immed = mach_code[7:0];

  // control decoder
  Control ctl1
  (
    .instr    (opcode),
    .RegDst   (RegDst), 
    .Branch   (relj_en), 
    .MemWrite (MemWrite), 
    .ALUSrc   (ALUSrc), 
    .RegWrite (RegWrite),     
    .MemtoReg (MemtoReg),
    .ALUOp    (aluOp)     // ALU command
  ); 

  // fetch subassembly
  PC #(.width(PC_WIDTH)) pc1 			  // D sets program counter width
  (
    .reset      (reset),
    .clk        (clk),
    .reljump_en (relj_en),
    .absjump_en (absj),
    .target     (12'(signed'(oprData))),
    .prog_ctr   (prog_ctr)
  );

  assign muxRegDst = RegDst? oprAddr : 4'b0000; // R0 is always the accumulator

  reg_file #(.pw(4)) rf1
  (
    .data_in     (regWrite_data),	   // loads, most ops
    .clk        (clk),
    .wr_en      (RegWrite),
    .rd_addrOpr (oprAddr),
    .wr_addr    (muxRegDst),      // in place operation
    .opr_out    (oprData),
    .acc_out    (accData)
  ); 

  assign muxB = ALUSrc? immed : oprData;

  alu alu1
  (
    .aluOp  (aluOp),
    .inAcc  (accData),
    .inOpr  (muxB),
    .cin    (sc_in),   // output from sc register
    .result (aluResult),
    .cout   (sc_out), // input to sc register
    .pari   (pari)
  );  

  dat_mem dm1
  (
    .data_in  (accData),  // from reg_file
    .clk      (clk),  // clock
		.wr_en    (MemWrite), // stores
		.addr     (oprData),  // from reg_file
    .start    (start),
    .data_out (regWrite_data)
  ); // write data to regfile

// registered flags from ALU
  always_ff @(posedge clk) 
  begin
    pariQ <= pari;
	  zeroQ <= zero;
    if(sc_clr)
	    sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_out;
  end

  assign done = prog_ctr == 128;
 
endmodule