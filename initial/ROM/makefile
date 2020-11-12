
CC = vasm\vasm.exe -L outout.txt
DEL = del
CCOUT = -Fbin
COPTS = $(CCOUT)
INC   = -I.
TARGET = testprog


all: clean $(TARGET)

clean:
	$(DEL) $(TARGET)


$(TARGET):
	$(CC) $(OPTS) $(INC) $(CCOUT) testz80.s -o $(TARGET)