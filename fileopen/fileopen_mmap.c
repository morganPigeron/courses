#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>

typedef unsigned char u8;
typedef unsigned long u64;
typedef size_t u32;

u64 fakeLoad(u8 *buffer, u32 size)
{
  u64 result = 0;
  for (u32 i=0; i<size; ++i)
    {
      if (buffer[i] == 128)
	{
	  ++result;
	}
    }
  return result;
}

int main ()
{
  struct timespec start = {};
  struct timespec stop = {};
  clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &start);
  
  int fd = open("bigfile.txt", O_RDONLY);
  
  struct stat file_stat = {};
  fstat(fd, &file_stat);
  u32 total_file_size = (u32)file_stat.st_size;
  
  u8 *buffer = mmap(
		    NULL,
		    (u32)total_file_size,
		    PROT_READ,
		    MAP_PRIVATE,
		    fd,
		    0
		    );
  
  u64 result = fakeLoad(buffer, total_file_size);

  clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &stop);  
  
  printf("result: %ld, ticks: %ld\n", result, stop.tv_nsec - start.tv_nsec);
  
  
  return 0;
}
