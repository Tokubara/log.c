LIB = log_c
LIB_NAME = lib$(LIB).a
all: $(LIB_NAME) mv
.PHONY: mv

# CC=gcc

CFLAGS ?= -O2  

OBJECTS=$(subst src,build,$(subst .c,.o,$(wildcard src/*.c)))

$(OBJECTS): build/%.o : src/%.c src/%.h
	$(CC) $(CFLAGS) $< -c -DLOG_USE_COLOR -o $@

liblog_c.a: $(OBJECTS)
	ar rcs $@ $^

mv:
	cp $(LIB_NAME) ../ubuntu/lib/
	cp src/*.h ../ubuntu/header/

INCLUDES = -I src/
LDFLAGS += -L . -l $(LIB)

test: test.c $(LIB_NAME)
	$(CC) $(CFLAGS) $(INCLUDES) $< -o $@ $(LDFLAGS)

