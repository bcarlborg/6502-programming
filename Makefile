# Unix, using vasm assembler and vlink linker
# - vasm  information: http://sun.hasenbraten.de/vasm/
# - vlink information: http://sun.hasenbraten.de/vasm/

# ###############################################
# ASSEMBLER CONFIGURATION
# ###############################################
AS = vasm6502_oldstyle
AS_FLAGS = -dotdir -Fvobj
AS_OUT = -o $(DUMMY)


# ###############################################
# LINKER CONFIGURATION
# ###############################################
LN = vlink
LINKER_CONFIG = link.config
LN_FLAGS = -b rawbin2 -T $(LINKER_CONFIG)
LN_OUT = -o $(DUMMY)


# ###############################################
# CHIP IO CONFIGURATION
# ###############################################
UPLOAD = minipro
ROM_CHIP = AT28C64B
UPLOAD_FLAGS = -p $(ROM_CHIP)
UPLOAD_OUT = -w $(DUMMY)


# ###############################################
# UNIX CONFIGURATION
# ###############################################
RM = rm -f


# ###############################################
# INPUT, INTERMEDIARY, AND OUTPUT FILES
# ###############################################
TARGET = 6502.out
OBJECTS_DIR = objs/
OBJECTS = $(OBJECTS_DIR)main.obj \
					$(OBJECTS_DIR)lcd-control-routines.obj 


# ###############################################
# DEFAULT TARGET
# RUNS WHEN MAKE IS CALLED WITH NO INPUTS
# FIRST TARGET IN THE FILE IS THE DEFAULT
# ###############################################

$(TARGET): $(OBJECTS)
	$(LN) $(LN_FLAGS) $(LN_OUT) $@ $^


# ###############################################
# GLOBAL TARGETS
# ###############################################
all: $(TARGET)

upload: $(TARGET)
	$(UPLOAD) $(UPLOAD_FLAGS) $(UPLOAD_OUT)$(TARGET)

clean:
	$(RM) $(OBJECTS_DIR)/* $(TARGET)

# ###############################################
# INDIVIDUAL TARGETS
# ###############################################

$(OBJECTS_DIR)main.obj: global_constants.h.s main.s 
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ main.s

$(OBJECTS_DIR)lcd-control-routines.obj: global_constants.h.s lcd-control-routines.s 
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ lcd-control-routines.s
