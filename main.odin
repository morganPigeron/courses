package main

import "core:time"
import "profiler"

main :: proc () {
    profiler.calibrate()
    
    profiler.test_calibration()

    profiler.calibrate(time.Millisecond * 100)
    profiler.calibrate(time.Millisecond * 10)
    profiler.calibrate(time.Millisecond * 1)
}
