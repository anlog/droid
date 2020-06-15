# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2015-2019
KERNELDIR ?= $(HOME)/code/dipper/kernel/xiaomi/dipper
KERNELDIR := $(HOME)/code/dipper/out/target/product/dipper/obj/KERNEL_OBJ
$(info KERNELDIR is $(KERNELDIR))
ARCH := arm64
CC := /home/dp/code/master/prebuilts/clang/host/linux-x86/clang-r383902/bin/clang
CLANG_TRIPLE := aarch64-linux-gnu-
CROSS_COMPILE := aarch64-linux-androidkernel-
CROSS_COMPILE_ARM32 := aarch64-linux-androidkernel-

PWD := $(shell pwd)
OUT := $(PWD)/out

all: module
debug: module-debug

ifneq ($(V),1)
MAKEFLAGS += --no-print-directory
endif

export PATH := $(HOME)/code/master/prebuilts/clang/host/linux-x86/clang-r383902/bin:$(HOME)/code/master/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin:$(PATH)

WIREGUARD_VERSION = $(patsubst v%,%,$(shell GIT_CEILING_DIRECTORIES="$(PWD)/../.." git describe --dirty 2>/dev/null))

module:
	@$(MAKE) -C $(KERNELDIR) M=$(PWD) O=$(OUT) ARCH=$(ARCH) CC=clang CLANG_TRIPLE=$(CLANG_TRIPLE) CROSS_COMPILE=$(CROSS_COMPILE) CROSS_COMPILE_ARM32=$(CROSS_COMPILE) WIREGUARD_VERSION="$(WIREGUARD_VERSION)" modules

module-debug:
	@$(MAKE) -C $(KERNELDIR) M=$(PWD) O=$(OUT) ARCH=$(ARCH) CC=clang CLANG_TRIPLE=$(CLANG_TRIPLE) CROSS_COMPILE=$(CROSS_COMPILE) CROSS_COMPILE_ARM32=$(CROSS_COMPILE) WIREGUARD_VERSION="$(WIREGUARD_VERSION)" V=1 CONFIG_WIREGUARD_DEBUG=y WIREGUARD_VERSION="$(WIREGUARD_VERSION)" modules

clean:
	@$(MAKE) -C $(KERNELDIR) M=$(PWD) O=$(OUT) ARCH=$(ARCH) CC=clang CLANG_TRIPLE=$(CLANG_TRIPLE) CROSS_COMPILE=$(CROSS_COMPILE) CROSS_COMPILE_ARM32=$(CROSS_COMPILE) WIREGUARD_VERSION="$(WIREGUARD_VERSION)" clean

module-install:
	@$(MAKE) -C $(KERNELDIR) M=$(PWD) O=$(OUT) ARCH=$(ARCH) CC=clang CLANG_TRIPLE=$(CLANG_TRIPLE) CROSS_COMPILE=$(CROSS_COMPILE) CROSS_COMPILE_ARM32=$(CROSS_COMPILE) WIREGUARD_VERSION="$(WIREGUARD_VERSION)" modules WIREGUARD_VERSION="$(WIREGUARD_VERSION)" modules_install

install: module-install

.PHONY: all module module-debug 
