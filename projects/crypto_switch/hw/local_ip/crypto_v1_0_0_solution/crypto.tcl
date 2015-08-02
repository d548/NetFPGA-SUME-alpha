#
# Copyright (c) 2015 University of Cambridge
# Copyright (c) 2015 Noa Zilberman
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
#   http:#www.www.netfpga-cic.org
#
# Unless required by applicable law or agreed to in writing, Work distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations under the License.
#
# @NETFPGA_LICENSE_HEADER_END@
#

# Vivado Launch Script
#### Change design settings here #######
set design  crypto
set top crypto
set device xc7vx690t-3-ffg1761
set proj_dir ./ip_proj
#set repo_dir $::env(SUME_FOLDER)/lib/hw/ip_repo
set ip_version 1.00
#set ip_output ./${design}_${ip_version}.zip
set lib_name NetFPGA
#####################################
# set IP paths
#####################################
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property source_mgmt_mode All [current_project]  
set_property top ${top} [current_fileset]
#file mkdir ${repo_dir}
# set_property ip_repo_paths ${repo_dir} [current_fileset]
set_property ip_repo_paths $::env(SUME_FOLDER)/lib/hw/  [current_fileset]
puts "Creating Input Arbiter IP"
# Project Constraints
#####################################
# Project Structure & IP Build
#####################################

read_verilog "./hdl/crypto.v"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project

set_property name ${design} [ipx::current_core]
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {NetFPGA} [ipx::current_core]
set_property company_url {www.netfpga.org} [ipx::current_core]
set_property vendor {NetFPGA} [ipx::current_core]
set_property supported_families {{virtex7} {Production}} [ipx::current_core]
set_property taxonomy {{/NetFPGA/Generic}} [ipx::current_core]
set_property version ${ip_version} [ipx::current_core]
set_property display_name ${design} [ipx::current_core]
set_property description ${design} [ipx::current_core]


update_ip_catalog -rebuild 
ipx::add_subcore NetFPGA:NetFPGA:fallthrough_small_fifo:1.00 [ipx::get_file_groups xilinx_verilogsynthesis -of_objects [ipx::current_core]]
ipx::add_subcore NetFPGA:NetFPGA:fallthrough_small_fifo:1.00 [ipx::get_file_groups xilinx_verilogbehavioralsimulation -of_objects [ipx::current_core]]
ipx::infer_user_parameters [ipx::current_core]

