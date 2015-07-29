#
# Copyright (c) 2015 Digilent Inc.
# Copyright (c) 2015 Tinghui Wang (Steve)
# All rights reserved.
#
# File:
# hw/Makefile
#
# Project:
# acceptance_test
#
# Author:
# Tinghui Wang (Steve)
#
# Description:
# This makefile is used to generate and compile acceptance_test hardware
# projects 
#
# This software was developed by the University of Cambridge Computer Laboratory
# under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
# and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL),
# under contract FA8750-11-C-0249.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA (NetFPGA) under one or more contributor
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
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#

all:
	@echo ""
	@echo "NetFPGA-SUME Acceptance Test HW Makefile"
	@echo ""
	@echo "make PROJ=<project_name> TARGETS"
	@echo "------------------------------------------------------"
	@echo "project:         Create hardware project"
	@echo "compile:         Synthesize and implement specified project"
	@echo "export_to_sdk:   Export implemented project to sw/embedded"
	@echo "load_elf:        Load ELF file for specified project"
	@echo "sim:             Simulate specified project"
	@echo ""
	@echo "clean:           Remove specified project"
	@echo "distclean:       Remove all generated projects"
	@echo ""
	@echo "Available Projects are: ddr3A, ddr3B, qdrA, qdrB, qdrC, pcie_g3, pcie, fmc_ibert, fmc_gtwizard, fmc_aurora, qth_ibert, qth_gtwizard, qth_aurora, xge_loopback, gpio"
	@echo ""

.PHONY: project compile export_to_sdk load_elf clean distclean

project:
	@if [ -z ${PROJ} ]; then\
		echo "make PROJ=<proj_name> project";\
		echo "Available Projects are: ddr3A, ddr3B, qdrA, qdrB, qdrC, pcie_g3, pcie, fmc_ibert, fmc_gtwizard, fmc_aurora, qth_ibert, qth_gtwizard, qth_aurora, xge_loopback, gpio";\
	else\
		echo "Create ${PROJ} acceptance test under folder /project";\
		if test -d project/nf_sume_${PROJ}_example; then\
			echo "${PROJ} already exists"; \
		else \
			vivado -mode batch -source tcl/nf_sume_${PROJ}.tcl;\
			if [ -f patch/nf_sume_${PROJ}.patch ]; then\
				patch -p1 < patch/nf_sume_${PROJ}.patch;\
			fi;\
		fi;\
	fi;

compile:
	@if [ -z ${PROJ} ]; then\
		echo "make PROJ=<proj_name> compile";\
		echo "Available Projects are: ddr3A, ddr3B, qdrA, qdrB, qdrC, pcie_g3, pcie, fmc_ibert, fmc_gtwizard, fmc_aurora, qth_ibert, qth_gtwizard, qth_aurora, xge_loopback, gpio";\
	else\
		if test -d project/nf_sume_${PROJ}_example; then\
			echo "Start Compiling ${PROJ}"; \
			vivado -mode batch -source tcl/nf_sume_compile.tcl -tclargs ${PROJ};\
		else \
			echo "Acceptance test ${PROJ} does not exists.";\
			echo "Please run \"make PROJ=${PROJ} project\" to create the project first";\
		fi;\
	fi;

export_to_sdk:
	@if [ -z ${PROJ} ]; then\
		echo "make PROJ=<proj_name> export_to_sdk";\
		echo "Available Projects are: ddr3A, ddr3B, qdrA, qdrB, qdrC, pcie_g3, pcie, fmc_ibert, fmc_gtwizard, fmc_aurora, qth_ibert, qth_gtwizard, qth_aurora, xge_loopback, gpio";\
	else\
		if test -d project/nf_sume_${PROJ}_example; then\
			echo "export ${PROJ} project to SDK"; \
			vivado -mode batch -source tcl/nf_sume_export_hardware.tcl -tclargs nf_sume_${PROJ};\
		else \
			echo "Acceptance test ${PROJ} does not exists.";\
			echo "Please run \"make PROJ=${PROJ} project compile\" to create and build the project first";\
		fi;\
	fi;

sim:
	@if [ -z ${PROJ} ]; then\
		echo "make PROJ=<proj_name> sim";\
		echo "Available Projects are: ddr3A, ddr3B, qdrA, qdrB, qdrC, pcie_g3, pcie, fmc_ibert, fmc_gtwizard, fmc_aurora, qth_ibert, qth_gtwizard, qth_aurora, xge_loopback, gpio";\
	else\
		if test -d project/nf_sume_${PROJ}_example; then\
			echo "export ${PROJ} project to SDK"; \
			vivado -mode batch -source tcl/nf_sume_sim.tcl -tclargs nf_sume_${PROJ};\
		else \
			echo "Acceptance test ${PROJ} does not exists.";\
			echo "Please run \"make PROJ=${PROJ} project compile\" to create and build the project first";\
		fi;\
	fi;

load_elf:
	@if [ ! -d ../bitfiles ]; then mkdir ../bitfiles; fi;
	@if [ -z ${PROJ} ]; then\
		echo "make PROJ=<proj_name> load_elf";\
		echo "Available Projects are: ddr3A, ddr3B, qdrA, qdrB, qdrC, pcie_g3, pcie, fmc_ibert, fmc_gtwizard, fmc_aurora, qth_ibert, qth_gtwizard, qth_aurora, xge_loopback, gpio";\
	else\
		if test -d project/nf_sume_${PROJ}_example; then\
			echo "load elf file to ${PROJ} project"; \
			vivado -mode batch -source tcl/nf_sume_load_elf.tcl -tclargs nf_sume_${PROJ};\
		else \
			echo "Acceptance test ${PROJ} does not exists.";\
			echo "Please run \"make PROJ=${PROJ} project compile\" to create and build the project first";\
		fi;\
	fi;

clean:
	@if [ -z ${PROJ} ]; then\
		echo "make PROJ=<proj_name> clean";\
		echo "Available Projects are: ddr3A, ddr3B, qdrA, qdrB, qdrC, pcie_g3, pcie, fmc_ibert, fmc_gtwizard, fmc_aurora, qth_ibert, qth_gtwizard, qth_aurora, xge_loopback, gpio";\
	else\
		rm -rfv project/nf_sume_${PROJ}_example;\
		rm -rfv ../sw/embedded/nf_sume_${PROJ}/hw;\
		rm -rfv vivado*;\
		rm -rfv *.log;\
		rm -rfv .Xil;\
		rm -rfv ..rej;\
		rm -rfv .srcs;\
		rm -rfv webtalk*;\
	fi;

distclean:
	@rm -rfv project
	@rm -rfv ../sw/embedded/nf_sume_*
	@rm -rfv vivado*
	@rm -rfv *.log
	@rm -rfv .Xil
	@rm -rfv ..rej
	@rm -rfv .srcs
	@rm -rfv webtalk*

