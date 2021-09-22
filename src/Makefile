SHELL := bash -Eeuo pipefail

# Passed arguments
TARGET_ARCH   := amd64
TARGET_HOST   := x86_64
SPTCLI_ARCH   := x86_64
CROSS_COMPILE := $(SPTCLI_ARCH)-linux-gnu-

# Environment arguments
INSTALL := /usr/src
ARTIFACTS := artifacts
TARGET_NAME := speedtest-c
TARGET_TAR_NAME := tar
TARGET_GZP_NAME := gzip
TARGET_SPT_NAME := speedtest
TARGET_CAC_NAME := ca-certificates

# Extra arguments
STRIP := $(CROSS_COMPILE)strip

# C flags
export CFLAGS := -static -Os -fdata-sections -ffunction-sections -s
export LDFLAGS := -Wl,--gc-sections -static

# Targets
TARGET     := $(ARTIFACTS)/$(TARGET_ARCH)/$(TARGET_NAME)
TARGET_TAR := $(ARTIFACTS)/$(TARGET_ARCH)/$(TARGET_TAR_NAME)
TARGET_GZP := $(ARTIFACTS)/$(TARGET_ARCH)/$(TARGET_GZP_NAME)

# Musl
MUSL_DIR := $(CURDIR)/musl/$(TARGET_ARCH)
MUSL_GCC := $(MUSL_DIR)/bin/musl-gcc

# Tar
TAR_DIR := $(CURDIR)/$(TARGET_TAR_NAME)/$(TARGET_ARCH)
TAR_ELF := $(TAR_DIR)/src/$(TARGET_TAR_NAME)

# Gzip
GZP_DIR := $(CURDIR)/$(TARGET_GZP_NAME)/$(TARGET_ARCH)
GZP_ELF := $(GZP_DIR)/$(TARGET_GZP_NAME)


.PHONY: clean
clean:
	$(info 1. Cleaning Artifacts Directory)

	-rm -vrf $(ARTIFACTS)/$(TARGET_ARCH)
	-mkdir -p $(ARTIFACTS)/$(TARGET_ARCH)


.PHONY: build
build: $(TARGET_TAR) $(TARGET_GZP) $(TARGET) 
	$(info Done)


$(MUSL_GCC):
	$(info 2. Compiling: MUSL Build Tools)

	mkdir -p $(MUSL_DIR)
	
	cd $(MUSL_DIR) && $(INSTALL)/musl/configure --disable-shared --prefix=$(MUSL_DIR) > /dev/null

	$(MAKE) -C $(MUSL_DIR) -j $(shell nproc) install > /dev/null


$(TARGET_TAR): $(INSTALL)/$(TARGET_TAR_NAME) $(MUSL_GCC)
	$(info 3. Compiling: $(TARGET_TAR_NAME))

	mkdir -p $(TAR_DIR)

	cd $(TAR_DIR) && env FORCE_UNSAFE_CONFIGURE=1 CC=$(MUSL_GCC) CFLAGS='$(CFLAGS)' LDFLAGS='$(LDFLAGS)' $(INSTALL)/$(TARGET_TAR_NAME)/configure --prefix=$(TAR_DIR) --host=$(TARGET_HOST) > /dev/null;
	$(MAKE) -C $(TAR_DIR) -j $(shell nproc) > /dev/null

	mv $(TAR_ELF) $@

	$(STRIP) --strip-all --strip-unneeded --remove-section=.comment $@

$(TARGET_GZP): $(INSTALL)/$(TARGET_GZP_NAME) $(MUSL_GCC)
	$(info 4. Compiling: $(TARGET_GZP_NAME))
	
	mkdir -p $(GZP_DIR)

	cd $(GZP_DIR) && env CC=$(MUSL_GCC) CFLAGS='$(CFLAGS)' LDFLAGS='$(LDFLAGS)' $(INSTALL)/$(TARGET_GZP_NAME)/configure --prefix=$(GZP_DIR) --host=$(TARGET_HOST) > /dev/null;
	$(MAKE) -C $(GZP_DIR) -j $(shell nproc) > /dev/null

	mv $(GZP_ELF) $@
	
	$(STRIP) --strip-all --strip-unneeded --remove-section=.comment $@


$(TARGET): speedtest.c speedtest.h $(MUSL_GCC)
	$(info 5. Compiling: $(TARGET_C_NAME))

	$(MUSL_GCC) $(CFLAGS) $(LDFLAGS) \
	-D ARCH='"$(SPTCLI_ARCH)"' \
	-D SPT='"$(TARGET_SPT_NAME)"' \
	-D GPZ='"$(TARGET_GZP_NAME)"' \
	-D TAR='"$(TARGET_TAR_NAME)"' \
	-D CAC='"$(TARGET_CAC_NAME)"' \
	$< -o $@ 

	$(STRIP) --strip-all --strip-unneeded --remove-section=.comment $@



.PHONY: test
test: speedtest.c
	gcc ./speedtest.c -o ./tests/test && cd ./tests && ./test
