package main

import "core:os"
import "core:log"
import "core:mem"

INIT_PRINTER :: []byte{0x1B, 0x40} // Initialize printer
PRINT_AND_FEED :: 0x0A

main :: proc () {
    
    context.logger = log.create_console_logger()

    log.info("start")

    file_handle, errno := os.open("/dev/usb/lp0", os.O_WRONLY) 
    if errno != os.ERROR_NONE {
        log.errorf("failed to open printer with code: %v", errno)
    }

    send_buffer := make([dynamic]byte, 0, mem.Megabyte * 4)
    defer(delete(send_buffer)) 

    append(&send_buffer, ..INIT_PRINTER)
    append(&send_buffer, "Hello")
    append(&send_buffer, PRINT_AND_FEED)

    written, err_write := os.write(file_handle, send_buffer[:])
    if err_write != os.ERROR_NONE {
        log.errorf("failed to write to printer with code: %v", err_write)
    } else {
        log.infof("written %v bytes", written)
    }

    os.close(file_handle)
}
