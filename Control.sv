// control decoder
module Control #(parameter opwidth = 4, mcodebits = 4)(
  input        [mcodebits-1:0]  instr,    // subset of machine code (any width you need)
  input                         ldImmed,
  output logic                  RegDst,   // not in place (may be removed since accumulator architecture but keeping in case)
                                Branch,   // branch instruction
                                MemtoReg, // write from memory to register
                                MemWrite, // write from register to memory
                                ALUSrc,   // immediate alu inOp (may be removed since all alu is from register but keeping in case)
                                RegWrite, // write to register
  output logic [opwidth-1:0]    ALUOp);	  // for up to 8 ALU operations

always_comb begin
// defaults
  RegDst    = 'b0;   // 1: not in place  just leave 0
  Branch 	  = 'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	  =	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    = instr; // alu cmd will just correspond to instruction by default
  if (ldImmed)
    ALUSrc = 'b1;
  else
  begin
    case (instr)
      4'b0000: // shift instructions
        ALUSrc = 'b1;
      4'b0001, 4'b0010, 4'b0011: // branch instructions
      begin
        Branch = 'b1;
        RegWrite = 'b0;
      end
      4'b0100:  // load instruction
        MemtoReg = 'b1;
      4'b0101:  // store instruction
      begin
        MemWrite = 'b1;
        RegWrite = 'b0;
      end
      4'b0110:  // push in
      4'b0111:  // pop out
        RegDst = 'b1;
      4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101: // bitwise AND, OR, XOR, NOT; add & sub
      4'b1110:  // TBD
      4'b1111:  // done flag
        RegWrite = 'b0;
    endcase
  end
end
	
endmodule