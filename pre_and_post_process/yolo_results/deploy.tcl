# deploy.tcl - Build, Deploy, and Dump Memory
set ws_path "/home/kal-thir/workspace"
set output_dir "/home/kal-thir/yolo_results"

# --- BUILD ---
#puts "--- Building Project ---"
#setws $ws_path
#app build -name yolo_app

--- BUILD using make (not XSCT) ---
puts "--- Building Project with make ---"
cd "$ws_path/yolo_app/Debug"
if {[catch {exec make all 2>@1} result]} {
    puts "Build output: $result"
}
puts "Build complete"


# --- CONNECT AND DEPLOY ---
puts "--- Connecting to Hardware ---"
connect -url tcp:localhost:3121
targets -set -nocase -filter {name =~ "arm*#0"}
catch {stop}
rst -system

puts "--- Programming FPGA ---"
fpga "$ws_path/yolo_app/_ide/bitstream/design_1_wrapper.bit"
source "$ws_path/zedboard_platform/hw/ps7_init.tcl"
ps7_init
ps7_post_config

puts "--- Loading and Running ELF ---"
dow "$ws_path/yolo_app/Debug/yolo_app.elf"
con

# --- WAIT FOR COMPLETION ---
puts "--- Waiting for completion flag ---"
set timeout 120
set done 0
while {$timeout > 0 && !$done} {
    after 2000
    stop
    if {[catch {set flag [mrd -value 0x10200000]} err]} {
        puts "Memory read error: $err"
        con
        incr timeout -2
        continue
    }
    puts "Flag value: $flag (timeout: $timeout)"
    con
    if {$flag == 0xDEADBEEF || $flag == -559038737} {
        set done 1
        puts "✅ Inference complete!"
    }
    incr timeout -2
}

if {!$done} {
    puts "❌ Timeout waiting for completion"
}

# --- DUMP MEMORY TO FILES ---
puts "--- Dumping output tensors ---"
stop

# Dump 13x13 layer: 43264 shorts = 86528 bytes = 21632 words
mrd -bin -file "$output_dir/output_13x13.bin" 0x10000000 21632

# Dump 26x26 layer: 173056 shorts = 346112 bytes = 86528 words
mrd -bin -file "$output_dir/output_26x26.bin" 0x10100000 86528

puts "✅ Memory dump complete!"
exit
