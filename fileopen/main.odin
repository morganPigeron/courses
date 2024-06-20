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
    
    stopwatch := time.Stopwatch{}

    time.stopwatch_start(&stopwatch)
    content := languageMethod()
    time.stopwatch_stop(&stopwatch)
    
    print_result("Language method", content, stopwatch)
    
    time.stopwatch_reset(&stopwatch)
    time.stopwatch_start(&stopwatch)
    content2 := systemMethod()
    time.stopwatch_stop(&stopwatch)

    print_result("system method", content, stopwatch)

    time.stopwatch_reset(&stopwatch)
    time.stopwatch_start(&stopwatch)
    content3 := mmapMethod()
    time.stopwatch_stop(&stopwatch)

    print_result("mmap method", content, stopwatch)
    
    return
}

print_result :: proc (title: string, content: []byte, stopwatch: time.Stopwatch) {
    log.infof("%v", title)
    log.infof("size: %v", len(content))
    log.infof("time: %v us", time.duration_microseconds(time.stopwatch_duration(stopwatch))) 
    log.infof("first %v, last %v", content[0], content[len(content) - 1])
}

languageMethod :: proc () -> []byte {
    buffer, _:= os.read_entire_file_from_filename(FilePath)
    return buffer
}

systemMethod :: proc () -> []byte {
    fd, _ := os.open(FilePath)
    fileinfo, _ := os.fstat(fd)
    
    buffer := make([]byte, fileinfo.size)

    read, _ := os.read(fd, buffer)

    return buffer
}

mmapMethod :: proc () -> []byte {
    fd, _ := os.open(FilePath)
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

    return result
}
