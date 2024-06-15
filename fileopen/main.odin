package main
import "core:log"
import "core:os"
import "core:fmt"
import "core:time"

FILEPATH :: "bigfile.txt"
FILEPATHC:: "bigfile.txt"

main :: proc () {
    
    context.logger = log.create_console_logger()

    stopwatch := time.Stopwatch{}

    log.info("language method")

    time.stopwatch_start(&stopwatch)
    content := languageMethod()
    time.stopwatch_stop(&stopwatch)
    
    log.info("language method")
    log.infof("size: %v", len(content))
    log.infof("time: %v ns", time.duration_nanoseconds(time.stopwatch_duration(stopwatch))) 

    time.stopwatch_reset(&stopwatch)
    time.stopwatch_start(&stopwatch)
    content2 := languageMethod()
    time.stopwatch_stop(&stopwatch)

    log.info("os method")
    log.infof("size: %v", len(content2))
    log.infof("time: %v ns", time.duration_nanoseconds(time.stopwatch_duration(stopwatch))) 

    return
}

languageMethod :: proc () -> []byte {
    buffer, _:= os.read_entire_file_from_filename(FILEPATH)
    return buffer
}

systemMethod :: proc () -> []byte {
    fd, _ := os.open(FILEPATHC)
    fileinfo, _ := os.fstat(fd)
    
    buffer := make([]byte, fileinfo.size)

    read, _ := os.read(fd, buffer)

    return buffer
}

mmapMethod :: proc () -> []byte {
    return []byte{}
}
