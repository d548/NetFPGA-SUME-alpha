//----------------------------------------------------------------------------
// This software is Copyright © 2015 The Regents of the University of 
// California. All Rights Reserved.
//
// Permission to copy, modify, and distribute this software and its 
// documentation for educational, research and non-profit purposes, without 
// fee, and without a written agreement is hereby granted, provided that the 
// above copyright notice, this paragraph and the following three paragraphs 
// appear in all copies.
//
// Permission to make commercial use of this software may be obtained by 
// contacting:
// Technology Transfer Office
// 9500 Gilman Drive, Mail Code 0910
// University of California
// La Jolla, CA 92093-0910
// (858) 534-5815
// invent@ucsd.edu
// 
// This software program and documentation are copyrighted by The Regents of 
// the University of California. The software program and documentation are 
// supplied "as is", without any accompanying services from The Regents. The 
// Regents does not warrant that the operation of the program will be 
// uninterrupted or error-free. The end-user understands that the program was 
// developed for research purposes and is advised not to rely exclusively on 
// the program for any reason.
// 
// IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO
// ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR
// CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
// OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
// EVEN IF THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE. THE UNIVERSITY OF
// CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
// INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
// THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, 
// AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO
// PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
// MODIFICATIONS.
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// Filename:            tx_engine_ultrascale.v
// Version:             1.0
// Verilog Standard:    Verilog-2001
// Description:         The TX Engine takes unformatted request and completions,
// formats these packets into AXI packets for the Xilinx Core. These packets
// must meet max-request, max-payload, and payload termination requirements (see
// Read Completion Boundary). The TX Engine does not check these requirements
// during operation, but may do so during simulation.
// 
// This Engine is capable of operating at "line rate".
// Author:              Dustin Richmond (@darichmond)
//-----------------------------------------------------------------------------
`include "trellis.vh"
`include "ultrascale.vh"
module tx_engine_ultrascale
    #(
      parameter C_PCI_DATA_WIDTH = 128,
      parameter C_PIPELINE_INPUT = 1,
      parameter C_PIPELINE_OUTPUT = 0,
      parameter C_MAX_PAYLOAD_DWORDS = 64
      )
    (
     // Interface: Clocks
     input                                   CLK,
     // Interface: Resets
     input                                   RST_IN,
     // Interface: Configuration
     input [`SIG_CPLID_W-1:0]                CONFIG_COMPLETER_ID,

     // Interface: CC
     input                                   S_AXIS_CC_TREADY,
     output                                  S_AXIS_CC_TVALID,
     output                                  S_AXIS_CC_TLAST,
     output [C_PCI_DATA_WIDTH-1:0]           S_AXIS_CC_TDATA,
     output [(C_PCI_DATA_WIDTH/32)-1:0]      S_AXIS_CC_TKEEP,
     output [`SIG_CC_TUSER_W-1:0]            S_AXIS_CC_TUSER,

     // Interface: TXC Engine
     input                                   TXC_DATA_VALID,
     input [C_PCI_DATA_WIDTH-1:0]            TXC_DATA,
     input                                   TXC_DATA_START_FLAG,
     input [clog2s(C_PCI_DATA_WIDTH/32)-1:0] TXC_DATA_START_OFFSET,
     input                                   TXC_DATA_END_FLAG,
     input [clog2s(C_PCI_DATA_WIDTH/32)-1:0] TXC_DATA_END_OFFSET,
     output                                  TXC_DATA_READY,

     input                                   TXC_META_VALID,
     input [`SIG_FBE_W-1:0]                  TXC_META_FDWBE,
     input [`SIG_LBE_W-1:0]                  TXC_META_LDWBE,
     input [`SIG_LOWADDR_W-1:0]              TXC_META_ADDR,
     input [`SIG_TYPE_W-1:0]                 TXC_META_TYPE,
     input [`SIG_LEN_W-1:0]                  TXC_META_LENGTH,
     input [`SIG_BYTECNT_W-1:0]                 TXC_META_BYTE_COUNT,
     input [`SIG_TAG_W-1:0]                  TXC_META_TAG,
     input [`SIG_REQID_W-1:0]                TXC_META_REQUESTER_ID,
     input [`SIG_TC_W-1:0]                   TXC_META_TC,
     input [`SIG_ATTR_W-1:0]                 TXC_META_ATTR,
     input                                   TXC_META_EP,
     output                                  TXC_META_READY,
     output                                  TXC_SENT,

     // Interface: RQ
     input                                   S_AXIS_RQ_TREADY,
     output                                  S_AXIS_RQ_TVALID,
     output                                  S_AXIS_RQ_TLAST,
     output [C_PCI_DATA_WIDTH-1:0]           S_AXIS_RQ_TDATA,
     output [(C_PCI_DATA_WIDTH/32)-1:0]      S_AXIS_RQ_TKEEP,
     output [`SIG_RQ_TUSER_W-1:0]            S_AXIS_RQ_TUSER,
    
     // Interface: TXR Engine
     input                                   TXR_DATA_VALID,
     input [C_PCI_DATA_WIDTH-1:0]            TXR_DATA,
     input                                   TXR_DATA_START_FLAG,
     input [clog2s(C_PCI_DATA_WIDTH/32)-1:0] TXR_DATA_START_OFFSET,
     input                                   TXR_DATA_END_FLAG,
     input [clog2s(C_PCI_DATA_WIDTH/32)-1:0] TXR_DATA_END_OFFSET,
     output                                  TXR_DATA_READY,

     input                                   TXR_META_VALID,
     input [`SIG_FBE_W-1:0]                  TXR_META_FDWBE, 
     input [`SIG_LBE_W-1:0]                  TXR_META_LDWBE,
     input [`SIG_ADDR_W-1:0]                 TXR_META_ADDR,
     input [`SIG_LEN_W-1:0]                  TXR_META_LENGTH,
     input [`SIG_TAG_W-1:0]                  TXR_META_TAG,
     input [`SIG_TC_W-1:0]                   TXR_META_TC,
     input [`SIG_ATTR_W-1:0]                 TXR_META_ATTR,
     input [`SIG_TYPE_W-1:0]                 TXR_META_TYPE,
     input                                   TXR_META_EP,
     output                                  TXR_META_READY,
     output                                  TXR_SENT
     );

    localparam C_DEPTH_PACKETS = 10;
    /*AUTOWIRE*/
    /*AUTOINPUT*/
    /*AUTOOUTPUT*/

    reg                                      rTxcSent;
    reg                                      rTxrSent;

    assign TXC_SENT = rTxcSent;
    assign TXR_SENT = rTxrSent;
    
    always @(posedge CLK) begin
        rTxcSent <= S_AXIS_CC_TLAST & S_AXIS_CC_TVALID & S_AXIS_CC_TREADY;
        rTxrSent <= S_AXIS_RQ_TLAST & S_AXIS_RQ_TVALID & S_AXIS_RQ_TREADY;
    end                                  
    
    txr_engine_ultrascale
        #(
          /*AUTOINSTPARAM*/
          // Parameters
          .C_PCI_DATA_WIDTH             (C_PCI_DATA_WIDTH),
          .C_PIPELINE_INPUT             (C_PIPELINE_INPUT),
          .C_PIPELINE_OUTPUT            (C_PIPELINE_OUTPUT),
          .C_DEPTH_PACKETS              (C_DEPTH_PACKETS),
          .C_MAX_PAYLOAD_DWORDS         (C_MAX_PAYLOAD_DWORDS))
    txr_engine_inst
        (/*AUTOINST*/
         // Outputs
         .S_AXIS_RQ_TVALID              (S_AXIS_RQ_TVALID),
         .S_AXIS_RQ_TLAST               (S_AXIS_RQ_TLAST),
         .S_AXIS_RQ_TDATA               (S_AXIS_RQ_TDATA[C_PCI_DATA_WIDTH-1:0]),
         .S_AXIS_RQ_TKEEP               (S_AXIS_RQ_TKEEP[(C_PCI_DATA_WIDTH/32)-1:0]),
         .S_AXIS_RQ_TUSER               (S_AXIS_RQ_TUSER[`SIG_RQ_TUSER_W-1:0]),
         .TXR_DATA_READY                (TXR_DATA_READY),
         .TXR_META_READY                (TXR_META_READY),
         // Inputs
         .CLK                           (CLK),
         .RST_IN                        (RST_IN),
         .CONFIG_COMPLETER_ID           (CONFIG_COMPLETER_ID[`SIG_CPLID_W-1:0]),
         .S_AXIS_RQ_TREADY              (S_AXIS_RQ_TREADY),
         .TXR_DATA_VALID                (TXR_DATA_VALID),
         .TXR_DATA                      (TXR_DATA[C_PCI_DATA_WIDTH-1:0]),
         .TXR_DATA_START_FLAG           (TXR_DATA_START_FLAG),
         .TXR_DATA_START_OFFSET         (TXR_DATA_START_OFFSET[clog2s(C_PCI_DATA_WIDTH/32)-1:0]),
         .TXR_DATA_END_FLAG             (TXR_DATA_END_FLAG),
         .TXR_DATA_END_OFFSET           (TXR_DATA_END_OFFSET[clog2s(C_PCI_DATA_WIDTH/32)-1:0]),
         .TXR_META_VALID                (TXR_META_VALID),
         .TXR_META_FDWBE                (TXR_META_FDWBE[`SIG_FBE_W-1:0]),
         .TXR_META_LDWBE                (TXR_META_LDWBE[`SIG_LBE_W-1:0]),
         .TXR_META_ADDR                 (TXR_META_ADDR[`SIG_ADDR_W-1:0]),
         .TXR_META_LENGTH               (TXR_META_LENGTH[`SIG_LEN_W-1:0]),
         .TXR_META_TAG                  (TXR_META_TAG[`SIG_TAG_W-1:0]),
         .TXR_META_TC                   (TXR_META_TC[`SIG_TC_W-1:0]),
         .TXR_META_ATTR                 (TXR_META_ATTR[`SIG_ATTR_W-1:0]),
         .TXR_META_TYPE                 (TXR_META_TYPE[`SIG_TYPE_W-1:0]),
         .TXR_META_EP                   (TXR_META_EP));
    

    txc_engine_ultrascale
        #(
          /*AUTOINSTPARAM*/
          // Parameters
          .C_PCI_DATA_WIDTH             (C_PCI_DATA_WIDTH),
          .C_PIPELINE_INPUT             (C_PIPELINE_INPUT),
          .C_PIPELINE_OUTPUT            (C_PIPELINE_OUTPUT),
          .C_DEPTH_PACKETS              (C_DEPTH_PACKETS),
          .C_MAX_PAYLOAD_DWORDS         (C_MAX_PAYLOAD_DWORDS))
    txc_engine_inst
        (/*AUTOINST*/
         // Outputs
         .S_AXIS_CC_TVALID              (S_AXIS_CC_TVALID),
         .S_AXIS_CC_TLAST               (S_AXIS_CC_TLAST),
         .S_AXIS_CC_TDATA               (S_AXIS_CC_TDATA[C_PCI_DATA_WIDTH-1:0]),
         .S_AXIS_CC_TKEEP               (S_AXIS_CC_TKEEP[(C_PCI_DATA_WIDTH/32)-1:0]),
         .S_AXIS_CC_TUSER               (S_AXIS_CC_TUSER[`SIG_CC_TUSER_W-1:0]),
         .TXC_DATA_READY                (TXC_DATA_READY),
         .TXC_META_READY                (TXC_META_READY),
         // Inputs
         .CLK                           (CLK),
         .RST_IN                        (RST_IN),
         .CONFIG_COMPLETER_ID           (CONFIG_COMPLETER_ID[`SIG_CPLID_W-1:0]),
         .S_AXIS_CC_TREADY              (S_AXIS_CC_TREADY),
         .TXC_DATA_VALID                (TXC_DATA_VALID),
         .TXC_DATA                      (TXC_DATA[C_PCI_DATA_WIDTH-1:0]),
         .TXC_DATA_START_FLAG           (TXC_DATA_START_FLAG),
         .TXC_DATA_START_OFFSET         (TXC_DATA_START_OFFSET[clog2s(C_PCI_DATA_WIDTH/32)-1:0]),
         .TXC_DATA_END_FLAG             (TXC_DATA_END_FLAG),
         .TXC_DATA_END_OFFSET           (TXC_DATA_END_OFFSET[clog2s(C_PCI_DATA_WIDTH/32)-1:0]),
         .TXC_META_VALID                (TXC_META_VALID),
         .TXC_META_FDWBE                (TXC_META_FDWBE[`SIG_FBE_W-1:0]),
         .TXC_META_LDWBE                (TXC_META_LDWBE[`SIG_LBE_W-1:0]),
         .TXC_META_ADDR                 (TXC_META_ADDR[`SIG_LOWADDR_W-1:0]),
         .TXC_META_TYPE                 (TXC_META_TYPE[`SIG_TYPE_W-1:0]),
         .TXC_META_LENGTH               (TXC_META_LENGTH[`SIG_LEN_W-1:0]),
         .TXC_META_BYTE_COUNT           (TXC_META_BYTE_COUNT[`SIG_BYTECNT_W-1:0]),
         .TXC_META_TAG                  (TXC_META_TAG[`SIG_TAG_W-1:0]),
         .TXC_META_REQUESTER_ID         (TXC_META_REQUESTER_ID[`SIG_REQID_W-1:0]),
         .TXC_META_TC                   (TXC_META_TC[`SIG_TC_W-1:0]),
         .TXC_META_ATTR                 (TXC_META_ATTR[`SIG_ATTR_W-1:0]),
         .TXC_META_EP                   (TXC_META_EP));

endmodule
