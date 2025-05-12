# Compiler and assembler
CC=gcc
AS=as

# Compile options
CFLAGS=-g -no-pie
ASFLAGS=-g

# Target executable name
TARGET=test

all: $(TARGET)

$(TARGET): minimal.o minimal_test.o
	$(CC) $(CFLAGS) -o $(TARGET) minimal.o minimal_test.o

minimal.o: minimal.s
	$(AS) $(ASFLAGS) -o minimal.o minimal.s

minimal_test.o: minimal_test.c
	$(CC) $(CFLAGS) -c -o minimal_test.o minimal_test.c

clean:
	rm -f $(TARGET) *.o
