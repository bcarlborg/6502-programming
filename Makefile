# Unix, using vasm assembler, vlink linker, miniPRO chip programmer
# - vasm    information : http://sun.hasenbraten.de/vasm/
# - vlink   information : http://sun.hasenbraten.de/vasm/
# - minipro information : https://gitlab.com/DavidGriffith/minipro/

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


# ###############################################
# DEFAULT TARGET
# RUNS WHEN MAKE IS CALLED WITH NO INPUTS
# FIRST TARGET IN THE FILE IS THE DEFAULT
# ###############################################

default: base_print_test

# ###############################################
# GLOBAL TARGETS
# ###############################################
clean:
	$(RM) $(OBJECTS_DIR)*

all: base_print_test


# ###############################################
# GLOBAL_UTILITIES_TARGETS
# ###############################################

GLOBAL_UTILITIES_DIRECTORY = global_utilities/
GLOBAL_UTILITIES_OBJECT_PREFIX = $(OBJECTS_DIR)global_utils_
GLOBAL_UTILITIES_HEADERS = $(GLOBAL_UTILITIES_DIRECTORY)global_constants.h.s
GLOBAL_UTILITIES_OBJECTS = $(GLOBAL_UTILITIES_OBJECT_PREFIX)lcd-control-routines.obj \
													 $(GLOBAL_UTILITIES_OBJECT_PREFIX)program_harness.obj \
													 $(GLOBAL_UTILITIES_OBJECT_PREFIX)strings.obj

global_utilities: $(GLOBAL_UTILITIES_OBJECT_PREFIX)lcd-control-routines.obj \
									$(GLOBAL_UTILITIES_OBJECT_PREFIX)program_harness.obj \
									$(GLOBAL_UTILITIES_OBJECT_PREFIX)strings.obj

$(GLOBAL_UTILITIES_OBJECT_PREFIX)lcd-control-routines.obj: \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(GLOBAL_UTILITIES_DIRECTORY)lcd-control-routines.s 
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ $(GLOBAL_UTILITIES_DIRECTORY)lcd-control-routines.s

$(GLOBAL_UTILITIES_OBJECT_PREFIX)program_harness.obj: \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(GLOBAL_UTILITIES_DIRECTORY)program_harness.s
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ $(GLOBAL_UTILITIES_DIRECTORY)program_harness.s

$(GLOBAL_UTILITIES_OBJECT_PREFIX)strings.obj: \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(GLOBAL_UTILITIES_DIRECTORY)strings.s
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ $(GLOBAL_UTILITIES_DIRECTORY)strings.s

# ###############################################
# HELP
# ###############################################

help:
	@echo ""
	@echo ""
	@echo "MAKE"
	@echo "- build the default target  :  make"
	@echo "  (base print test)"
	@echo "- remove all object files   :  make clean"
	@echo ""
	@echo "BASE PRINT TEST PROJECT"
	@echo "- make project objects      :  make base_print_test"
	@echo "- upload objects to EEPROM  :  make upload_base_print_test"
	@echo "- remove project objects    :  make clean_base_print_test"
	@echo ""
	@echo "BLINKING LIGHT TIMER PROJECT"
	@echo "- make project objects      :  make blinking_light_timer"
	@echo "- upload objects to EEPROM  :  make upload_blinking_light_timer"
	@echo "- remove project objects    :  make clean_blinking_light_timer"
	@echo ""
	@echo "SIMPLE TEXT EDITOR PROJECT"
	@echo "- make project objects      :  make simple_text_editor"
	@echo "- upload objects to EEPROM  :  make upload_simple_text_editor"
	@echo "- remove project objects    :  make clean_simple_text_editor"
	@echo ""
	@echo ""

# ###############################################
# BASE_PRINT_TEST PROJECT
# ###############################################

# constants
BASE_PRINT_TEST_OBJECT_PREFIX = $(OBJECTS_DIR)base_print_test_
BASE_PRINT_TEST_DIR = projects/base_print_test/

