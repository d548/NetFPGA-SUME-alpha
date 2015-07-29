#!/usr/bin/env python

#
# Copyright (c) 2015 University of Cambridge
# Copyright (c) 2015 Modified by Neelakandan Manihatty Bojan, Georgina Kalogeridou
# All rights reserved.
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

import logging
logging.getLogger("scapy.runtime").setLevel(logging.ERROR)

from NFTest import *
import sys
import os
from scapy.layers.all import Ether, IP, TCP
from subprocess import Popen, PIPE
from reg_defines_reference_nic import *



conn = ('../connections/conn', [])
nftest_init(sim_loop = ['nf0', 'nf1', 'nf2', 'nf3'], hw_config = [conn])

nftest_start()

# set parameters
SA = "aa:bb:cc:dd:ee:ff"
TTL = 64
DST_IP = "192.168.1.1"
SRC_IP = "192.168.0.1"
nextHopMAC = "dd:55:dd:66:dd:77"
if isHW():
    NUM_PKTS = 5
else:
    NUM_PKTS = 5

pkts = []

print "Sending now: "
totalPktLengths = [0,0,0,0]
# send NUM_PKTS from ports nf2c0...nf2c3
for i in range(NUM_PKTS):
    if isHW():
        for port in range(4):
            DA = "00:ca:fe:00:00:%02x"%port
            pkt = make_IP_pkt(dst_MAC=DA, src_MAC=SA, dst_IP=DST_IP,
                             src_IP=SRC_IP, TTL=TTL,
                             pkt_len=60)
            totalPktLengths[port] += len(pkt)
         
            nftest_send_dma('nf' + str(port), pkt)
            nftest_expect_dma('nf' + str(port), pkt)
    else:
	DA = "00:ca:fe:00:00:00"
        pkt = make_IP_pkt(dst_MAC=DA, src_MAC=SA, dst_IP=DST_IP,
                             src_IP=SRC_IP, TTL=TTL,
                             pkt_len=60) 
	pkt.time = (i*(1e-8))
        pkts.append(pkt)

if not isHW():
    nftest_send_phy('nf0', pkts) 
    nftest_expect_dma('nf0', pkts) 

print ""

nftest_barrier()


if isHW():
    rres1=nftest_regread_expect(SUME_INPUT_ARBITER_PKTIN_0(), 0x28)
    proc = Popen(["./rwaxi","-a","0x44010010"], stdout=PIPE)
    print proc.stdout.read() 
  	
    rres2=nftest_regread_expect(SUME_INPUT_ARBITER_PKTOUT_0(), 0x28)
    proc = Popen(["./rwaxi","-a","0x44010014"], stdout=PIPE)
    print proc.stdout.read() 

    rres3=nftest_regread_expect(SUME_OUTPUT_PORT_LOOKUP_PKTIN_0(), 0x28)
    proc = Popen(["./rwaxi","-a","0x44020010"], stdout=PIPE)
    print proc.stdout.read() 

    rres4=nftest_regread_expect(SUME_OUTPUT_PORT_LOOKUP_PKTOUT_0(), 0x28)
    proc = Popen(["./rwaxi","-a","0x44020014"], stdout=PIPE)
    print proc.stdout.read() 


    rres5=nftest_regread_expect(SUME_OUTPUT_QUEUES_PKTIN_0(), 0x28)
    proc = Popen(["./rwaxi","-a","0x44030010"], stdout=PIPE)
    print proc.stdout.read() 


    rres6=nftest_regread_expect(SUME_OUTPUT_QUEUES_PKTOUT_0(), 0x28)
    proc = Popen(["./rwaxi","-a","0x44030014"], stdout=PIPE)
    print proc.stdout.read() 


    mres=[rres1,rres2,rres3,rres4,rres5,rres6]

nftest_finish(mres)




