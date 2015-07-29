//
// Copyright (c) 2015 University of Cambridge 
// All rights reserved.
//
// This software was developed by the University of Cambridge Computer
// Laboratory under EPSRC INTERNET Project EP/H040536/1, National Science
// Foundation under Grant No. CNS-0855268, and Defense Advanced Research
// Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), under
// contract FA8750-11-C-0249.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA Open Systems C.I.C. (NetFPGA) under one or more
// contributor license agreements.  See the NOTICE file distributed with this
// work for additional information regarding copyright ownership.  NetFPGA
// licenses this file to you under the NetFPGA Hardware-Software License,
// Version 1.0 (the "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at:
//
//   http://www.netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@
//
//

`timescale 1ns/1ps

module rx_axi_riffa #(
   parameter C_PCI_DATA_WIDTH = 128,
   parameter C_RIFFA_OFFSET   = 31'h0,
   parameter C_PREAM_VALUE    = 16'hCAFE 
)
(
   input    wire                             CLK, 
   input    wire                             RST,
   // RIFFA outputs
   output   reg                              CHNL_TX,
   output   reg   [C_PCI_DATA_WIDTH-1:0]     CHNL_TX_DATA,
   output   reg                              CHNL_TX_DATA_VALID, 
   output   reg                              CHNL_TX_LAST,
   output   reg   [31:0]                     CHNL_TX_LEN, 
   output   reg   [30:0]                     CHNL_TX_OFF,
   input    wire                             CHNL_TX_DATA_REN,
   input    wire                             CHNL_TX_ACK,
   // AXIS-Slave input 
   input    wire  [C_PCI_DATA_WIDTH-1:0]     tdata,
   input    wire  [C_PCI_DATA_WIDTH/8-1:0]   tkeep,
   input    wire  [127:0]                    tuser,
   input    wire                             tvalid,
   input    wire                             tlast,
   output   reg                              tready
);

function integer log2;
   input integer number;
   begin
      log2=0;
      while(2**log2<number) begin
         log2=log2+1;
      end
   end
endfunction

`define  AXIS_IDLE      0
`define  AXIS_WRITE     1

`define  RIFFA_IDLE     0
`define  RIFFA_SEND     1

localparam  MAX_PKT_SIZE = 2000; 
localparam  IN_FIFO_DEPTH_BIT = log2(MAX_PKT_SIZE/(C_PCI_DATA_WIDTH/8));

reg   [C_PCI_DATA_WIDTH:0]    fifo_in;
wire  [C_PCI_DATA_WIDTH:0]    fifo_out;
reg   fifo_wren, fifo_rden;
wire  fifo_full, fifo_empty;

fallthrough_small_fifo #(
   .WIDTH            (  C_PCI_DATA_WIDTH+1   ),
   .MAX_DEPTH_BITS   (  IN_FIFO_DEPTH_BIT    )
)
axis_riffa_fifo
(
   .clk              (  CLK                  ),
   .reset            (  RST                  ),
   .din              (  fifo_in              ),
   .wr_en            (  fifo_wren            ),
   .rd_en            (  fifo_rden            ),
   .dout             (  fifo_out             ),
   .nearly_full      (  fifo_full            ),
   .empty            (  fifo_empty           ),
   .full             (),
   .prog_full        ()
);

wire  [C_PCI_DATA_WIDTH+1-1:0]   fifo_first;

assign fifo_first = {1'b0, tuser[64+:64], C_PREAM_VALUE, tuser[0+:16], 8'b0, tuser[24+:8], 8'b0, tuser[16+:8]};

reg   [2:0]    axis_current_state, axis_next_state;

always @(posedge CLK)
   if (RST) begin
      axis_current_state   <= 0;
   end
   else begin
      axis_current_state   <= axis_next_state;
   end

always @(*) begin
   fifo_in           = 0;
   fifo_wren         = 0;
   tready            = 0;
   axis_next_state   = `AXIS_IDLE;
   case(axis_current_state)
      `AXIS_IDLE : begin
         fifo_in           = fifo_first;
         fifo_wren         = (tvalid & ~fifo_full) ? 1 : 0;
         axis_next_state   = (tvalid & ~fifo_full) ? `AXIS_WRITE : `AXIS_IDLE;
      end
      `AXIS_WRITE : begin
         fifo_in           = {tlast, tdata};
         fifo_wren         = (tvalid & ~fifo_full) ? 1 : 0;
         tready            = ~fifo_full;
         axis_next_state   = (tvalid & ~fifo_full & tlast) ? `AXIS_IDLE : `AXIS_WRITE;
      end
   endcase
end

reg   [30:0]   r_len;

always @(posedge CLK)
   if (RST) begin
      r_len <= 0;
   end
   else if (riffa_current_state == `RIFFA_IDLE && ~fifo_empty) begin
      r_len <= (fifo_out[34+:14] + (|fifo_out[32+:2]) + 4);
   end


reg   [2:0]    riffa_current_state, riffa_next_state;

always @(posedge CLK)
   if (RST) begin
      riffa_current_state  <= 0;
   end
   else begin
      riffa_current_state  <= riffa_next_state;
   end

always @(*) begin
   CHNL_TX              = 0;
   CHNL_TX_LAST         = 0;
   CHNL_TX_DATA         = 0;
   CHNL_TX_DATA_VALID   = 0;
   CHNL_TX_LEN          = 0;
   CHNL_TX_OFF          = 0;
   fifo_rden            = 0;
   riffa_next_state     = `RIFFA_IDLE;
   case (riffa_current_state)
      `RIFFA_IDLE : begin
         CHNL_TX              = 0;
         CHNL_TX_LAST         = 0;
         CHNL_TX_DATA         = 0;
         CHNL_TX_DATA_VALID   = 0;
         CHNL_TX_LEN          = 0;
         CHNL_TX_OFF          = 0;
         fifo_rden            = 0;
         riffa_next_state     = (~fifo_empty) ? `RIFFA_SEND : `RIFFA_IDLE;
      end
      `RIFFA_SEND : begin
         CHNL_TX              = 1;
         CHNL_TX_LAST         = 1;
         CHNL_TX_DATA         = fifo_out[0+:128];
         CHNL_TX_DATA_VALID   = ~fifo_empty & (CHNL_TX_ACK | CHNL_TX_DATA_REN);
         CHNL_TX_LEN          = r_len;
         CHNL_TX_OFF          = C_RIFFA_OFFSET;
         fifo_rden            = ~fifo_empty & CHNL_TX_DATA_REN;
         riffa_next_state     = (fifo_out[128]) ? `RIFFA_IDLE : `RIFFA_SEND;
      end
   endcase
end

endmodule
