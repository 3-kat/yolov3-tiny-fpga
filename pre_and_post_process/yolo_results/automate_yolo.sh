#!/bin/bash

# --- Paths Configuration ---
BASE_DIR="/home/kal-thir/qbbbbbb_yolo_fresh"
PYGEN_DIR="$BASE_DIR/pygen0"
ENDDRAW_DIR="$BASE_DIR/enddraw"
DRAW_C_DIR="$BASE_DIR/draw_box_c"
UART_FILE="$HOME/yolo_results/uart_output.txt"
VITIS_WORKSPACE="$HOME/workspace"
VITIS_SRC="$VITIS_WORKSPACE/yolo_app/src"
XILINX_SETTINGS="$HOME/tools/Xilinx/Vitis/2019.2/settings64.sh"
UART_DEV="/dev/ttyACM0"
YOLO_RESULTS="$HOME/yolo_results"
echo "🚀 Starting Full YOLO Automation Pipeline..."

# --- STAGE 0: ENVIRONMENT PREP ---
# 1. Source Xilinx Environment
if [ -f "$XILINX_SETTINGS" ]; then
    source "$XILINX_SETTINGS"
else
    echo "❌ Error: settings64.sh not found at $XILINX_SETTINGS"
    exit 1
fi

# 2. Start hw_server if not running
if ! pgrep -x "hw_server" > /dev/null; then
    echo "🌐 Starting Hardware Server..."
    hw_server & 
    sleep 3
fi

# 3. Clear Vitis Workspace Lock
rm -f "$VITIS_WORKSPACE/.metadata/.lock"

# 4. Clear old UART output for a fresh run
> "$UART_FILE"

# --- ADDITION 1: IMAGE SELECTION ---
echo "🖼️  Step 1: Selecting Image..."
# Running the selector script located in your results folder
python3 "$YOLO_RESULTS/selector.py"

# --- STAGE 1: PYGEN CLEANUP & GENERATION ---
echo "📂 Cleaning and Generating PyGen headers..."
cd "$PYGEN_DIR"
rm -f input_image_short.h group_0_input.h input_img.h input_img_sort.h testrunall0 testrunall1 testrunall2 testrunall3
python3 runall.py


echo "📦 Updating Vitis Source..."
cp group_0_input.h "$VITIS_SRC/"


# --- ADDITION 2: UART CAPTURE LOOP ---
#echo "⏳ Waiting for YOLO Inference and UART output..."
# Configure the serial port baud rate
#stty -F "$UART_DEV" 115200 raw -echo

# This loop reads the serial port line by line. 
# It saves everything to your UART_FILE.
# It breaks when it sees the final "End" message from your main.c.
#while IFS= read -r line; do
#    echo "$line" >> "$UART_FILE"
#    echo "  [Zynq]: $line"
    
    # We look for the "End" string printed at the bottom of your main()
#    if [[ "$line" == *"Calculation complete"* ]]; then
#        echo "✅ UART Capture Complete."
#        break
#    fi
#done < "$UART_DEV"



# Now trigger the hardware
echo "🛠️  Building and running..."
xsct "$YOLO_RESULTS/deploy.tcl" 




# --- STAGE 4: ENDDRAW PROCESSING ---
echo "✂️ Processing UART output in Enddraw..."
cd "$ENDDRAW_DIR"
python3 << 'EOF'
import numpy as np

# Convert 13x13 binary to 10.txt format
data_13 = np.fromfile('/home/kal-thir/yolo_results/output_13x13.bin', dtype=np.int16)
with open('10.txt', 'w') as f:
    for val in data_13[:43264]:
        f.write(f"{val},\n")
print(f"10.txt: {len(data_13[:43264])} values")

# Convert 26x26 binary to 13.txt format  
data_26 = np.fromfile('/home/kal-thir/yolo_results/output_26x26.bin', dtype=np.int16)
with open('13.txt', 'w') as f:
    for val in data_26[:173056]:
        f.write(f"{val},\n")
print(f"13.txt: {len(data_26[:173056])} values")
EOF




rm -f yolo0.h yolo0_o.h yolo1.h yolo1_o.h yolo0_cal.dat yolo1_cal.dat input_image_short.h 
cp "$PYGEN_DIR/input_image_short.h" ./
# Note: Using script_uart_output.py as per our earlier discussion
# python3 split_uart_output.py "$UART_FILE"
python3 enddraw.py

# --- STAGE 5: DRAW_BOX_C PREP ---
echo "🎨 Moving data to C++ Visualizer..."
cd "$DRAW_C_DIR"
rm -f input_image_short.h yolo0_cal.dat yolo1_cal.dat yolo0.h yolo1.h yolo0_o.h yolo1_o.h draw_box
cp "$ENDDRAW_DIR/yolo0_cal.dat" "$ENDDRAW_DIR/yolo1_cal.dat" ./
cp "$ENDDRAW_DIR/input_image_short.h" ./
cp "$ENDDRAW_DIR/yolo0.h" "$ENDDRAW_DIR/yolo1.h" "$ENDDRAW_DIR/yolo0_o.h" "$ENDDRAW_DIR/yolo1_o.h" ./

echo "📝 Patching SizedData_fp to SizedData..."
sed -i 's/SizedData_fp/SizedData/g' input_image_short.h

# --- STAGE 6: FINAL COMPILE & RUN ---
echo "⚙️ Compiling and Executing..."
g++ -o draw_box image.cpp main.cpp -lm

if [ $? -eq 0 ]; then
    ./draw_box
    echo "✅ Pipeline Complete! Check predictions.jpg"
    xdg-open predictions.jpg
else
    echo "❌ Compilation failed."
fi
