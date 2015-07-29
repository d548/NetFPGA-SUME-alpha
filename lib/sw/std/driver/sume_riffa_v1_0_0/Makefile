#
# Copyright (c) 2015 University of Cambridge
# Copyright (c) 2015 Bjoern A. Zeeb
# All rights reserved.
#
#  File:
#        Makefile
#
# $Id: Makefile,v 1.4 2015/06/24 22:34:42 root Exp root $
#
# This software was developed by the University of Cambridge Computer Laboratory 
# under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
# and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), 
# under contract FA8750-11-C-0249.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  NetFPGA licenses this
# file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#

#
# Makefile for the NetFPGA SUME driver.
#

#obj-$(CONFIG_NETFPGA_SUME) += sume.o
### OUTSIDE THE KERNEL TREE ...

MODULE_NAME:=	sume

KERNEL_VER ?=	$(shell uname -r)
KERNEL_DIR ?=	/lib/modules/$(KERNEL_VER)/build
INSTALL_DIR ?=	/lib/modules/$(KERNEL_VER)/extra/sume/

obj-m += $(MODULE_NAME).o

ifeq ($(CONFIG_NR_PORTS),)
CONFIG_NR_PORTS := 4
endif
ccflags-y += -DCONFIG_NR_PORTS=$(CONFIG_NR_PORTS)
ifneq ($(CONFIG_16BOFF),)
ccflags-y += -DSUME_16B_OFFSET=1
endif
ifeq ($(DEBUG),y)
ccflags-y += -g -DDEBUG
endif

all: modules

.PHONY: modules
modules:
	make -C $(KERNEL_DIR) M=$(PWD) modules

.PHONY: modules_install
modules_install: modules
	install -o root -g root -m 0755 -d $(INSTALL_DIR)
	install -o root -g root -m 0755 $(MODULE_NAME).ko $(INSTALL_DIR)
	depmod -a $(KERNEL_VER)

.PHONY: install
install: modules_install

.PHONY: clean
clean:
	make -C $(KERNEL_DIR) M=$(PWD) clean

# end
