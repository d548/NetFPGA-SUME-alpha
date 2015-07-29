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
// Filename: tx_hdr_fifo.v
// Version: 1.0
// Verilog Standard: Verilog-2001
//
// Description: The tx_hdr_fifo module implements a simple fifo for a packet
// (WR_TX_HDR) header and three metadata signals: WR_TX_HDR_ABLANKS,
// WR_TX_HDR_LEN, WR_TX_HDR_NOPAYLOAD. NOPAYLOAD indicates that the header is not
// followed by a payload. HDR_LEN indicates the length of the header in
// dwords. The ABLANKS signal indicates how many dwords should be inserted between
// the header and payload.
// 
// The intended use for this module is between the interface specific tx formatter
// (TXC or TXR) and the alignment pipeline, in parallel with the tx_data_pipeline
// which contains a fifo for payloads.
// 
// Author: Dustin Richmond (@darichmond) 
// Co-Authors:
//----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "trellis.vh" // Defines the user-facing signal widths.
module tx_hdr_fifo
    #(parameter C_DEPTH_PACKETS = 10,
      parameter C_MAX_HDR_WIDTH = 128,
      parameter C_PIPELINE_OUTPUT = 1,
      parameter C_PIPELINE_INPUT = 1,
      parameter C_VENDOR = "ALTERA"
      )
    (
     // Interface: Clocks
     input                          CLK,

     // Interface: Reset
     input                          RST_IN,

     // Interface: WR_TX_HDR
     input                          WR_TX_HDR_VALID,
     input [(C_MAX_HDR_WIDTH)-1:0]  WR_TX_HDR,
     input [`SIG_LEN_W-1:0]         WR_TX_HDR_PAYLOAD_LEN,
     input [`SIG_NONPAY_W-1:0]      WR_TX_HDR_NONPAY_LEN,
     input [`SIG_PACKETLEN_W-1:0]   WR_TX_HDR_PACKET_LEN,
     input                          WR_TX_HDR_NOPAYLOAD,
     output                         WR_TX_HDR_READY,

     // Interface: RD_TX_HDR
     output                         RD_TX_HDR_VALID,
     output [(C_MAX_HDR_WIDTH)-1:0] RD_TX_HDR,
     output [`SIG_LEN_W-1:0]        RD_TX_HDR_PAYLOAD_LEN,
     output [`SIG_NONPAY_W-1:0]     RD_TX_HDR_NONPAY_LEN,
     output [`SIG_PACKETLEN_W-1:0]  RD_TX_HDR_PACKET_LEN,
     output                         RD_TX_HDR_NOPAYLOAD,
     input                          RD_TX_HDR_READY
     );

    // Size of the header, plus the three metadata signals
    localparam C_WIDTH = (C_MAX_HDR_WIDTH) + `SIG_NONPAY_W + `SIG_PACKETLEN_W + 1 + `SIG_LEN_W;

    wire                            RST;

    wire                            wWrTxHdrReady;
    wire                            wWrTxHdrValid;
    wire [(C_MAX_HDR_WIDTH)-1:0]    wWrTxHdr;
    wire [`SIG_NONPAY_W-1:0]        wWrTxHdrNonpayLen;
    wire [`SIG_PACKETLEN_W-1:0]     wWrTxHdrPacketLen;
    wire [`SIG_LEN_W-1:0]           wWrTxHdrPayloadLen; 
    wire                            wWrTxHdrNoPayload;

    wire                            wRdTxHdrReady;
    wire                            wRdTxHdrValid;
    wire [C_MAX_HDR_WIDTH-1:0]      wRdTxHdr;
    wire [`SIG_NONPAY_W-1:0]        wRdTxHdrNonpayLen;
    wire [`SIG_PACKETLEN_W-1:0]     wRdTxHdrPacketLen;
    wire [`SIG_LEN_W-1:0]           wRdTxHdrPayloadLen; 
    wire                            wRdTxHdrNoPayload;

    assign RST = RST_IN;

    pipeline
        #(
          .C_DEPTH              (C_PIPELINE_INPUT?1:0),
          .C_USE_MEMORY         (0),
          /*AUTOINSTPARAM*/
          // Parameters
          .C_WIDTH                      (C_WIDTH))
    input_pipeline_inst
        (
         // Outputs
         .WR_DATA_READY         (WR_TX_HDR_READY),
         .RD_DATA               ({wWrTxHdr,wWrTxHdrNonpayLen,wWrTxHdrPacketLen,wWrTxHdrPayloadLen,wWrTxHdrNoPayload}),
         .RD_DATA_VALID         (wWrTxHdrValid),
         // Inputs
         .WR_DATA               ({WR_TX_HDR,WR_TX_HDR_NONPAY_LEN,WR_TX_HDR_PACKET_LEN,WR_TX_HDR_PAYLOAD_LEN,WR_TX_HDR_NOPAYLOAD}),
         .WR_DATA_VALID         (WR_TX_HDR_VALID),
         .RD_DATA_READY         (wWrTxHdrReady),
         /*AUTOINST*/
         // Inputs
         .CLK                           (CLK),
         .RST_IN                        (RST_IN));

    fifo
        #(
          // Parameters
          .C_DELAY             (0),
          /*AUTOINSTPARAM*/
          // Parameters
          .C_WIDTH                      (C_WIDTH),
          .C_DEPTH                      (C_DEPTH_PACKETS))
    fifo_inst
        (
         // Outputs
         .RD_DATA              ({wRdTxHdr,wRdTxHdrNonpayLen,wRdTxHdrPacketLen,wRdTxHdrPayloadLen,wRdTxHdrNoPayload}),
         .WR_READY             (wWrTxHdrReady),
         .RD_VALID             (wRdTxHdrValid),
         // Inputs
         .WR_DATA              ({wWrTxHdr,wWrTxHdrNonpayLen,wWrTxHdrPacketLen,wWrTxHdrPayloadLen,wWrTxHdrNoPayload}),
         .WR_VALID             (wWrTxHdrValid),
         .RD_READY             (wRdTxHdrReady),
         /*AUTOINST*/
         // Inputs
         .CLK                           (CLK),
         .RST                           (RST));

    pipeline
        #(
          .C_DEPTH              (C_PIPELINE_OUTPUT?1:0),
          .C_USE_MEMORY         (0),
          /*AUTOINSTPARAM*/
          // Parameters
          .C_WIDTH                      (C_WIDTH))
    output_pipeline_inst
        (
         // Outputs
         .WR_DATA_READY         (wRdTxHdrReady),
         .RD_DATA               ({RD_TX_HDR,RD_TX_HDR_NONPAY_LEN,RD_TX_HDR_PACKET_LEN,RD_TX_HDR_PAYLOAD_LEN,RD_TX_HDR_NOPAYLOAD}),
         .RD_DATA_VALID         (RD_TX_HDR_VALID),
         // Inputs
         .WR_DATA              ({wRdTxHdr,wRdTxHdrNonpayLen,wRdTxHdrPacketLen,wRdTxHdrPayloadLen,wRdTxHdrNoPayload}),
         .WR_DATA_VALID         (wRdTxHdrValid),
         .RD_DATA_READY         (RD_TX_HDR_READY),
         /*AUTOINST*/
         // Inputs
         .CLK                           (CLK),
         .RST_IN                        (RST_IN));
endmodule
// Local Variables:
// verilog-library-directories:("." "../../common/")
// End:
