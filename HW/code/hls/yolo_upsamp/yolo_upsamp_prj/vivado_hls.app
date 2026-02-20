<AutoPilot:project xmlns:AutoPilot="com.autoesl.autopilot.project" projectType="C/C++" name="yolo_upsamp_prj" top="yolo_upsamp_top">
    <includePaths/>
    <libraryFlag/>
    <files>
        <file name="../../tb/yolo_upsamp_tb.cpp" sc="0" tb="1" cflags=" -Wno-unknown-pragmas" csimflags=" -Wno-unknown-pragmas" blackbox="false"/>
        <file name="../../tb/layer_output_sdk.dat" sc="0" tb="1" cflags=" -Wno-unknown-pragmas" csimflags=" -Wno-unknown-pragmas" blackbox="false"/>
        <file name="../../tb/layer_input.dat" sc="0" tb="1" cflags=" -Wno-unknown-pragmas" csimflags=" -Wno-unknown-pragmas" blackbox="false"/>
        <file name="src/yolo_stream.h" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
        <file name="src/yolo_upsamp.h" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
        <file name="src/yolo_upsamp.cpp" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
        <file name="src/yolo_fp.h" sc="0" tb="false" cflags="" csimflags="" blackbox="false"/>
    </files>
    <solutions>
        <solution name="solution1" status=""/>
    </solutions>
    <Simulation argv="">
        <SimFlow name="csim" setup="false" optimizeCompile="false" clean="false" ldflags="" mflags=""/>
    </Simulation>
</AutoPilot:project>

