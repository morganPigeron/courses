package profiler

import "core:fmt"
import "core:time"

//use external rdtsc
when ODIN_OS == .Linux do foreign import rdtsc "librdtsc.a"
when ODIN_OS == .Windows do foreign import rdtsc "librdtsc.lib"

calibration_ms: u64 = 0

foreign rdtsc {
    GetTimestamp :: #force_inline proc() -> u64 ---  
}

start :: proc() {
    fmt.println("hello from package")
    fmt.printf("%v\n", GetTimestamp())
}

calibrate :: proc (calibration_time: time.Duration = time.Second) {
    stopwatch := time.Stopwatch{}
    before := GetTimestamp()
    time.stopwatch_start(&stopwatch)
    for time.stopwatch_duration(stopwatch) <= calibration_time {
    }
    after := GetTimestamp()
    diff_rdtsc := after - before
    duration_ms := time.duration_milliseconds(calibration_time)
    calibration_ms = u64(f64(diff_rdtsc) / f64(duration_ms))
    fmt.printf("%v = %v, %v = 1ms\n", diff_rdtsc, calibration_time, calibration_ms)
}

test_calibration :: proc () {
    stopwatch := time.Stopwatch{}
    time.stopwatch_start(&stopwatch)
    
    before := GetTimestamp()
    after := GetTimestamp()
    for (after - before) <= 1000 * calibration_ms  {
        after = GetTimestamp()
    }

    time.stopwatch_stop(&stopwatch)
    measure := time.stopwatch_duration(stopwatch)

    fmt.printf("should have taken 1s, it took %v \n", measure)

}
