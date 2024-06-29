package main

import "core:os"
import "core:log"
import "core:mem"

INIT_PRINTER :: []byte{0x1B, 0x40}
PRINT_AND_FEED_N_LINE :: []byte{0x1B, 0x64, 0x02}

print :: proc (text: string) -> bool {
    context.logger = log.create_console_logger()

    log.info("start printing")

    file_handle, errno := os.open("/dev/usb/lp0", os.O_WRONLY) 
    defer(os.close(file_handle))
    
    if errno != os.ERROR_NONE {
        log.errorf("failed to open printer with code: %v", errno)
        return false
    }

    send_buffer := make([dynamic]byte, 0, len(text) + 100)
    defer(delete(send_buffer)) 

    append(&send_buffer, ..INIT_PRINTER)
    append(&send_buffer, text)
    append(&send_buffer, ..PRINT_AND_FEED_N_LINE)

    written, err_write := os.write(file_handle, send_buffer[:])
    if err_write != os.ERROR_NONE {
        log.errorf("failed to write to printer with code: %v", err_write)
        return false
    } else {
        log.infof("written %v bytes", written)
        return true
    }
}
