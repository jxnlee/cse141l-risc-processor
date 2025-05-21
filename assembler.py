# assembler.py

# Define the instruction set and their corresponding binary codes
INSTRUCTION_SET = {
    # I-type
    "LDI":  {"type": "I", "opcode": "1"},  # 1 bit type (1), 8-bit immediate

    # S-type (shifts)
    "SHL":  {"type": "S", "opcode": "00000"},  # 0 + 5 bits opcode + 3 bits immediate
    "ASR":  {"type": "S", "opcode": "00001"},

    # R-type (all others)
    "B":     {"type": "R", "opcode": "0001"},
    "BEQZ":  {"type": "R", "opcode": "0010"},
    "BLTZ":  {"type": "R", "opcode": "0011"},
    "LDR":   {"type": "R", "opcode": "0100"},
    "STR":   {"type": "R", "opcode": "0101"},
    "PIN":   {"type": "R", "opcode": "0110"},
    "POUT":  {"type": "R", "opcode": "0111"},
    "AND":   {"type": "R", "opcode": "1000"},
    "OR":    {"type": "R", "opcode": "1001"},
    "XOR":   {"type": "R", "opcode": "1010"},
    "NOT":   {"type": "R", "opcode": "1011"},
    "ADD":   {"type": "R", "opcode": "1100"},
    "SUB":   {"type": "R", "opcode": "1101"},
    "TBD":   {"type": "R", "opcode": "1110"},
    "DONE":  {"type": "R", "opcode": "1111"},
}

def parse_instruction(instruction):
    parts = instruction.strip().replace(',', '').split()
    if len(parts) < 1:
        return None

    opcode = parts[0].upper()
    if opcode not in INSTRUCTION_SET:
        raise ValueError(f"Unknown instruction: {opcode}")

    info = INSTRUCTION_SET[opcode]
    instr_type = info["type"]

    if instr_type == "I":
        # LDI: 1 bit type (1), 8-bit immediate
        if len(parts) != 2 or not parts[1].isdigit():
            raise ValueError(f"Ldi expects a single immediate value")
        imm = int(parts[1])
        if not (0 <= imm < 256):
            raise ValueError("Immediate out of range for Ldi (0-255)")
        return f"1{imm:08b}"

    elif instr_type == "S":
        # SHL/ASR: 0 + 5 bits opcode + 3 bits immediate (immediate is 1-8, encoded as 0-7)
        if len(parts) != 2 or not parts[1].isdigit():
            raise ValueError(f"{opcode} expects a single immediate value")
        imm = int(parts[1])
        if not (1 <= imm <= 8):
            raise ValueError("Immediate out of range for shift (1-8)")
        imm_enc = imm - 1  # encode as 0-7
        return f"0{info['opcode']}{imm_enc:03b}"

    elif instr_type == "R":
        # R-type: 0 + 4 bits opcode + 4 bits register
        if len(parts) != 2 or not parts[1].upper().startswith('R'):
            raise ValueError(f"{opcode} expects a register operand (e.g., R1)")
        reg_str = parts[1][1:]
        if not reg_str.isdigit():
            raise ValueError(f"Invalid register: {parts[1]}")
        reg = int(reg_str)
        if not (0 <= reg < 16):
            raise ValueError("Register out of range (R0-R15)")
        return f"0{info['opcode']}{reg:04b}"

    else:
        raise ValueError(f"Unknown instruction type: {instr_type}")

def assemble(input_file, output_file):
    """
    Assemble the input assembly file into machine code.
    """
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        for line in infile:
            if line.strip() == "" or line.startswith("#"):  # Skip empty lines or comments
                continue
            try:
                machine_code = parse_instruction(line)
                if machine_code:
                    outfile.write(machine_code + "\n")
            except ValueError as e:
                print(f"Error: {e}")

if __name__ == "__main__":
    input_file = "instructions.txt"  # Input file containing assembly instructions
    output_file = "machine_code.txt"    # Output file for machine code
    assemble(input_file, output_file)