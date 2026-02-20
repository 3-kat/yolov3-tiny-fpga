#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    /home/kal-thir/Downloads/Tiny_YOLO_v3_ZYNQ/code/hls/yolo_upsamp/yolo_upsamp_prj/solution1/.autopilot/db/a.g.bc ${1+"$@"}
