#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

int main() {
    // ESC/POS commands to initialize printer, print "Hello", and feed paper
    unsigned char data[] = {
        0x1B, 0x40,          // Initialize printer
        'H', 'e', 'l', 'l', 'o', // Print "Hello"
        0x0A                // Print and feed paper
    };

    // Open the device file
    int fd = open("/dev/usb/lp0", O_WRONLY);
    if (fd < 0) {
        perror("Failed to open /dev/usb/lp0");
        return 1;
    }

    // Write data to the printer
    ssize_t bytes_written = write(fd, data, sizeof(data));
    if (bytes_written != sizeof(data)) {
        perror("Failed to write to /dev/usb/lp0");
        close(fd);
        return 1;
    }

    printf("Data sent successfully\n");

    // Close the device file
    close(fd);

    return 0;
}
