#!/usr/bin/env python
#
# Copyright (c) 2015 University of Cambridge
# Copyright (c) 2015 Modified by Neelakandan Manihatty Bojan, Georgina Kalogeridou, Noa Zilberman
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
from reg_defines_crypto_switch import *
from crypto_lib import *

conn = ('../connections/conn', [])
nftest_init(sim_loop = ['nf0', 'nf1', 'nf2', 'nf3'], hw_config = [conn])
nftest_start()

# set parameters
SA = "aa:bb:cc:dd:ee:ff"
DA = "00:ca:fe:00:00:02"
TTL = 64
DST_IP = "192.168.1.1"
SRC_IP = "192.168.0.1"
nextHopMAC = "dd:55:dd:66:dd:77"

routerMAC = []
routerIP = []
for i in range(4):
    routerMAC.append("00:ca:fe:00:00:0%d"%(i+1))
    routerIP.append("192.168.%s.40"%i)

num_broadcast = 10


# Reset the switch table lookup counters (value is reset every time is read)
if isHW():
    nftest_regread(SUME_OUTPUT_PORT_LOOKUP_0_LUTHIT())
    nftest_regread(SUME_OUTPUT_PORT_LOOKUP_0_LUTMISS())


# define the key we want to use to encrypt the packet
key = 0x0

# Now write the key in the register (in case an older key is left inside)
if isHW():
    nftest_regwrite(SUME_CRYPTO_0_KEY(), key)

pkts = []
encrypt_pkts=[]
pkta = []
encrypt_pkta=[]
for i in range(num_broadcast):
    pkt = make_IP_pkt(src_MAC="aa:bb:cc:dd:ee:ff", dst_MAC=routerMAC[0],
                      src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=96)

    pkt.tuser_sport = 1
    pkts.append(pkt)
    encrypt_pkts.append(encrypt_pkt(key, pkt))

    for i in range(num_broadcast):
        for pkt in pkts:
            pkt.time = i*(1e-8)
        for pkt in encrypt_pkts:
            pkt.time = i*(1e-8)

    if isHW():
        nftest_expect_phy('nf1', encrypt_pkt(key, pkt))
        nftest_send_phy('nf0', pkt)
    
if not isHW():
    nftest_expect_phy('nf1', encrypt_pkts)
    nftest_expect_phy('nf2', encrypt_pkts)
    nftest_expect_phy('nf3', encrypt_pkts)
    nftest_send_phy('nf0', pkts)

nftest_barrier()

num_normal = 10

for i in range(num_normal):
    pkt = make_IP_pkt(dst_MAC="aa:bb:cc:dd:ee:ff", src_MAC=routerMAC[1],
                     src_IP="192.168.0.1", dst_IP="192.168.1.1", pkt_len=96)

    pkt.tuser_sport = 1
    pkta.append(pkt)
    encrypt_pkta.append(encrypt_pkt(key, pkt))

    for i in range(num_normal):
        for pkt in pkta:
            pkt.time = i*(1e-8)
        for pkt in encrypt_pkta:
            pkt.time = i*(1e-8)

    if isHW():
        nftest_expect_phy('nf0', encrypt_pkt(key, pkt))
        nftest_send_phy('nf1', pkt)

if not isHW():
    nftest_expect_phy('nf0', encrypt_pkta)
    nftest_send_phy('nf1', pkta)

nftest_barrier()

if isHW():
    # Now we expect to see the lut_hit and lut_miss registers incremented and we
    # verify this by doing a  reg
    rres1= nftest_regread_expect(SUME_OUTPUT_PORT_LOOKUP_0_LUTMISS(), num_broadcast)
    rres2= nftest_regread_expect(SUME_OUTPUT_PORT_LOOKUP_0_LUTHIT(), num_normal)
    # List containing the return values of the reg_reads
    mres = [rres1, rres2]
else:
    nftest_regread_expect(SUME_OUTPUT_PORT_LOOKUP_0_LUTMISS(), num_broadcast) # lut_miss
    nftest_regread_expect(SUME_OUTPUT_PORT_LOOKUP_0_LUTHIT(), num_normal) # lut_hit
    mres = []

nftest_finish(mres)
