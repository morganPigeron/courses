package profiler

import "core:fmt"
import "core:testing"
import "core:time"

//use external rdtsc
when ODIN_OS == .Linux do foreign import rdtsc "librdtsc.a"
when ODIN_OS == .Windows do foreign import rdtsc "librdtsc.lib"

calibration_ms: u64 = 0

foreign rdtsc {
	GetTimestamp :: #force_inline proc() -> u64 ---
}

calibrate :: proc(calibration_time: time.Duration = time.Second) {
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

test_calibration :: proc() {
	stopwatch := time.Stopwatch{}
	time.stopwatch_start(&stopwatch)

	before := GetTimestamp()
	after := GetTimestamp()
	for (after - before) <= 1000 * calibration_ms {
		time.sleep(time.Millisecond * 100)
		after = GetTimestamp()
	}

	time.stopwatch_stop(&stopwatch)
	measure := time.stopwatch_duration(stopwatch)

	fmt.printf("should have taken 1s, it took %v \n", measure)
}

to_ms :: #force_inline proc(raw: u64) -> u64 {
	return raw / calibration_ms
}

Marker :: struct {
	time:  u64,
	label: string,
}

Markers :: struct {
	data: [1000]Marker,
	size: u32,
}

markers := Markers{}

init :: proc() {
	markers.size = 0
}

mark_start :: #force_inline proc(label: string) {
	t := GetTimestamp()
	m := Marker {
		time  = t,
		label = label,
	}
	markers.data[markers.size] = m
	markers.size += 1
	//check overflow or add dynamic array 
}

mark_stop :: #force_inline proc() {
	t := GetTimestamp()
	m := Marker {
		time  = t,
		label = markers.data[markers.size - 1].label, // check is len > 0
	}
	markers.data[markers.size] = m
	markers.size += 1
	//check overflow or add dynamic array 
}

report :: proc() {
	fmt.println("")
	fmt.print("/==================\n")
	fmt.printf("| markers count: %v\n", markers.size)
	fmt.print("|------------------\n")
	for i := 0; i < int(markers.size); i += 2 {
		fmt.printf(
			"| %v: %v ms\n",
			markers.data[i].label,
			to_ms(markers.data[i + 1].time - markers.data[i].time),
		)
	}
	fmt.print("\\==================\n")
	fmt.println("")
}

@(test)
test_that_marker_can_be_init :: proc(t: ^testing.T) {
	init()
	mark_start("test")
	mark_stop()
	expected := markers.data[0]
	result := markers.data[1]

	testing.expect_value(t, expected.label, result.label)
	testing.expect(t, expected.time < result.time)
	testing.expect_value(t, markers.size, 2)
}
