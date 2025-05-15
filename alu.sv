// combinational -- no clock

module alu (
    input [3:0] aluOp,    // ALU instructions

    // 8-bit wide data path
    input [7:0] inAcc,    // accumulator (ALU output)
                inOpr,       // operand (ALU input)
    input       cin,  // shift_carry in
                ldImmed,
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
    shift_dir     = inOpr[3];
    shift_amount  = inOpr[2:0];
    if (ldImmed) result = inOpr;
    else
    begin
      case (aluOp)
        4'b0000:  // shift instructions // add 2 8-bit unsigned; automatically makes carry-out
        begin
          if (shift_dir)  // arithmetic shift right
          begin
            result = inAcc >>> shift_amount + 1;
            cout = inAcc[0];
          end
          else            // shift left
          begin
            result = inAcc << shift_amount + 1;
            cout = inAcc[7];
          end
        end
        4'b0001, 4'b0010, 4'b0011: // branch instructions
          result = inAcc;
        4'b0100, 4'b0101: // load and store
          result = inOpr;
        4'b0110: // push in
          result = inOpr;
        4'b0111: // pop out
          result = inAcc;
        4'b1000: // bitwise AND
          result = inAcc & inOpr;
        4'b1001: // bitwise OR
          result = inAcc | inOpr;
        4'b1010: // bitwise XOR
          result = inAcc ^ inOpr;
        4'b1011: // bitwise NOT
          result = ~inOpr;
        4'b1100: // add
          {cout, result} = inAcc + inOpr + cin;
        4'b1101: // subtract
          {cout, result} = inAcc - inOpr + cin;
        4'b1110: // tbd, pass for now
          result = inAcc;
        4'b1111: // acknowledge / flag
          result = 'b0;
      endcase
    end
  end

endmodule
