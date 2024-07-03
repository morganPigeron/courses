package profiler

import "core:fmt"
import "core:log"
import "core:strings"
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
	//fmt.printf("%v = %v, %v = 1ms\n", diff_rdtsc, calibration_time, calibration_ms)
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

to_ms :: #force_inline proc(raw: u64) -> f64 {
	return f64(raw) / f64(calibration_ms)
}

to_us :: #force_inline proc(raw: u64) -> f64 {
	return f64(raw) / f64(calibration_ms) * 1000
}

to_ns :: #force_inline proc(raw: u64) -> f64 {
	return f64(raw) / f64(calibration_ms) * 1_000_000
}

Phase :: enum {
	Begin,
	End,
}
Marker :: struct {
	time:  u64,
	label: string,
	phase: Phase,
}

MarkerPair :: distinct [2]Marker

Markers :: struct {
	data:          [1000]Marker,
	ordered_pairs: [1000]Marker,
	size:          u32,
}

init :: proc() -> Markers {
    return Markers{}
}

mark_start :: #force_inline proc(label: string, markers: ^Markers) {
	t := GetTimestamp()
	m := Marker {
		time  = t,
		label = label,
		phase = Phase.Begin,
	}
    mark_increment(m, markers)
	mark_check_overflow(markers) 
}

mark_stop :: #force_inline proc(label: string, markers: ^Markers) {
	t := GetTimestamp()
	m := Marker {
		time  = t,
		label = label,
		phase = Phase.End,
	}
    mark_increment(m, markers)
	mark_check_overflow(markers) 
}

mark_increment :: #force_inline proc(m: Marker, markers: ^Markers) {
	markers.data[markers.size] = m
	markers.size += 1
}

mark_check_overflow :: #force_inline proc(markers: ^Markers) {
    // Override old data to avoid overflow
    if markers.size >= len(markers.data) {
        markers.size = 0
    }
}

/*
[ {"name": "Asub", "cat": "PERF", "ph": "B", "pid": 22630, "tid": 22630, "ts": 829},
  {"name": "Asub", "cat": "PERF", "ph": "E", "pid": 22630, "tid": 22630, "ts": 833} ]
*/
report_json_profiler :: proc(markers: Markers) -> string {
	sb := strings.builder_make()
	strings.write_string(&sb, "{")
	strings.write_string(&sb, "\"traceEvents\":")
	strings.write_string(&sb, "[")

	for i in 0 ..< markers.size {
		marker := markers.data[i]
		if i > 0 {
			strings.write_string(&sb, ",")
		}
		strings.write_string(&sb, "{")
		fmt.sbprintf(
			&sb,
			"\"name\": \"%v\", \"cat\": \"profiler\", \"ph\": \"%v\", \"pid\": 0, \"tid\": 0, \"ts\": %v",
			marker.label,
			marker.phase == Phase.Begin ? "B" : "E",
			to_us(marker.time),
		)
		strings.write_string(&sb, "}")
	}

	strings.write_string(&sb, "]")
	strings.write_string(&sb, ", \"displayTimeUnit\": \"ms\"")
	strings.write_string(&sb, "}")
	return strings.to_string(sb)
}

report :: proc(markers: Markers) {
	fmt.println("")
	fmt.print("/==================\n")
	fmt.printf("| markers count: %v\n", markers.size)
	fmt.print("|------------------\n")
	for i := 0; i < int(markers.size); i += 2 {
		delta := markers.data[i + 1].time - markers.data[i].time
		delta_ms := to_ms(delta)
		delta_us := to_us(delta)
		delta_ns := to_ns(delta)

		final: f64
		unit: string
		if delta_ms >= 1 {
			final = delta_ms
			unit = "ms"
		} else if delta_us >= 1 {
			final = delta_us
			unit = "us"
		} else {
			final = delta_ns
			unit = "ns"
		}

		fmt.printf("| %v: %f %v\n", markers.data[i].label, final, unit)
	}
	fmt.print("\\==================\n")
	fmt.println("")
}

@(test)
test_export_to_chrome_tracer :: proc(t: ^testing.T) {
	markers := init()
	mark_start("test", &markers)
	mark_start("test1", &markers)
	mark_stop("test1", &markers)
	mark_stop("test", &markers)
	calibrate()
	result := report_json_profiler(markers)
	fmt.println(result)
}

@(test)
test_that_marker_can_be_init :: proc(t: ^testing.T) {
	markers := init()
	mark_start("test", &markers)
	mark_stop("test", &markers)
	expected := markers.data[0]
	result := markers.data[1]

	testing.expect_value(t, expected.label, result.label)
	testing.expect(t, expected.time < result.time)
	testing.expect_value(t, markers.size, 2)
}

@(test)
test_that_it_doesnt_overflow :: proc(t: ^testing.T) {
    markers := init()
    for i in 0..<1_000_000 {
        mark_start("test", &markers)
        mark_start("testend", &markers)
    }
    testing.expect_value(t, markers.size , 0)
}
