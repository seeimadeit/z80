
CC = vasm\vasm.exe 
DEL = del
CCOUT = -Fbin
COPTS = $(CCOUT) -z80asm
INC   = -I.

progs = ROM RAM cmd hello run@5000 dir type edit keyboardtest asm hexdump setmat proc
librarys = screen keyboard
cleanlibs = screen.lib keyboard.lib


all: clean  $(progs) $(librarys)

clean:
	$(DEL) $(progs) $(cleanlibs)

#$(TARGET10):
#	$(CC) $(OPTS) $(INC) $(CCOUT) -L keyboardtestboot.txt -DBOOT -o $(TARGET10)boot keyboardtest.s
#	$(CC) $(OPTS) $(INC) $(CCOUT) -L keyboardtest.txt -o $(TARGET10) keyboardtest.s

$(progs):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L $@.txt -o $@ $*.s

$(librarys):
	@echo ======================================= library $@ =========================
	$(CC) $(OPTS) $(INC) $(CCOUT) -L $@.txt -o $@.lib $*.s
