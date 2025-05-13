// combinational -- no clock

module alu (
    input [3:0] alu_cmd,    // ALU instructions

    // 8-bit wide data path
    input [7:0] inAccum,    // accumulator (ALU output)
                inOp,       // operand (ALU input)
    input       cin,  // shift_carry in
    output logic [7:0]  result,
    output logic        cout, // shift_carry out
                        pari,       // reduction XOR (output)
                        zero        // NOR (output)
);
logic       shift_dir;
logic [2:0] shift_amount;

  always_comb 
  begin
    result        = 'b0;
    cout          = 'b0;
    zero          = !result;
    pari          = ^result;
    shift_dir     = inOp[3];
    shift_amount  = inOp[2:0];
    case (alu_cmd)
      4'b0000:  // shift instructions // add 2 8-bit unsigned; automatically makes carry-out
      begin
        if (shift_dir)  // arithmetic shift right
        begin
          result = inAccum >>> shift_amount + 1;
          cout = inAccum[0];
        end
        else            // shift left
        begin
          result = inAccum << shift_amount + 1;
          cout = inAccum[7];
        end
      end
      4'b0001, 4'b0010, 4'b0011: // branch instructions
        result = inAccum;
      4'b0100, 4'b0101: // load and store
        result = inOp;
      4'b0110: // push in
        result = inOp;
      4'b0111: // pop out
        result = inAccum;
      4'b1000: // bitwise AND
        result = inAccum & inOp;
      4'b1001: // bitwise OR
        result = inAccum | inOp;
      4'b1010: // bitwise XOR
        result = inAccum ^ inOp;
      4'b1011: // bitwise NOT
        result = ~inOp;
      4'b1100: // add
        {cout, result} = inAccum + inOp + cin;
      4'b1101: // subtract
        {cout, result} = inAccum - inOp + cin;
      4'b1110: // tbd, pass for now
        result = inAccum;
      4'b1111: // acknowledge / flag
        result = 'b0;
    endcase
  end

endmodule
