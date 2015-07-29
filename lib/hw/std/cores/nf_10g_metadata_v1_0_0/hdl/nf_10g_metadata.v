//
// Copyright (c) 2015 University of Cambridge All rights reserved.
//
// This software was developed by the University of Cambridge Computer
// Laboratory under EPSRC INTERNET Project EP/H040536/1, National Science
// Foundation under Grant No. CNS-0855268, and Defense Advanced Research
// Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), under
// contract FA8750-11-C-0249.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more
// contributor license agreements.  See the NOTICE file distributed with this
// work for additional information regarding copyright ownership.  NetFPGA
// licenses this file to you under the NetFPGA Hardware-Software License,
// Version 1.0 (the "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at:
//
//   http://netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@


`timescale 1ns/1ps

module nf_10g_metadata
#(
   // Master AXI Stream Data Width
   parameter   C_M_AXIS_DATA_WIDTH  = 64,
   parameter   C_S_AXIS_DATA_WIDTH  = 64,
   parameter   C_M_AXIS_TUSER_WIDTH = 128,
   parameter   C_S_AXIS_TUSER_WIDTH = 128,
   parameter   PKT_SIZE_POS         = 0,
   parameter   META_DATA_WIDTH      = 30
)
(
   //Global Ports
   input                                           axis_aclk,
   input                                           axis_resetn,

   // Master Stream Ports
   output   reg   [C_M_AXIS_DATA_WIDTH-1:0]        m_axis_tdata,
   output   reg   [(C_M_AXIS_DATA_WIDTH/8)-1:0]    m_axis_tkeep,
   output   reg   [C_M_AXIS_TUSER_WIDTH-1:0]       m_axis_tuser,
   output   reg                                    m_axis_tvalid,
   input                                           m_axis_tready,
   output   reg                                    m_axis_tlast,

   // Slave Stream Ports
   input          [C_S_AXIS_DATA_WIDTH-1:0]        s_axis_tdata,
   input          [(C_S_AXIS_DATA_WIDTH/8)-1:0]    s_axis_tkeep,
   input          [C_S_AXIS_TUSER_WIDTH-1:0]       s_axis_tuser,
   input                                           s_axis_tvalid,
   output   reg                                    s_axis_tready,
   input                                           s_axis_tlast,

   // Async fifo for meta data stats
   input                                           stat_fifo_empty,
   input          [META_DATA_WIDTH-1:0]            stat_fifo_din,
   output   reg                                    stat_fifo_rden,

   // source port interface 
   input          [7:0]                            src_port_num    
);

`define  IDLE     0
`define  HEAD     1
`define  SEND     2

reg   [1:0]    current_st, next_st;
reg   [14:0]   r_stat_din;

always @(posedge axis_aclk)
   if (~axis_resetn)
      current_st  <= `IDLE;
   else
      current_st  <= next_st;

always @(posedge axis_aclk)
   if (~axis_resetn)
      r_stat_din  <= 0;
   else if (s_axis_tlast & s_axis_tvalid & m_axis_tready)
      r_stat_din  <= 0;
   else if (stat_fifo_rden)
      r_stat_din  <= stat_fifo_din[5+:15]-4;

wire  [C_S_AXIS_TUSER_WIDTH-1:0]    w_tuser;

wire  [7:0]    w_src_port_num = (src_port_num == 0) ? 8'h01 :
                                (src_port_num == 1) ? 8'h04 :
                                (src_port_num == 2) ? 8'h10 :
                                (src_port_num == 3) ? 8'h40 : 8'h01;

assign w_tuser = {96'h0, 8'h0, w_src_port_num, 1'b0, r_stat_din};

always @(*) begin
   m_axis_tdata   = 0;
   m_axis_tkeep   = 0;
   m_axis_tuser   = 0;
   m_axis_tvalid  = 0;
   m_axis_tlast   = 0;
   s_axis_tready  = 0;
   stat_fifo_rden = 0;
   next_st        = 0;
   case (current_st)
      `IDLE : begin
         m_axis_tdata   = 0;
         m_axis_tkeep   = 0;
         m_axis_tuser   = 0;
         m_axis_tvalid  = 0;
         m_axis_tlast   = 0;
         s_axis_tready  = 0;
         stat_fifo_rden = (~stat_fifo_empty) ? 1 : 0;
         next_st        = (~stat_fifo_empty) ? `HEAD : `IDLE;
      end
      `HEAD : begin
         m_axis_tdata   = s_axis_tdata;
         m_axis_tkeep   = s_axis_tkeep;
         m_axis_tuser   = w_tuser;
         m_axis_tvalid  = s_axis_tvalid;
         m_axis_tlast   = s_axis_tlast;
         s_axis_tready  = m_axis_tready;
         stat_fifo_rden = 0;
         next_st        = (s_axis_tlast & s_axis_tvalid & m_axis_tready) ? `IDLE :
                          (               s_axis_tvalid & m_axis_tready) ? `SEND : `HEAD;
      end
      `SEND : begin
         m_axis_tdata   = s_axis_tdata;
         m_axis_tkeep   = s_axis_tkeep;
         m_axis_tuser   = 0;
         m_axis_tvalid  = s_axis_tvalid;
         m_axis_tlast   = s_axis_tlast;
         s_axis_tready  = m_axis_tready;
         stat_fifo_rden = 0;
         next_st        = (s_axis_tlast & s_axis_tvalid & m_axis_tready) ? `IDLE : `SEND;
      end
   endcase
end

endmodule