ipx::add_user_parameter {C_M_AXIS_DATA_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_M_AXIS_DATA_WIDTH [ipx::current_core]]
set_property display_name {C_M_AXIS_DATA_WIDTH} [ipx::get_user_parameter C_M_AXIS_DATA_WIDTH [ipx::current_core]]
set_property value {256} [ipx::get_user_parameter C_M_AXIS_DATA_WIDTH [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_M_AXIS_DATA_WIDTH [ipx::current_core]]

ipx::add_user_parameter {C_S_AXIS_DATA_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_S_AXIS_DATA_WIDTH [ipx::current_core]]
set_property display_name {C_S_AXIS_DATA_WIDTH} [ipx::get_user_parameter C_S_AXIS_DATA_WIDTH [ipx::current_core]]
set_property value {256} [ipx::get_user_parameter C_S_AXIS_DATA_WIDTH [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_S_AXIS_DATA_WIDTH [ipx::current_core]]

ipx::add_user_parameter {C_M_AXIS_TUSER_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_M_AXIS_TUSER_WIDTH [ipx::current_core]]
set_property display_name {C_M_AXIS_TUSER_WIDTH} [ipx::get_user_parameter C_M_AXIS_TUSER_WIDTH [ipx::current_core]]
set_property value {128} [ipx::get_user_parameter C_M_AXIS_TUSER_WIDTH [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_M_AXIS_TUSER_WIDTH [ipx::current_core]]

ipx::add_user_parameter {C_S_AXIS_TUSER_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_S_AXIS_TUSER_WIDTH [ipx::current_core]]
set_property display_name {C_S_AXIS_TUSER_WIDTH} [ipx::get_user_parameter C_S_AXIS_TUSER_WIDTH [ipx::current_core]]
set_property value {128} [ipx::get_user_parameter C_S_AXIS_TUSER_WIDTH [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_S_AXIS_TUSER_WIDTH [ipx::current_core]]

ipx::add_user_parameter {NUM_QUEUES} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter NUM_QUEUES [ipx::current_core]]
set_property display_name {NUM_QUEUES} [ipx::get_user_parameter NUM_QUEUES [ipx::current_core]]
set_property value {5} [ipx::get_user_parameter NUM_QUEUES [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter NUM_QUEUES [ipx::current_core]]

ipx::add_user_parameter {C_S_AXI_DATA_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_S_AXI_DATA_WIDTH [ipx::current_core]]
set_property display_name {C_S_AXI_DATA_WIDTH} [ipx::get_user_parameter C_S_AXI_DATA_WIDTH [ipx::current_core]]
set_property value {32} [ipx::get_user_parameter C_S_AXI_DATA_WIDTH [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_S_AXI_DATA_WIDTH [ipx::current_core]]

ipx::add_user_parameter {C_S_AXI_ADDR_WIDTH} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_S_AXI_ADDR_WIDTH [ipx::current_core]]
set_property display_name {C_S_AXI_ADDR_WIDTH} [ipx::get_user_parameter C_S_AXI_ADDR_WIDTH [ipx::current_core]]
set_property value {32} [ipx::get_user_parameter C_S_AXI_ADDR_WIDTH [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_S_AXI_ADDR_WIDTH [ipx::current_core]]

ipx::add_user_parameter {C_USE_WSTRB} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_USE_WSTRB [ipx::current_core]]
set_property display_name {C_S_AXI_ADDR_WIDTH} [ipx::get_user_parameter C_USE_WSTRB [ipx::current_core]]
set_property value {0} [ipx::get_user_parameter C_USE_WSTRB [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_USE_WSTRB [ipx::current_core]]

ipx::add_user_parameter {C_DPHASE_TIMEOUT} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_DPHASE_TIMEOUT [ipx::current_core]]
set_property display_name {C_DPHASE_TIMEOUT} [ipx::get_user_parameter C_DPHASE_TIMEOUT [ipx::current_core]]
set_property value {0} [ipx::get_user_parameter C_DPHASE_TIMEOUT [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_DPHASE_TIMEOUT [ipx::current_core]]

ipx::add_user_parameter {C_NUM_ADDRESS_RANGES} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_NUM_ADDRESS_RANGES [ipx::current_core]]
set_property display_name {C_NUM_ADDRESS_RANGES} [ipx::get_user_parameter C_NUM_ADDRESS_RANGES [ipx::current_core]]
set_property value {1} [ipx::get_user_parameter C_NUM_ADDRESS_RANGES [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_NUM_ADDRESS_RANGES [ipx::current_core]]

ipx::add_user_parameter {C_TOTAL_NUM_CE} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_TOTAL_NUM_CE [ipx::current_core]]
set_property display_name {C_TOTAL_NUM_CE} [ipx::get_user_parameter C_TOTAL_NUM_CE [ipx::current_core]]
set_property value {1} [ipx::get_user_parameter C_TOTAL_NUM_CE [ipx::current_core]]
set_property value_format {long} [ipx::get_user_parameter C_TOTAL_NUM_CE [ipx::current_core]]

ipx::add_user_parameter {C_S_AXI_MIN_SIZE} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_S_AXI_MIN_SIZE [ipx::current_core]]
set_property display_name {C_S_AXI_MIN_SIZE} [ipx::get_user_parameter C_S_AXI_MIN_SIZE [ipx::current_core]]
set_property value {0x0000FFFF} [ipx::get_user_parameter C_S_AXI_MIN_SIZE [ipx::current_core]]
set_property value_format {bitstring} [ipx::get_user_parameter C_S_AXI_MIN_SIZE [ipx::current_core]]

ipx::add_user_parameter {C_BASEADDR} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_BASEADDR [ipx::current_core]]
set_property display_name {C_BASEADDR} [ipx::get_user_parameter C_BASEADDR [ipx::current_core]]
set_property value {0x00000000} [ipx::get_user_parameter C_BASEADDR [ipx::current_core]]
set_property value_format {bitstring} [ipx::get_user_parameter C_BASEADDR [ipx::current_core]]

ipx::add_user_parameter {C_HIGHADDR} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_HIGHADDR [ipx::current_core]]
set_property display_name {C_HIGHADDR} [ipx::get_user_parameter C_HIGHADDR [ipx::current_core]]
set_property value {0x0000FFFF} [ipx::get_user_parameter C_HIGHADDR [ipx::current_core]]
set_property value_format {bitstring} [ipx::get_user_parameter C_HIGHADDR [ipx::current_core]]

ipx::add_user_parameter {C_ARD_NUM_CE_ARRAY} [ipx::current_core]
set_property value_resolve_type {user} [ipx::get_user_parameter C_ARD_NUM_CE_ARRAY [ipx::current_core]]
set_property display_name {C_ARD_NUM_CE_ARRAY} [ipx::get_user_parameter C_ARD_NUM_CE_ARRAY [ipx::current_core]]
set_property value {0x01} [ipx::get_user_parameter C_ARD_NUM_CE_ARRAY [ipx::current_core]]
set_property value_format {bitstring} [ipx::get_user_parameter C_ARD_NUM_CE_ARRAY [ipx::current_core]]

            
ipx::check_integrity [ipx::current_core]
ipx::save_core [ipx::current_core]
update_ip_catalog
close_project

#file delete -force ${proj_dir} 












