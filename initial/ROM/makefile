
CC = vasm\vasm.exe 
DEL = del
CCOUT = -Fbin
COPTS = $(CCOUT) 
INC   = -I.
TARGET = ROM
TARGET2 = RAM

all: clean $(TARGET) $(TARGET2)

clean:
	$(DEL) $(TARGET) $(TARGET2)


$(TARGET):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L initialROMz80.txt -o $(TARGET) initialROMz80.s

$(TARGET2):
	$(CC) $(OPTS) $(INC) $(CCOUT) -nodotneeded -L initialRAMz80.txt -o $(TARGET2) initialRAMz80.s