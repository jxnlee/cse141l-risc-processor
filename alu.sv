// combinational -- no clock

module alu (
    input        [2:0]  alu_cmd,    // ALU instructions

    // 8-bit wide data path
    input        [7:0]  inAccum,    // accumulator (ALU output)
                        inOp,       // operand (ALU input)
    input               shift_cin,  // shift_carry in
    output logic [7:0]  result,
    output logic        shift_cout, // shift_carry out
                        pari,       // reduction XOR (output)
                        zero        // NOR (output)
);

  always_comb begin
    result      = 'b0;
    shift_cout  = 'b0;
    zero        = !result;
    pari        = ^result;
    logic [2:0] shift_amount = inOp[2:0];       // assign shift amount
    case (alu_cmd)
      3'b000:  // add 2 8-bit unsigned; automatically makes carry-out
      {shift_cout, result} = inAccum + inOp + shift_cin;
      3'b001: // left_shift
      begin
        {shift_cout, result}      = {inAccum, shift_cin};     // single left shift and assign shift carry out to MSB
        result                    = result << shift_amount;   // shift by remaining amount specified in inOp[2:0]
        result[shift_amount-1:0]  = {shift_amount{shift_cin}};// set LSBs to shift carry in
      end
      3'b010:  // right shift (alternative syntax -- works like left shift
      begin
        {result, shift_cout}      = {shift_cin, inAccum};     // single shift right and assign shift carry out to LSB
        result                    = result >> shift_amount;   // shfit by remaining amount specified in inOp[2:0]
        result[7:7-shift_amount]  = {shift_amount{shift_cin}};// set MSBs to shift carry in
      end
      3'b011:  // bitwise XOR
        result = inAccum ^ inOp;
      3'b100:  // bitwise AND (mask)
        result = inAccum & inOp;
      3'b101:  // bitwise OR
        result = inAccum | inOp;
      3'b110:  // subtract
        {shift_cout, result} = inAccum - inOp + shift_cin;
      3'b111:  // bitwise NOT
        result = ~inOp;
    endcase
  end

endmodule
