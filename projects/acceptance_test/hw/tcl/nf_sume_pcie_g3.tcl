#
# Copyright (c) 2015 Digilent Inc.
# Copyright (c) 2015 Tinghui Wang (Steve)
# All rights reserved.
#
# File:
# nf_sume_pcie_g3.tcl
#
# Project:
# acceptance_test
#
# Author:
# Tinghui Wang (Steve)
#
# Description:
# This script is used to generate PCI-E Gen3 x8 example for NetFPGA-SUME
# board. The design is based on Xilinx VC709 PCI-E Reference Design
# (XTP237, rdf0235)
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
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#


set project_name        {nf_sume_pcie_g3_example}
set device 				{xc7vx690tffg1761-3}
set ip_repo_path        {../../../../lib/hw}
set bd_name             {baseSys}

# Create project under project folder
if {![file isdirectory project]} {
	file mkdir project
}
cd project
create_project $project_name ./$project_name -part $device

# Set IP Repository
set_property ip_repo_paths ${ip_repo_path} [current_fileset]
update_ip_catalog -rebuild

# Create Block Design
create_bd_design ${bd_name}

# Create and Configure 7series PCI-E IP Core
create_bd_cell -type ip -vlnv xilinx.com:ip:pcie3_7x nf10_sume_pcie
set_property -dict [list\
	CONFIG.pcie_blk_locn {X0Y1}\
	CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8}\
	CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s}\
	CONFIG.axisten_if_enable_client_tag {true}\
	CONFIG.AXISTEN_IF_RC_STRADDLE {true}\
	CONFIG.PF0_DEVICE_ID {0007}\
	CONFIG.pf0_bar0_size {8}\
	CONFIG.pf0_bar1_enabled {true}\
	CONFIG.pf0_bar1_size {4}\
	CONFIG.mode_selection {Advanced}\
	CONFIG.cfg_fc_if {false}\
	CONFIG.cfg_ext_if {false}\
	CONFIG.cfg_status_if {false}\
	CONFIG.per_func_status_if {false}\
	CONFIG.cfg_mgmt_if {false}\
	CONFIG.rcv_msg_if {false}\
	CONFIG.cfg_tx_msg_if {false}\
	CONFIG.cfg_ctl_if {false}\
	CONFIG.tx_fc_if {false}\
	CONFIG.en_ext_clk {false}\
] [get_bd_cells nf10_sume_pcie]

# Create PCI-E To AXI-Lite Bridge
create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_2_axilite pcie_2_axilite
set_property -dict [list\
	CONFIG.BAR1SIZE {0xFFFFFFFFFFFFF000}\
	CONFIG.BAR0SIZE {0xFFFFFFFFFFFFE000}\
	CONFIG.BAR2AXI1_TRANSLATION {0x00000000C2000000}\
	CONFIG.BAR2AXI0_TRANSLATION {0x00000000C0000000}\
] [get_bd_cells pcie_2_axilite]

# Create BRAM Controller
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl axi_bramA_ctrl
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl axi_bramB_ctrl
set_property -dict [list\
	CONFIG.SINGLE_PORT_BRAM {1}\
	CONFIG.SUPPORTS_NARROW_BURST.VALUE_SRC USER\
	CONFIG.SUPPORTS_NARROW_BURST {0}\
] [get_bd_cells axi_bramA_ctrl]
set_property -dict [list\
	CONFIG.SINGLE_PORT_BRAM {1}\
	CONFIG.SUPPORTS_NARROW_BURST.VALUE_SRC USER\
	CONFIG.SUPPORTS_NARROW_BURST {0}\
] [get_bd_cells axi_bramB_ctrl]

# Apply Block Diagram Automation to create BRAMs and Interconnects 
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen" }  [get_bd_intf_pins axi_bramA_ctrl/BRAM_PORTA]
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "New Blk_Mem_Gen" }  [get_bd_intf_pins axi_bramB_ctrl/BRAM_PORTA]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/pcie_2_axilite/m_axi" Clk "Auto" }  [get_bd_intf_pins axi_bramA_ctrl/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/pcie_2_axilite/m_axi" Clk "Auto" }  [get_bd_intf_pins axi_bramB_ctrl/S_AXI]

