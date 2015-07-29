//////////////////////////////////////////////////////////////////////////////
//  
// Copyright (c) 2015 Digilent Inc.
// Copyright (C) 2009 - 2013 Xilinx, Inc. All rights reserved.
// All rights reserved.
//
// File:
// nf_sume_xge_shared_logic.v
//  
// Library:
// hw/std/cores/nf_sume_10g_interface_shared_logic_1.0
//
// Author:
// Tinghui Wang (Steve)
//
// Description:
// 10GBASE-R shared clocking and reset logic which can be shared between multiple xge interfacores
//
// This software was developed by the University of Cambridge Computer Laboratory
// under EPSRC INTERNET Project EP/H040536/1, National Science Foundation under Grant No. CNS-0855268,
// and Defense Advanced Research Projects Agency (DARPA) and Air Force Research Laboratory (AFRL),
// under contract FA8750-11-C-0249.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more contributor
// license agreements. See the NOTICE file distributed with this work for
// additional information regarding copyright ownership. NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License. You may obtain a copy of the License at:
//
// http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//  
// ------------------------------------------------------------------------------
//
//        This file contains confidential and proprietary information
//        of Xilinx, Inc. and is protected under U.S. and 
//        international copyright and other intellectual property
//        laws.
//        
//        DISCLAIMER
//        This disclaimer is not a license and does not grant any
//        rights to the materials distributed herewith. Except as
//        otherwise provided in a valid license issued to you by
//        Xilinx, and to the maximum extent permitted by applicable
//        law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//        WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//        AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//        BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//        INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//        (2) Xilinx shall not be liable (whether in contract or tort,
//        including negligence, or under any other theory of
//        liability) for any loss or damage of any kind or nature
//        related to, arising under or in connection with these
//        materials, including for any direct, or any indirect,
//        special, incidental, or consequential loss or damage
//        (including loss of data, profits, goodwill, or any type of
//        loss or damage suffered as a result of any action brought
//        by a third party) even if such damage or loss was
//        reasonably foreseeable or Xilinx had been advised of the
//        possibility of the same.
//        
//        CRITICAL APPLICATIONS
//        Xilinx products are not designed or intended to be fail-
//        safe, or for use in any application requiring fail-safe
//        performance, such as life-support or safety devices or
//        systems, Class III medical devices, nuclear facilities,
//        applications related to the deployment of airbags, or any
//        other applications that could lead to death, personal
//        injury, or severe property or environmental damage
//        (individually and collectively, "Critical
//        Applications"). Customer assumes the sole risk and
//        liability of any use of Xilinx products in Critical
//        Applications, subject only to applicable laws and
//        regulations governing limitations on product liability.
//        
//        THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//        PART OF THIS FILE AT ALL TIMES.

`timescale 1ns / 1ps

module nf_sume_10g_interface_shared_logic(
    // GTX REFCLK
    input refclk,
    // Async Reset
    input areset,
    
    // clk156, DRP clock for PMA/PCS
    output clk156,
    output dclk,
    // Sync Reset in clk156 Domain
    output areset_clk156,
    // Sync Reset for GTX_TX GTX_RX
    output gttxreset,
    output gtrxreset,
    output reset_counter_done,
    // QPLL Signals
    output qplllock,
    output qplloutclk,
    output qplloutrefclk
    );
    
    reg [7:0] reset_counter = 8'h00;
    reg [3:0] reset_pulse = 4'b1110;

    // BUFG for clk156 (Shared by all PMA_PCS core)
    BUFG clk156_bufg_inst 
    (
        .I     (refclk),
        .O     (clk156) 
    );
    
    // DRP Clock (must be the same as clk156)
    assign dclk = clk156;
    
    // Async Reset Synchronizer
    nf_sume_10g_pcs_pma_ff_synchronizer_rst2 
      #(
        .C_NUM_SYNC_REGS(4),
        .C_RVAL(1'b1)) 
    areset_clk156_sync_i
      (
       .clk(clk156),
       .rst(areset),
       .data_in(1'b0),
       .data_out(areset_clk156)
      );

    // Hold off release the GT resets until 500ns after configuration.
    // 128 ticks at 6.4ns period will be >> 500 ns.
    always @(posedge clk156)
    begin
      if (!reset_counter[7])
        reset_counter   <=   reset_counter + 1'b1;   
      else
        reset_counter   <=   reset_counter;
    end
    
    always @(posedge clk156)
    begin
      if (areset_clk156 == 1'b1)  
        reset_pulse   <=   4'b1110;
      else if(reset_counter[7])
        reset_pulse   <=   {1'b0, reset_pulse[3:1]};
    end
    assign   qpllreset  =     reset_pulse[0];
    assign   gttxreset  =     reset_pulse[0];
    assign   gtrxreset  =     reset_pulse[0];  

    assign reset_counter_done = reset_counter[7];

    // Instantiate the 10GBASER/KR GT Common block
    nf_sume_10g_pcs_pma_gt_common # (
        .WRAPPER_SIM_GTRESET_SPEEDUP("TRUE") ) //Does not affect hardware
    nf_sume_10g_pcs_pma_gt_common_block
      (
       .refclk(refclk),
       .qpllreset(qpllreset),
       .qplllock(qplllock),
       .qplloutclk(qplloutclk),
       .qplloutrefclk(qplloutrefclk)
      );
      
endmodule
