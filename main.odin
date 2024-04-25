package main

import "core:time"
import "profiler"

main :: proc () {
    
    profiler.init()
    profiler.mark_start("test")
    defer profiler.report()
    defer profiler.mark_stop() 

    profiler.calibrate()
    
    profiler.test_calibration()

    profiler.calibrate(time.Millisecond * 100)
    profiler.calibrate(time.Millisecond * 10)
    profiler.calibrate(time.Millisecond * 1)

}
