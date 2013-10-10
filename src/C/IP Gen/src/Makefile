# Declaration of variables
CC = g++
CC_FLAGS = -w

.SILENT:

# File names
EXEC = RS_IP_gen
SOURCES = $(wildcard *.cpp)
OBJECTS = $(SOURCES:.cpp=.o)
VHDFILES = $(SOURCES:.cpp=.vhd)

# Main target
$(EXEC): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(EXEC)

# To obtain object files
%.o: %.cpp
	$(CC) -c $(CC_FLAGS) $< -o $@

# To remove generated files
clean:
	rm -f $(EXEC) $(OBJECTS) $(VHDFILES) *~