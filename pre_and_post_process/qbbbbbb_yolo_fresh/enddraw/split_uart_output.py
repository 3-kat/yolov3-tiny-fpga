#!/usr/bin/env python3
"""
Split UART output from FPGA into format compatible with qbbbbbb's post-processing pipeline.

YOUR UART FORMAT:
=== BEGIN OUTPUT_13X13 ===
SIZE:43264
00A5 00A9 FFDD FFA0 0001 0001 0001 0002 0001 0001 0001 0008 0001 0001 0001 0001
0001 0001 0001 0001 0001 0001 0001 0001 0001 0001 0001 0001 0001 0001 0004 0001
...
=== END OUTPUT_13X13 ===

QBBBBBB EXPECTED FORMAT (10.txt / 13.txt):
163,
190,
-89,
-56,
1,
1,
...
(One decimal value per line, with trailing comma, NO newline character issues)

KEY POINTS:
- Your hex values are 16-bit SIGNED (FFDD = -35, not 65501)
- Each hex value becomes one line in output
- Values read left-to-right, row-by-row
- 13x13 layer: 43264 values total (13*13*256)
- 26x26 layer: 173056 values total (26*26*256)
"""

import sys
import re

def hex_to_signed16(hex_str):
    """Convert 4-character hex string to signed 16-bit decimal."""
    val = int(hex_str, 16)
    # If value >= 0x8000, it's negative in 2's complement
    if val >= 0x8000:
        val = val - 0x10000
    return val

def extract_section(content, begin_marker, end_marker):
    """Extract data between markers, skipping the SIZE line."""
    # Find the section
    pattern = re.escape(begin_marker) + r'\nSIZE:\d+\n(.*?)' + re.escape(end_marker)
    matches = list(re.finditer(pattern, content, re.DOTALL))
    
    if not matches:
        # Try without SIZE line in case format varies
        pattern = re.escape(begin_marker) + r'\n(.*?)' + re.escape(end_marker)
        matches = list(re.finditer(pattern, content, re.DOTALL))
    
    if not matches:
        return None
    
    # Return the LAST match (most recent run)
    return matches[-1].group(1)

def parse_hex_lines(data):
    """Parse hex data into list of signed decimal values."""
    values = []
    
    for line in data.strip().split('\n'):
        line = line.strip()
        if not line:
            continue
        # Skip any non-hex lines (like SIZE:xxxxx if it wasn't caught)
        if line.startswith('SIZE:'):
            continue
            
        # Split line by whitespace and parse each hex value
        hex_values = line.split()
        for hv in hex_values:
            # Only process 4-character hex strings
            if len(hv) == 4 and all(c in '0123456789ABCDEFabcdef' for c in hv):
                values.append(hex_to_signed16(hv))
    
    return values

def write_qbbbbbb_format(values, output_file):
    """Write values in qbbbbbb format: one decimal per line with comma."""
    with open(output_file, 'w') as f:
        for val in values:
            f.write(f"{val},\n")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 split_uart_output.py <uart_output.txt>")
        print("")
        print("Outputs:")
        print("  10.txt - 13x13 layer (43264 values)")
        print("  13.txt - 26x26 layer (173056 values)")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    print(f"Reading: {input_file}")
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Extract 13x13 layer (Group 10 output)
    data_13x13 = extract_section(content, "=== BEGIN OUTPUT_13X13 ===", "=== END OUTPUT_13X13 ===")
    if not data_13x13:
        print("ERROR: Could not find 13x13 layer data!")
        print("Looking for: === BEGIN OUTPUT_13X13 === ... === END OUTPUT_13X13 ===")
        sys.exit(1)
    
    # Extract 26x26 layer (Group 13 output)  
    data_26x26 = extract_section(content, "=== BEGIN OUTPUT_26X26 ===", "=== END OUTPUT_26X26 ===")
    if not data_26x26:
        print("ERROR: Could not find 26x26 layer data!")
        print("Looking for: === BEGIN OUTPUT_26X26 === ... === END OUTPUT_26X26 ===")
        sys.exit(1)
    
    # Parse hex values
    values_13x13 = parse_hex_lines(data_13x13)
    values_26x26 = parse_hex_lines(data_26x26)
    
    # Verify counts
    expected_13x13 = 13 * 13 * 256  # 43264
    expected_26x26 = 26 * 26 * 256  # 173056
    
    print(f"")
    print(f"13x13 layer: {len(values_13x13)} values (expected {expected_13x13})")
    print(f"26x26 layer: {len(values_26x26)} values (expected {expected_26x26})")
    
    if len(values_13x13) != expected_13x13:
        print(f"WARNING: 13x13 count mismatch!")
    if len(values_26x26) != expected_26x26:
        print(f"WARNING: 26x26 count mismatch!")
    
    # Write output files
    write_qbbbbbb_format(values_13x13, '10.txt')
    write_qbbbbbb_format(values_26x26, '13.txt')
    
    print(f"")
    print(f"Wrote: 10.txt ({len(values_13x13)} lines)")
    print(f"Wrote: 13.txt ({len(values_26x26)} lines)")
    
    # Show first few values for verification
    print(f"")
    print(f"First 10 values of 10.txt: {values_13x13[:10]}")
    print(f"First 10 values of 13.txt: {values_26x26[:10]}")

if __name__ == '__main__':
    main()
