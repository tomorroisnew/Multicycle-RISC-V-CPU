import serial
import time

def read_uart_bits(device, baud_rate, timeout=1):
    # Open the serial port
    ser = serial.Serial(device, baudrate=baud_rate, timeout=timeout)
    
    try:
        print(f"Listening on {device} at {baud_rate} baud...")
        
        while True:
            # Read one byte (8 bits)
            byte_data = ser.read(1)
            
            if byte_data:
                # Convert byte to its binary representation and pad to 8 bits
                binary_representation = format(ord(byte_data), '08b')
                
                # Print each bit
                print(f"Received byte: {byte_data.hex()} -> Bits: {binary_representation}")
                
                # You can further process the bits if needed here
                
            else:
                print("No data received")
            time.sleep(0.1)  # Small delay to not overload the loop
    except KeyboardInterrupt:
        print("Exiting...")
    finally:
        ser.close()

if __name__ == "__main__":
    # Specify your device and baud rate
    uart_device = '/dev/ttyUSB1'  # Adjust this path if needed
    baud_rate = 1200  # Ensure this matches the baud rate of your FPGA UART
    
    read_uart_bits(uart_device, baud_rate)
