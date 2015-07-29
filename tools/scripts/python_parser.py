#!/usr/bin/python

#
# Copyright (c) 2015 University of Cambridge
# Copyright (c) 2015 Neelakandan Manihatty Bojan
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
################################################################################
#  Description:
#        This is used to convert xparameters.h to reg_defines.h
#

import re

input_file = open("reg_defines.h", "r")
output_file = open("reg_defines.py", "w")
output_file.write("#!/usr/bin/python")
for line in input_file:
    match_defines = re.match(r'\s*#define ([a-zA-Z_0-9]+) (.*)', line)
    match_comments = re.match(r'\s*[/\*][\s*\*](.*)', line)
    match_slash = re.match(r'\s*[/*](.*)', line)
 	
    if match_defines:
        newline1= "\ndef %s():\n    return %s" % (match_defines.group(1),match_defines.group(2))
	output_file.write(newline1)

    elif match_comments:
	newline2= "\n# %s" % (match_comments.group(1))
        output_file.write(newline2)

    elif match_slash:
	newline3= "\n# %s" % (match_slash.group(1))
        output_file.write(newline3)

    else:
        output_file.write(line)


