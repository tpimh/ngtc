CC ?= clang
RM ?= rm -vf

ARCH ?= x86_64

S := $(ARCH)/crtbegin.S $(ARCH)/crtend.S
O := $(S:.S=.o)

CFLAGS += -c -I$(ARCH)/include
DESTDIR ?= /lib

all: $(O)

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

install: $(O)
	install $^ $(DESTDIR) 

clean:
	$(RM) $(O)
