SHELL := bash -Eeuo pipefail

NAME := speedtest-c
TARGET_ARCH := amd64
export ARCH_TEST :=
C_TARGETS := $(addsuffix $(NAME), $(wildcard build/$(TARGET_ARCH)/*/))

export CFLAGS := -Os -fdata-sections -ffunction-sections -s
STRIP := $(CROSS_COMPILE)strip

.PHONY: clean
clean:
	-rm -vrf $(C_TARGETS) $(MUSL_DIR)

.PHONY: build
build: $(C_TARGETS)

MUSL_DIR := $(CURDIR)/musl/$(TARGET_ARCH)
MUSL_PREFIX := $(MUSL_DIR)/prefix
MUSL_GCC := $(MUSL_PREFIX)/bin/musl-gcc

$(MUSL_GCC):
	mkdir -p '$(MUSL_DIR)'
	cd '$(MUSL_DIR)' && '/usr/local/src/musl/configure' --disable-shared --prefix='$(MUSL_PREFIX)'
	$(MAKE) -C '$(MUSL_DIR)' -j '$(shell nproc)' install

$(C_TARGETS): speedtest.c $(MUSL_GCC)
	$(MUSL_GCC) $(CFLAGS) -Wl,--gc-sections -static \
		-o '$@' \
		-D DOCKER_IMAGE='"$(notdir $(@D))"' \
		-D DOCKER_ARCH='"$(TARGET_ARCH)"' \
		'$<'
	$(STRIP) --strip-all --remove-section=.comment '$@'

.PHONY: test
test: $(C_TARGETS)
	@for b in $^; do \
		if [ -n "$$ARCH_TEST" ] && command -v arch-test && arch-test "$$ARCH_TEST"; then \
			( set -x && "./$$b" ); \
			( set -x && "./$$b" | grep -q '"'"$$(basename "$$(dirname "$$b")")"'"' ); \
		else \
			echo >&2 "warning: $$TARGET_ARCH ($$ARCH_TEST) not supported; skipping test"; \
		fi; \
	done