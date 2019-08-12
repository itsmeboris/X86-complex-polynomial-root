CC = gcc
LD = gcc
NASM = nasm 

CFLAGS =  -c
NASMFLAGS = -f elf64

PROG = root

OBJS = main.o

default: $(PROG)

$(PROG): $(OBJS) 
	$(LD) $(OBJS) -o $(PROG)

main.o: main.s
	$(NASM) $(NASMFLAGS) main.s

clean:
	rm -rf *.o *~

real_clean:
	 rm -rf *.o $(PROG) *~
