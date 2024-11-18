package main

import libc "core:c/libc"
import "core:fmt"

fake_load :: proc(buffer: ^[]byte) -> u64 {
	result: u64 = 0
	for i := 0; i < len(buffer); i += 1 {
		if buffer[i] == 128 {
			result += 1
		}
	}
	return result
}

main :: proc() {
	file := libc.fopen("bigfile.txt", "rb")
	buffer := make([]byte, 4000 * 1000)

	libc.fseek(file, 0, .END)
	total_file_size := libc.ftell(file)
	libc.fseek(file, 0, .END)

	result: u64
	remaining := int(total_file_size)
	for remaining > 0 {
		read_size := len(buffer)
		if read_size > remaining {
			read_size = remaining
		}

		if libc.fread(&buffer, uint(read_size), 1, file) == 1 {
			result += fake_load(&buffer)
		}

		remaining -= read_size
	}

	free(&buffer)
	libc.fclose(file)

	fmt.printf("result: %v\n", result)

	return
}
