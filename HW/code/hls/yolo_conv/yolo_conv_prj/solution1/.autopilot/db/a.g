#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    /home/kal-thir/Downloads/Tiny_YOLO_v3_ZYNQ/code/hls/yolo_conv/yolo_conv_prj/solution1/.autopilot/db/a.g.bc ${1+"$@"}
