//-
// Copyright (c) 2015 University of Cambridge
// Copyright (c) 2015 Noa Zilberman
// All rights reserved.
//
// This software was developed by the University of Cambridge Computer Laboratory 
// under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
// and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), 
// under contract FA8750-11-C-0249.
//
//  File:
//        nf_sume_microblaze.v
//
//  Module:
//        nf_sume_microblaze
//
//  Author: Noa Zilberman
//
//  Description:
//        Microblaze instantiation module
//
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//

`timescale 1ps / 1ps

 module nf_sume_microblaze  (

  input clk,
  //-SI5324 I2C programming interface 
  inout i2c_clk,
  inout i2c_data,
  output [1:0] i2c_reset,  

  //UART interface
  input uart_rxd,
  output uart_txd,
 
  //reset
  input       reset
);


wire i2c_scl_o;
wire i2c_scl_i;
wire i2c_scl_t;
wire i2c_sda_o;
wire i2c_sda_i;
wire i2c_sda_t;

IOBUF i2c_scl_iobuf
       (.I(i2c_scl_o),
        .IO(i2c_clk),
        .O(i2c_scl_i),
        .T(i2c_scl_t));
        
IOBUF i2c_sda_iobuf
       (.I(i2c_sda_o),
        .IO(i2c_data),
        .O(i2c_sda_i),
        .T(i2c_sda_t));


nf_sume_mbsys nf_sume_mbsys_i
   (
    .iic_fpga_scl_i(i2c_scl_i),
    .iic_fpga_scl_o(i2c_scl_o),
    .iic_fpga_scl_t(i2c_scl_t),
    .iic_fpga_sda_i(i2c_sda_i),
    .iic_fpga_sda_o(i2c_sda_o),
    .iic_fpga_sda_t(i2c_sda_t),
    .iic_reset     (i2c_reset),
    .uart_rxd      (uart_rxd),
    .uart_txd      (uart_txd),
    .reset         (sys_reset_n_c),
    .sysclk        (clk)
);



endmodule

