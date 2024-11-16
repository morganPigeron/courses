package main
import "core:log"
import "core:os"
import "core:fmt"
import "core:time"
import "core:mem"
import "core:strings"
import linux "core:sys/linux"

FilePath := "bigfile.txt"
FilePathC :cstring = "bigfile.txt"

main :: proc () {

    context.logger = log.create_console_logger()

    if (len(os.args) == 2) 
    {
        FilePath = os.args[1]
        FilePathC, _ = strings.clone_to_cstring(FilePath)
        log.infof("Reading file: %v", FilePath)
    }

    if !os.exists(FilePath) {
	log.errorf("File not found: %v", FilePath)
	return
    }

    fd, _       := os.open(FilePath)
    fileinfo, _ := os.fstat(fd)
    file_size := fileinfo.size
    os.close(fd)    

    stopwatch := time.Stopwatch{}

    time.stopwatch_start(&stopwatch)
    content := languageMethod()
    time.stopwatch_stop(&stopwatch)
    print_result("Language method", content, stopwatch, file_size)
    
    time.stopwatch_reset(&stopwatch)
    time.stopwatch_start(&stopwatch)
    content2 := systemMethod()
    time.stopwatch_stop(&stopwatch)
    print_result("system method", content2, stopwatch, file_size)

    time.stopwatch_reset(&stopwatch)
    time.stopwatch_start(&stopwatch)
    content3 := mmapMethod()
    time.stopwatch_stop(&stopwatch)
    print_result("mmap method", content3, stopwatch, file_size)


    for i := 1; i <= 10; i += 1 {
	time.stopwatch_reset(&stopwatch)
	time.stopwatch_start(&stopwatch)
	content4 := cacheBufferMethod(i * 100 * mem.Kilobyte)
	time.stopwatch_stop(&stopwatch)
	print_result(
	    fmt.aprintf("Cache buffer method %v", i),
	    content4,
	    stopwatch,
	    file_size,
	)	
    }
    
    return
}

print_result :: proc (
    title: string,
    result: int,
    stopwatch: time.Stopwatch,
    file_size: i64,
) {

    duration := time.stopwatch_duration(stopwatch)

    microseconds := time.duration_microseconds(duration)
    giga :f64 = f64(file_size) / f64(mem.Gigabyte)
    
    log.info("=====================")
    log.infof("%v", title)
    log.infof("result: %v", result)
    log.infof("time: %v us", microseconds)
    log.infof("throughput %.2f Gb/s", giga/(microseconds / 1_000_000.0))
}

languageMethod :: proc () -> int {
    buffer, _:= os.read_entire_file_from_filename(FilePath)
    return fakeLoad(buffer)
}

systemMethod :: proc () -> int {
    fd, _ := os.open(FilePath)
    defer os.close(fd)
    fileinfo, _ := os.fstat(fd)
    
    buffer := make([]byte, fileinfo.size)

    read, _ := os.read(fd, buffer)

    return fakeLoad(buffer)
}

mmapMethod :: proc () -> int {
    fd, _ := os.open(FilePath)
    defer os.close(fd)
    fileinfo, _ := os.fstat(fd)

    buffer, _ := linux.mmap(
            0, 
            uint(fileinfo.size), 
            linux.Mem_Protection{linux.Mem_Protection_Bits.READ}, 
            linux.Map_Flags{linux.Map_Flags_Bits.PRIVATE},
            linux.Fd(fd),
            0,
        )
    
    result := mem.byte_slice(buffer, fileinfo.size)
    
    return fakeLoad(result)
}

cacheBufferMethod :: proc (buffer_size: int) -> int {
    fd, _       := os.open(FilePath)
    defer os.close(fd)
    fileinfo, _ := os.fstat(fd)
    buffer      := make([]byte, buffer_size)

    total_read  := 0
    result      := 0
    
    for total_read < int(fileinfo.size) {
	read, _ := os.read(fd, buffer)
	total_read += read
	result += fakeLoad(buffer[:read])
    }
    
    return result
}

fakeLoad :: proc (buffer: []byte) -> int {
    result := 0
    for b in buffer {
	if b == 123 {
	    result += 1
	}
    }
    return result
}
