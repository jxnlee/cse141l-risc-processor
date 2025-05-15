# assembler.py

# Define the instruction set and their corresponding binary codes
INSTRUCTION_SET = {
    "ADD": "0001",
    "SUB": "0010",
    "AND": "0011",
    "OR": "0100",
    "XOR": "0101",
    "LOAD": "0110",
    "STORE": "0111",
    "JUMP": "1000",
    # Add more instructions as needed
}

def parse_instruction(instruction):
    """
    Parse a single assembly instruction into machine code.
    """
    parts = instruction.strip().split()
    if len(parts) < 1:
        return None

    opcode = parts[0].upper()
    if opcode not in INSTRUCTION_SET:
        raise ValueError(f"Unknown instruction: {opcode}")

    binary_code = INSTRUCTION_SET[opcode]

    # Handle operands (e.g., registers, immediate values)
    operands = parts[1:] if len(parts) > 1 else []
    for operand in operands:
        # Convert operands to binary (e.g., register numbers or immediate values)
        # This is a placeholder; customize based on your architecture
        if operand.isdigit():
            binary_code += format(int(operand), '04b')  # Example: 4-bit binary
        else:
            raise ValueError(f"Invalid operand: {operand}")

    return binary_code

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
    output_file = "mach_code.txt"    # Output file for machine code
    assemble(input_file, output_file)