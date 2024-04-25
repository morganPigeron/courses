package main

import "core:fmt"
import "core:time"
import "profiler"

main :: proc() {

	profiler.init()
	{
		profiler.mark_start("calibration")
		defer profiler.mark_stop()

		profiler.calibrate()

		profiler.test_calibration()

		profiler.calibrate(time.Millisecond * 100)
		profiler.calibrate(time.Millisecond * 10)
		profiler.calibrate(time.Millisecond * 1)
	}

	{
		temp := 0
		{
			profiler.mark_start("for loop")

			for temp < 100 {
				temp += 1
			}

			profiler.mark_stop()
		}
		fmt.printf("temp %v", temp)
	}

	profiler.report()
}
