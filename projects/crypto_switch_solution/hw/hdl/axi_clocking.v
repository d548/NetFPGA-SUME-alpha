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
//        axi_clocking.v
//
//  Module:
//        axi_clocking
//
//  Author: Noa Zilberman
//
//  Description:
//        Sharable clocking resources for NetFPGA SUME
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
(* dont_touch = "yes" *)
module axi_clocking
  (
   // Inputs
   input clk_in_p,
   input clk_in_n,
//   input tx_mmcm_reset,

   // Status outputs
 //  output tx_mmcm_locked,
   
   // IBUFDS 200MHz    
   output clk_200 
   
   );

  // Signal declarations
  wire s_axi_dcm_aclk0;
  wire clkfbout;

  // 200MHz differencial into single-rail     
  IBUFDS clkin1_buf
   (.O  (clkin1),
    .I  (clk_in_p),
    .IB (clk_in_n)
    );

   // currently not used   
/*   MMCME2_BASE
  #(.DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (5),  
    .CLKIN1_PERIOD        (5.000),
    
    .CLKFBOUT_PHASE       (0.000),
    //.CLKOUT0_DIVIDE_F     (8.000), // 125MHz
    .CLKOUT0_DIVIDE_F     (5.000),   // 200MHz
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.5),
    //.CLKOUT1_DIVIDE       (8.000),  //125MHz -- 8.000
    .CLKOUT1_DIVIDE       (5.000),    //200MHz -- 5.000
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.5),
    .REF_JITTER1          (0.050))
  tx_mmcm
    // Output clocks
   (.CLKFBOUT            (clkfbout),
    .CLKOUT0             (s_axi_dcm_aclk0),
    .CLKOUT1             (),
     // Input clock control
    .CLKFBIN             (clkfbout),
    .CLKIN1              (clkin1),
    // Other control and status signals
    .LOCKED              (tx_mmcm_locked),
    .PWRDWN              (1'b0),
    // .RST                 (tx_mmcm_reset),
    .RST                 (1'b0),
    .CLKFBOUTB           (),
    .CLKOUT0B            (),
    .CLKOUT1B            (),
    .CLKOUT2             (),
    .CLKOUT2B            (),
    .CLKOUT3             (),
    .CLKOUT3B            (),
    .CLKOUT4             (),
    .CLKOUT5             (),
    .CLKOUT6             ());
 */
     
   BUFG clk_200_bufg0 (
     .I(clkin1),
     .O(clk_200));

endmodule
