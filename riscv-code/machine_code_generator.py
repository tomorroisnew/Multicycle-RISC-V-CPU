def split_machine_code(machine_code_hex):
    # Ensure the machine code is 8 characters long (32 bits)
    if len(machine_code_hex) != 8:
        raise ValueError("Machine code must be 8 hex characters long (32 bits).")

    # Split the machine code into 4 bytes in little-endian order
    byte4 = machine_code_hex[0:2]
    byte3 = machine_code_hex[2:4]
    byte2 = machine_code_hex[4:6]
    byte1 = machine_code_hex[6:8]

    return byte1, byte2, byte3, byte4

def write_bytes_to_files(byte1, byte2, byte3, byte4):
    with open("firstbyte.txt", "a") as f1:
        f1.write(byte1 + "\n" + "00" + "\n" + "00" + "\n" + "00" + "\n")
    with open("secondbyte.txt", "a") as f2:
        f2.write(byte2 + "\n" + "00" + "\n" + "00" + "\n" + "00" + "\n")
    with open("thirdbyte.txt", "a") as f3:
        f3.write(byte3 + "\n" + "00" + "\n" + "00" + "\n" + "00" + "\n")
    with open("fourthbyte.txt", "a") as f4:
        f4.write(byte4 + "\n" + "00" + "\n" + "00" + "\n" + "00" + "\n")

def main():
    machine_code_hex = [
        "fffff537", # lui   x10, 0xFFFFF
        "ff056513", # ori   x10, x10, 0xFF0
        "00000593", # addi x11, x0, 0
        #"0ff00593", # addi x11, x0, 255
        "00b52023", # sw    x11, 0(x10)
        "00000013", # addi x0, x0, 0 NOP
        "00000013", # addi x0, x0, 0 NOP
        "00000013", # addi x0, x0, 0 NOP
        "00000013", # addi x0, x0, 0 NOP
        "fffff537", # lui   x10, 0xFFFFF
        "ff056513", # ori   x10, x10, 0xFF0
        "00000593", # addi x11, x0, 0
        #"0ff00593", # addi x11, x0, 255
        "00b52023", # sw    x11, 0(x10)
        "00000013", # addi x0, x0, 0 NOP
        "00000013", # addi x0, x0, 0 NOP
        "00000013", # addi x0, x0, 0 NOP
        "00000013", # addi x0, x0, 0 NOP
        "fc1ff06f", # jal x0, -64
    ]
    for code in machine_code_hex:
        byte1, byte2, byte3, byte4 = split_machine_code(code)
        write_bytes_to_files(byte1, byte2, byte3, byte4)
        print("Machine code has been split and written to files.")

if __name__ == "__main__":
    main()