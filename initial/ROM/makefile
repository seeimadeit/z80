
CC = vasm\vasm.exe 
DEL = del
CCOUT = -Fbin
COPTS = $(CCOUT) 
INC   = -I.
TARGET = ROM
TARGET2 = RAM
TARGET3 = cmd
hello = hello
TARGET4 = run@5000


all: clean $(TARGET) $(TARGET2) $(TARGET3) $(hello) $(TARGET4)

clean:
	$(DEL) $(TARGET) $(TARGET2) $(TARGET3) $(hello) $(TARGET4)


$(TARGET):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L initialROMz80.txt -o $(TARGET) initialROMz80.s

$(TARGET2):
	$(CC) $(OPTS) $(INC) $(CCOUT) -nodotneeded -L initialRAMz80.txt -o $(TARGET2) initialRAMz80.s

$(TARGET3):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L CMD.txt -o $(TARGET3) cmd.s

$(hello):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L helloworld.txt -o $(hello) hello.s

$(TARGET4):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L runat5000.txt -o $(TARGET4) run@5000.s
