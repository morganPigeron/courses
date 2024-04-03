package profiler

import "core:fmt"

//use external rdtsc
when ODIN_OS == .Linux do foreign import rdtsc "librdtsc.a"
when ODIN_OS == .Windows do foreign import rdtsc "librdtsc.lib"

foreign rdtsc {
    GetTimestamp :: proc() -> u64 ---  
}

start :: proc() {
    fmt.println("hello from package")
    fmt.printf("%v\n", GetTimestamp())
}