# Remove the redundant auto-generated instances
delete_bd_objs [get_bd_nets clk_wiz_locked] [get_bd_cells clk_wiz]
connect_bd_net -net [get_bd_nets clk_wiz_clk_out1] [get_bd_pins nf10_sume_pcie/user_clk]
delete_bd_objs [get_bd_nets rst_clk_wiz_100M_interconnect_aresetn] [get_bd_cells rst_clk_wiz_100M]
delete_bd_objs [get_bd_nets rst_clk_wiz_100M_peripheral_aresetn]

# Connect Reset Network
create_bd_port -dir O user_lnk_up
create_bd_port -dir O user_reset
connect_bd_net	[get_bd_pins nf10_sume_pcie/user_reset]\
				[get_bd_ports user_reset]
connect_bd_net	[get_bd_pins nf10_sume_pcie/user_lnk_up]\
				[get_bd_pins axi_mem_intercon/ARESETN]\
				[get_bd_pins axi_mem_intercon/M00_ARESETN]\
				[get_bd_pins axi_mem_intercon/S00_ARESETN]\
				[get_bd_pins axi_mem_intercon/M01_ARESETN]\
				[get_bd_pins axi_bramA_ctrl/s_axi_aresetn]\
				[get_bd_pins axi_bramB_ctrl/s_axi_aresetn]\
				[get_bd_pins pcie_2_axilite/axi_aresetn]\
				[get_bd_ports user_lnk_up]

# Connect AXIS Buses
connect_bd_intf_net	[get_bd_intf_pins nf10_sume_pcie/s_axis_cc]\
					[get_bd_intf_pins pcie_2_axilite/m_axis_cc]
connect_bd_intf_net [get_bd_intf_pins pcie_2_axilite/s_axis_cq]\
					[get_bd_intf_pins nf10_sume_pcie/m_axis_cq]

# Create Clock Network for PCI-E
create_bd_port -dir I -from 0 -to 0 pcie_refclk_p
create_bd_port -dir I -from 0 -to 0 pcie_refclk_n

create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf pcie_ibufdsgte
set_property -dict [list CONFIG.C_BUF_TYPE {IBUFDSGTE}] [get_bd_cells pcie_ibufdsgte]
connect_bd_net [get_bd_pins pcie_ibufdsgte/IBUF_OUT] [get_bd_pins nf10_sume_pcie/sys_clk]
connect_bd_net [get_bd_pins /pcie_ibufdsgte/IBUF_DS_P] [get_bd_ports pcie_refclk_p]
connect_bd_net [get_bd_pins /pcie_ibufdsgte/IBUF_DS_N] [get_bd_ports pcie_refclk_n]

# PCIE-RSTN
create_bd_port -dir I -type rst pcie_rstn
set_property CONFIG.POLARITY "ACTIVE_LOW" [get_bd_ports pcie_rstn]
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic pcie_rst_inv
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not}] [get_bd_cells pcie_rst_inv]
connect_bd_net [get_bd_ports pcie_rstn] [get_bd_pins pcie_rst_inv/Op1]
connect_bd_net [get_bd_pins pcie_rst_inv/Res] [get_bd_pins nf10_sume_pcie/sys_reset]

# PCI-E External Port
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt
connect_bd_intf_net [get_bd_intf_pins nf10_sume_pcie/pcie_7x_mgt] [get_bd_intf_ports pcie_7x_mgt]

# Configure AXI-Lite Memory Mapping
set_property range 8K [get_bd_addr_segs {pcie_2_axilite/m_axi/SEG_axi_bramA_ctrl_Mem0}]
set_property range 4K [get_bd_addr_segs {pcie_2_axilite/m_axi/SEG_axi_bramB_ctrl_Mem0}]

# Generate Top Wrapper
make_wrapper -files [get_files -regexp -nocase {.*\.bd}] -top -import -force
add_files -fileset constrs_1 -norecurse ../xdc/nf_sume_pcie_g3.xdc

# Update Compile Order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

exit
