MUSA_ROOT ?= /usr/local/musa
CC ?= cc
CFLAGS := -std=c11 -O2 -Wall -Wextra -Werror -I$(MUSA_ROOT)/include

.PHONY: all test

all: native_launcher test_native_launcher

native_launcher: native_launcher.c native_launcher.h
	$(CC) $(CFLAGS) native_launcher.c -L/usr/lib/x86_64-linux-gnu \
		-Wl,-rpath,/usr/lib/x86_64-linux-gnu -Wl,--no-as-needed -lmusa -o $@

test_native_launcher: test_native_launcher.c native_launcher.c native_launcher.h
	$(CC) $(CFLAGS) test_native_launcher.c -o $@

test: all
	./test_native_launcher
	./test_telemetry.sh
	./sample_device_continuously.sh 2>/dev/null; test $$? -eq 64
	./native_launcher --print-contract