# main target: simply points to main executable
base_print_test: $(BASE_PRINT_TEST_OBJECT_PREFIX)executable.out

# target for uploading main executable
upload_base_print_test: $(BASE_PRINT_TEST_OBJECT_PREFIX)executable.out
	$(UPLOAD) $(UPLOAD_FLAGS) $(UPLOAD_OUT)$(BASE_PRINT_TEST_OBJECT_PREFIX)executable.out

# target to clean all of teh base print test objects and executables
clean_base_print_test:
	$(RM) $(BASE_PRINT_TEST_OBJECT_PREFIX)*

# target for main executable
$(BASE_PRINT_TEST_OBJECT_PREFIX)executable.out: \
			$(BASE_PRINT_TEST_OBJECT_PREFIX)main.obj \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(GLOBAL_UTILITIES_OBJECTS)
	$(LN) $(LN_FLAGS) $(LN_OUT)$@ \
		$(BASE_PRINT_TEST_OBJECT_PREFIX)main.obj \
		$(GLOBAL_UTILITIES_OBJECTS)

$(BASE_PRINT_TEST_OBJECT_PREFIX)main.obj: \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(BASE_PRINT_TEST_DIR)main.s
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ $(BASE_PRINT_TEST_DIR)main.s


# ###############################################
# BLINKING LIGHT TIMER PROJECT
# ###############################################

# constants
BLINKING_LIGHT_TIMER_OBJECT_PREFIX = $(OBJECTS_DIR)blinking_light_timer_
BLINKING_LIGHT_TIMER_DIR = projects/blinking_light_timer/

# main target: simply points to main executable
blinking_light_timer: $(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)executable.out

# target for uploading main executable
upload_blinking_light_timer: $(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)executable.out
	$(UPLOAD) $(UPLOAD_FLAGS) $(UPLOAD_OUT)$(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)executable.out

# target to clean all of teh base print test objects and executables
clean_blinking_light_timer:
	$(RM) $(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)*

# target for main executable
$(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)executable.out: \
			$(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)main.obj \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(GLOBAL_UTILITIES_OBJECTS)
	$(LN) $(LN_FLAGS) $(LN_OUT)$@ \
		$(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)main.obj \
		$(GLOBAL_UTILITIES_OBJECTS)

$(BLINKING_LIGHT_TIMER_OBJECT_PREFIX)main.obj: \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(BLINKING_LIGHT_TIMER_DIR)main.s
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ $(BLINKING_LIGHT_TIMER_DIR)main.s


# ###############################################
# SIMPLE TEXT EDITOR PROJECT
# ###############################################

# constants
SIMPLE_TEXT_EDITOR_OBJECT_PREFIX = $(OBJECTS_DIR)simple_text_editor_
SIMPLE_TEXT_EDITOR_DIR = projects/simple_text_editor/

# main target: simply points to main executable
simple_text_editor: $(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)executable.out

# target for uploading main executable
upload_simple_text_editor: $(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)executable.out
	$(UPLOAD) $(UPLOAD_FLAGS) $(UPLOAD_OUT)$(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)executable.out

# target to clean all of teh base print test objects and executables
clean_simple_text_editor:
	$(RM) $(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)*

# target for main executable
$(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)executable.out: \
			$(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)main.obj \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(GLOBAL_UTILITIES_OBJECTS)
	$(LN) $(LN_FLAGS) $(LN_OUT)$@ \
		$(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)main.obj \
		$(GLOBAL_UTILITIES_OBJECTS)

$(SIMPLE_TEXT_EDITOR_OBJECT_PREFIX)main.obj: \
			$(GLOBAL_UTILITIES_HEADERS) \
			$(SIMPLE_TEXT_EDITOR_DIR)main.s
	$(AS) $(AS_FLAGS) $(AS_OUT)$@ $(SIMPLE_TEXT_EDITOR_DIR)main.s

