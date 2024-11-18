#include <stdlib.h>
#include <stdio.h>
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
    
  FILE *file = fopen("bigfile.txt", "rb");
  u32 buffer_size = 4000 * 1000;
  u8 *buffer = malloc(buffer_size);

  fseek(file, 0, SEEK_END);
  u64 total_file_size = ftell(file);
  fseek(file, 0, SEEK_SET);

  u64 result = 0;
   
  u64 remaining = total_file_size;
  while (remaining)
    {
      u64 read_size = buffer_size;
      if(read_size > remaining)
	{
	  read_size = remaining;
	}

      if(fread(buffer, read_size, 1, file) == 1)
	{
	  result += fakeLoad(buffer, read_size);
	}

      remaining -= read_size;
    }

  free(buffer);
  fclose(file);

  clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &stop);  
  
  printf("result: %ld, ticks: %ld\n", result, stop.tv_nsec - start.tv_nsec);
  
  return 0;
}
