#!/bin/sh

#
# Copyright (c) 2015 University of Cambridge
# All rights reserved.
#
# This software was developed by the University of Cambridge Computer Laboratory 
# under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
# and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), 
# under contract FA8750-11-C-0249.
#
# @NETFPGA_LICENSE_HEADER_START@
#
# Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
# license agreements.  See the NOTICE file distributed with this work for
# additional information regarding copyright ownership.  NetFPGA licenses this
# file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
# "License"); you may not use this file except in compliance with the
# License.  You may obtain a copy of the License at:
#
#   http://netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#

echo "===> SUME_MICROBLAZE_AXI_IIC_BASEADDR (0x40800000)"

echo "===> SUME_MICROBLAZE_UARTLITE_BASEADDR (0x40600000)"

echo "===> SUME_MICROBLAZE_DLMB_BRAM_BASEADDR (0x00000000)"

echo "===> SUME_MICROBLAZE_ILMB_BRAM_BASEADDR (0x00000000)"

echo "===> SUME_MICROBLAZE_AXI_INTC_BASEADDR (0x41200000)"

echo "===> SUME_INPUT_ARBITER_BASEADDR (0x44010000)"
echo -n "SUME_INPUT_ARBITER_FLIP_0_OFFSET: "
./rwaxi -a 0x44010008 -w 0x43216578
./rwaxi -a 0x44010008
echo -n "SUME_INPUT_ARBITER_DEBUG_0_OFFSET: "
./rwaxi -a 0x4401000c -w 0x43216578
./rwaxi -a 0x4401000c

echo "===> SUME_OUTPUT_QUEUES_BASEADDR (0x44030000)"
echo -n "SUME_OUTPUT_QUEUES_FLIP_0_OFFSET: "
./rwaxi -a 0x44030008 -w 0x43216578
./rwaxi -a 0x44030008
echo -n "SUME_OUTPUT_QUEUES_DEBUG_0_OFFSET: "
./rwaxi -a 0x4403000c -w 0x43216578
./rwaxi -a 0x4403000c

echo "===> SUME_OUTPUT_PORT_LOOKUP_BASEADDR (0x44020000)"
echo -n "SUME_OUTPUT_PORT_LOOKUP_FLIP_0_OFFSET: "
./rwaxi -a 0x44020008 -w 0x43216578
./rwaxi -a 0x44020008
echo -n "SUME_OUTPUT_PORT_LOOKUP_DEBUG_0_OFFSET: "
./rwaxi -a 0x4402000c -w 0x43216578
./rwaxi -a 0x4402000c

echo "===> SUME_NF_10G_INTERFACE0_BASEADDR (0x44040000)"
echo -n "SUME_NF_10G_INTERFACE_SHARED_FLIP_0_OFFSET: "
./rwaxi -a 0x44040008 -w 0x43216578
./rwaxi -a 0x44040008
echo -n "SUME_NF_10G_INTERFACE_SHARED_DEBUG_0_OFFSET: "
./rwaxi -a 0x4404000c -w 0x43216578
./rwaxi -a 0x4404000c

echo "===> SUME_NF_10G_INTERFACE1_BASEADDR (0x44050000)"
echo -n "SUME_NF_10G_INTERFACE_FLIP_0_OFFSET: "
./rwaxi -a 0x44050008 -w 0x43216578
./rwaxi -a 0x44050008
echo -n "SUME_NF_10G_INTERFACE_DEBUG_0_OFFSET: "
./rwaxi -a 0x4405000c -w 0x43216578
./rwaxi -a 0x4405000c

echo "===> SUME_NF_10G_INTERFACE2_BASEADDR (0x44060000)"
echo -n "SUME_NF_10G_INTERFACE_FLIP_0_OFFSET: "
./rwaxi -a 0x44060008 -w 0x43216578
./rwaxi -a 0x44060008
echo -n "SUME_NF_10G_INTERFACE_DEBUG_0_OFFSET: "
./rwaxi -a 0x4406000c -w 0x43216578
./rwaxi -a 0x4406000c

echo "===> SUME_NF_10G_INTERFACE3_BASEADDR (0x44070000)"
echo -n "SUME_NF_10G_INTERFACE_FLIP_0_OFFSET: "
./rwaxi -a 0x44070008 -w 0x43216578
./rwaxi -a 0x44070008
echo -n "SUME_NF_10G_INTERFACE_DEBUG_0_OFFSET: "
./rwaxi -a 0x4407000c -w 0x43216578
./rwaxi -a 0x4407000c

echo "===> SUME_NF_RIFFA_DMA_BASEADDR (0x44080000)"
echo -n "SUME_NF_RIFFA_DMA_FLIP_0_OFFSET: "
./rwaxi -a 0x44080008 -w 0x43216578
./rwaxi -a 0x44080008
echo -n "SUME_NF_RIFFA_DMA_DEBUG_0_OFFSET: "
./rwaxi -a 0x4408000c -w 0x43216578
./rwaxi -a 0x4408000c
