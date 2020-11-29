
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
TARGET5 = edit
TARGET6 = dir
TARGET7 = type
TARGET8 = hexdump


all: clean $(TARGET) $(TARGET2) $(TARGET3) $(hello) $(TARGET4) $(TARGET5) $(TARGET6) $(TARGET7) $(TARGET8)

clean:
	$(DEL) $(TARGET) $(TARGET2) $(TARGET3) $(hello) $(TARGET4) $(TARGET5) $(TARGET6) $(TARGET7) $(TARGET8)


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

$(TARGET5):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L edit.txt -o $(TARGET5) edit.s

$(TARGET6):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L dir.txt -o $(TARGET6) dir.s

$(TARGET7):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L type.txt -o $(TARGET7) type.s

$(TARGET8):
	$(CC) $(OPTS) $(INC) $(CCOUT) -L hexdump.txt -o $(TARGET8) hexdump.s

