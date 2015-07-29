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

# Set variables

# CORE CONFIG parameters
set sharedLogic          "FALSE"
set tdataWidth           256

set convWidth [expr $tdataWidth/8]

if { $sharedLogic eq "True" || $sharedLogic eq "TRUE" || $sharedLogic eq "true" } {
   set supportLevel 1
} else {
   set supportLevel 0
}

create_ip -name axi_10g_ethernet -vendor xilinx.com -library ip -version 2.0 -module_name axi_10g_ethernet_nonshared
set_property -dict [list CONFIG.Management_Interface {false}] [get_ips axi_10g_ethernet_nonshared]
set_property -dict [list CONFIG.base_kr {BASE-R}] [get_ips axi_10g_ethernet_nonshared]
set_property -dict [list CONFIG.SupportLevel $supportLevel] [get_ips axi_10g_ethernet_nonshared]
set_property -dict [list CONFIG.autonegotiation {0}] [get_ips axi_10g_ethernet_nonshared]
set_property -dict [list CONFIG.fec {0}] [get_ips axi_10g_ethernet_nonshared]
set_property -dict [list CONFIG.Statistics_Gathering {0}] [get_ips axi_10g_ethernet_nonshared]

set_property generate_synth_checkpoint false [get_files axi_10g_ethernet_nonshared.xci]
reset_target all [get_ips axi_10g_ethernet_nonshared]
generate_target all [get_ips axi_10g_ethernet_nonshared]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 1.1 -module_name axis_data_fifo_0
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8}] [get_ips axis_data_fifo_0]
set_property -dict [list CONFIG.TUSER_WIDTH {128}] [get_ips axis_data_fifo_0]
set_property -dict [list CONFIG.IS_ACLK_ASYNC {1}] [get_ips axis_data_fifo_0]
set_property -dict [list CONFIG.FIFO_DEPTH {32}] [get_ips axis_data_fifo_0]
set_property -dict [list CONFIG.HAS_TSTRB {0} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1}] [get_ips axis_data_fifo_0]

set_property generate_synth_checkpoint false [get_files axis_data_fifo_0.xci]
reset_target all [get_ips axis_data_fifo_0]
generate_target all [get_ips axis_data_fifo_0]

#create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 1.1 -module_name axis_data_fifo_1
#set_property -dict [list CONFIG.TDATA_NUM_BYTES {8}] [get_ips axis_data_fifo_1]
#set_property -dict [list CONFIG.TUSER_WIDTH {128}] [get_ips axis_data_fifo_1]
#set_property -dict [list CONFIG.IS_ACLK_ASYNC {1}] [get_ips axis_data_fifo_1]
#set_property -dict [list CONFIG.FIFO_DEPTH {32}] [get_ips axis_data_fifo_1]
#set_property -dict [list CONFIG.HAS_TSTRB {0} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1}] [get_ips axis_data_fifo_1]

create_ip -name fifo_generator -vendor xilinx.com -library ip -version 12.0 -module_name fifo_generator_0
set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Performance_Options {First_Word_Fall_Through}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Input_Data_Width {30} CONFIG.Input_Depth {16}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Reset_Pin {false}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Output_Data_Width {30} CONFIG.Output_Depth {16}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Full_Flags_Reset_Value {0}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Use_Dout_Reset {false}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Data_Count_Width {4}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Write_Data_Count_Width {4}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Read_Data_Count_Width {4}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Full_Threshold_Assert_Value {15}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Full_Threshold_Negate_Value {14}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Empty_Threshold_Assert_Value {4}] [get_ips fifo_generator_0]
set_property -dict [list CONFIG.Empty_Threshold_Negate_Value {5}] [get_ips fifo_generator_0]

set_property generate_synth_checkpoint false [get_files fifo_generator_0.xci]
reset_target all [get_ips fifo_generator_0]
generate_target all [get_ips fifo_generator_0]


create_ip -name fifo_generator -vendor xilinx.com -library ip -version 12.0 -module_name fifo_generator_status
set_property -dict [list CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Performance_Options {First_Word_Fall_Through}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Input_Data_Width {458} CONFIG.Input_Depth {16}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Reset_Pin {false}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Output_Data_Width {458} CONFIG.Output_Depth {16}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Full_Flags_Reset_Value {0}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Use_Dout_Reset {false}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Data_Count_Width {4}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Write_Data_Count_Width {4}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Read_Data_Count_Width {4}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Full_Threshold_Assert_Value {15}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Full_Threshold_Negate_Value {14}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Empty_Threshold_Assert_Value {4}] [get_ips fifo_generator_status]
set_property -dict [list CONFIG.Empty_Threshold_Negate_Value {5}] [get_ips fifo_generator_status]

set_property generate_synth_checkpoint false [get_files fifo_generator_status.xci]
reset_target all [get_ips fifo_generator_status]
generate_target all [get_ips fifo_generator_status]

create_ip -name util_vector_logic -vendor xilinx.com -library ip -version 2.0 -module_name inverter_0
set_property -dict [list CONFIG.C_SIZE {1}] [get_ips inverter_0]
set_property -dict [list CONFIG.C_OPERATION {not}] [get_ips inverter_0]

set_property generate_synth_checkpoint false [get_files inverter_0.xci]
reset_target all [get_ips inverter_0]
generate_target all [get_ips inverter_0]

#create_ip -name util_vector_logic -vendor xilinx.com -library ip -version 2.0 -module_name areset_inverter_0
#set_property -dict [list CONFIG.C_SIZE {1}] [get_ips areset_inverter_0]
#set_property -dict [list CONFIG.C_OPERATION {not}] [get_ips areset_inverter_0]

create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_dwidth_converter_0
set_property -dict [list CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} \
      CONFIG.HAS_TSTRB {0}  \
      CONFIG.TUSER_BITS_PER_BYTE {16}] [get_ips axis_dwidth_converter_0]
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {8} CONFIG.M_TDATA_NUM_BYTES $convWidth \
      CONFIG.TUSER_BITS_PER_BYTE {16} CONFIG.HAS_TLAST {1} CONFIG.HAS_TSTRB {0} \
      CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1}] [get_ips axis_dwidth_converter_0]

set_property generate_synth_checkpoint false [get_files axis_dwidth_converter_0.xci]
reset_target all [get_ips axis_dwidth_converter_0]
generate_target all [get_ips axis_dwidth_converter_0]

create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_dwidth_converter_1
set_property -dict [list CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} \
      CONFIG.HAS_TSTRB {0}  \
      CONFIG.TUSER_BITS_PER_BYTE {16}] [get_ips axis_dwidth_converter_1]
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES $convWidth CONFIG.M_TDATA_NUM_BYTES {8} \
      CONFIG.TUSER_BITS_PER_BYTE {16} CONFIG.HAS_TLAST {1} CONFIG.HAS_TSTRB {0} \
      CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1}] [get_ips axis_dwidth_converter_1]

set_property generate_synth_checkpoint false [get_files axis_dwidth_converter_1.xci]
reset_target all [get_ips axis_dwidth_converter_1]
generate_target all [get_ips axis_dwidth_converter_1]



