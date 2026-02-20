#!/usr/bin/env python3
"""
Convert XSCT memory dump (.bin) to qbbbbbb format (10.txt, 13.txt)

XSCT mrd dumps 32-bit words in little-endian format.
Each 32-bit word contains two 16-bit signed shorts.
"""
import numpy as np
import sys
import os

def convert_bin_to_txt(bin_file, txt_file, expected_count):
    """Convert binary dump to decimal text format."""
    
    # Read as raw bytes
    with open(bin_file, 'rb') as f:
        raw_data = f.read()
    
    print(f"Read {len(raw_data)} bytes from {bin_file}")
    
    # Method 1: Direct int16 interpretation (little-endian)
    data = np.frombuffer(raw_data, dtype='<i2')  # Little-endian int16
    
    print(f"Converted to {len(data)} int16 values")
    print(f"First 10 values: {data[:10]}")
    print(f"Value range: [{data.min()}, {data.max()}]")
    
    # Take only what we need
    if len(data) >= expected_count:
        data = data[:expected_count]
    else:
        print(f"WARNING: Only got {len(data)} values, expected {expected_count}")
    
    # Write in qbbbbbb format: "value,\n"
    with open(txt_file, 'w') as f:
        for val in data:
            f.write(f"{val},\n")
    
    print(f"Wrote {len(data)} values to {txt_file}")
    return len(data)

def main():
    output_dir = "/home/kal-thir/yolo_results"
    enddraw_dir = "/home/kal-thir/qbbbbbb_yolo_fresh/enddraw"
    
    # Convert 13x13 layer (group_10 output)
    print("=" * 60)
    print("Converting 13x13 layer (OUTPUT_13X13)")
    print("=" * 60)
    bin_13x13 = os.path.join(output_dir, "output_13x13.bin")
    txt_10 = os.path.join(enddraw_dir, "10.txt")
    count_10 = convert_bin_to_txt(bin_13x13, txt_10, 43264)
    
    print()
    
    # Convert 26x26 layer (group_13 output)
    print("=" * 60)
    print("Converting 26x26 layer (OUTPUT_26X26)")
    print("=" * 60)
    bin_26x26 = os.path.join(output_dir, "output_26x26.bin")
    txt_13 = os.path.join(enddraw_dir, "13.txt")
    count_13 = convert_bin_to_txt(bin_26x26, txt_13, 173056)
    
    print()
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"10.txt: {count_10} values (expected 43264)")
    print(f"13.txt: {count_13} values (expected 173056)")
    
    if count_10 == 43264 and count_13 == 173056:
        print("✅ Conversion successful!")
    else:
        print("⚠️  Value counts don't match expected!")

if __name__ == "__main__":
    main()
