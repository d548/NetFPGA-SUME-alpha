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
//-----------------------------------------------------------------------------
// Filename: tx_data_pipeline.v
// Version: 1.0
// Verilog Standard: Verilog-2001
//
// Description: The tx_data_fifo takes 0-bit aligned packet data and
// puts each DW into one of N FIFOs where N = (C_DATA_WIDTH/32).
// 
// The data interface (TX_DATA) is an interface for N 32-bit FIFOs, where N =
// (C_DATA_WIDTH/32). The START_FLAG signal indicates that the first dword of
// a packet is in FIFO 0 (TX_DATA[31:0]). Each FIFO interface also contains an
// END_FLAG signal in the END_FLAGS bus. When a bit in END_FLAGS bus is asserted,
// its corresponding fifo contains the last dword of data for the current
// packet. START_FLAG, END_FLAG and DATA are all qualified by the VALID signal,
// and read by the READY signal.
// 
// The write interface (WR_TX) differs slightly from the read interface because it
// produces a READY signal and consumes a VALID signal. VALID is asserted when an
// entire packet has been packed into a FIFO. 
//  
// TODO: 
// - Make sure that the synthesis tool is removing the other three start
// flag wires (and modifying the width of the FIFOs)
// 
// Author: Dustin Richmond (@darichmond) 
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "trellis.vh" // Defines the user-facing signal widths.
module tx_data_fifo 
    #(parameter C_DEPTH_PACKETS = 10,
      parameter C_DATA_WIDTH = 128,
      parameter C_PIPELINE_INPUT = 1,
      parameter C_PIPELINE_OUTPUT = 1,
      parameter C_MAX_PAYLOAD = 256 // BYTES
      )
    (
     // Interface: Clocks
     input                          CLK,

     // Interface: Reset
     input                          RST_IN,

     // Interface: WR TX DATA
     input [C_DATA_WIDTH-1:0]       WR_TX_DATA,
     input                          WR_TX_DATA_VALID,
     input                          WR_TX_DATA_START_FLAG,
     input [(C_DATA_WIDTH/32)-1:0]  WR_TX_DATA_WORD_VALID,
     input [(C_DATA_WIDTH/32)-1:0]  WR_TX_DATA_END_FLAGS,
     output                         WR_TX_DATA_READY,

     // Interface: RD TX DATA
     input [(C_DATA_WIDTH/32)-1:0]  RD_TX_DATA_WORD_READY,
     output [C_DATA_WIDTH-1:0]      RD_TX_DATA,
     output                         RD_TX_DATA_START_FLAG,
     output [(C_DATA_WIDTH/32)-1:0] RD_TX_DATA_END_FLAGS,
     output [(C_DATA_WIDTH/32)-1:0] RD_TX_DATA_WORD_VALID,
     output                         RD_TX_DATA_PACKET_VALID
     );
    localparam C_FIFO_OUTPUT_DEPTH = 1;
    localparam C_INPUT_DEPTH = C_PIPELINE_INPUT != 0 ? 1 : 0;
    localparam C_OUTPUT_DEPTH = C_PIPELINE_OUTPUT != 0 ? 1 : 0;
    localparam C_MAXPACKET_LINES = (C_MAX_PAYLOAD*8)/C_DATA_WIDTH;
    localparam C_FIFO_DEPTH = C_MAXPACKET_LINES*C_DEPTH_PACKETS;
    localparam C_FIFO_DATA_WIDTH = 32; 
    localparam C_REGISTER_WIDTH = C_FIFO_DATA_WIDTH + 2;
    localparam C_FIFO_WIDTH = C_FIFO_DATA_WIDTH + 2; // Data, end flag and start flag
    localparam C_NUM_FIFOS = (C_DATA_WIDTH/32);
    genvar                          i;

    wire                            RST;
    
    wire [C_FIFO_DATA_WIDTH-1:0]    wWrTxData[C_NUM_FIFOS-1:0];
    wire [C_NUM_FIFOS-1:0]          wWrTxDataValid;
    wire [C_NUM_FIFOS-1:0]          wWrTxDataReady;
    wire [C_NUM_FIFOS-1:0]          wWrTxDataStartFlags;
    wire [C_NUM_FIFOS-1:0]          wWrTxDataEndFlags;

    wire [C_NUM_FIFOS-1:0]          _wRdTxDataStartFlags;

    wire [C_FIFO_DATA_WIDTH-1:0]    wRdTxData[C_NUM_FIFOS-1:0];
    wire [C_NUM_FIFOS-1:0]          wRdTxDataValid;
    wire [C_NUM_FIFOS-1:0]          wRdTxDataReady;
    wire [C_NUM_FIFOS-1:0]          wRdTxDataStartFlags;
    wire [C_NUM_FIFOS-1:0]          wRdTxDataEndFlags;
    wire                            wRdTxDataPacketValid;
    
    wire                            wWrTxEndFlagValid;
    wire                            wWrTxEndFlagReady;

    wire                            wRdTxEndFlagValid;
    wire                            wRdTxEndFlagReady;

    wire                            wPacketDecrement; 
    wire                            wPacketIncrement;

    reg [clog2(C_DEPTH_PACKETS+1)-1:0] rPacketCounter,_rPacketCounter;

    /*AUTOINPUT*/
    /*AUTOWIRE*/
    ///*AUTOOUTPUT*/

    assign RST = RST_IN;

    assign wWrTxEndFlagValid = (wWrTxDataEndFlags & wWrTxDataValid) != {C_NUM_FIFOS{1'b0}};
    assign wWrTxEndFlagReady = rPacketCounter != C_DEPTH_PACKETS;// Designed a small bit of latency here to help timing...
    assign wPacketIncrement = wWrTxEndFlagValid & wWrTxEndFlagReady;
    assign wPacketDecrement = wRdTxEndFlagValid & wRdTxEndFlagReady;
    
    assign WR_TX_DATA_READY = wWrTxEndFlagReady;

    assign wRdTxEndFlagValid = rPacketCounter != 0;
    assign wRdTxEndFlagReady = (wRdTxDataReady & wRdTxDataEndFlags & wRdTxDataValid) != {C_NUM_FIFOS{1'b0}};
    assign wRdTxDataPacketValid = rPacketCounter != 0;

    assign RD_TX_DATA_START_FLAG = _wRdTxDataStartFlags[0];
    
    always @(*) begin
        _rPacketCounter = rPacketCounter;
        if(wPacketIncrement & wPacketDecrement) begin
            _rPacketCounter = rPacketCounter + 0;
        end else if(wPacketIncrement) begin
            _rPacketCounter = rPacketCounter + 1;
        end else if(wPacketDecrement) begin
            _rPacketCounter = rPacketCounter - 1;
        end
    end // always @ (*)

    always @(posedge CLK) begin
        if(RST_IN) begin
            rPacketCounter <= #1 0;
        end else begin
            rPacketCounter <= #1 _rPacketCounter;
        end
    end

    generate
        for( i = 0 ; i < C_NUM_FIFOS ; i = i + 1 ) begin : gen_regs_fifos
            pipeline
                 #(
                   .C_DEPTH              (C_INPUT_DEPTH),
                   .C_USE_MEMORY         (0),
                   .C_WIDTH              (C_REGISTER_WIDTH)
                   /*AUTOINSTPARAM*/)
            input_pipeline_inst_
                 (
                  // Outputs
                  .WR_DATA_READY         (),
                  .RD_DATA               ({wWrTxData[i], wWrTxDataEndFlags[i],wWrTxDataStartFlags[i]}),
                  .RD_DATA_VALID         (wWrTxDataValid[i]),
                  // Inputs
                  .CLK                   (CLK),
                  .RST_IN                (RST_IN),
                  .WR_DATA               ({WR_TX_DATA[C_FIFO_DATA_WIDTH*i +: C_FIFO_DATA_WIDTH], 
                                           WR_TX_DATA_END_FLAGS[i], (i == 0) ? WR_TX_DATA_START_FLAG: 1'b0}),
                  .WR_DATA_VALID         (WR_TX_DATA_VALID & WR_TX_DATA_WORD_VALID[i]),
                  .RD_DATA_READY         (wWrTxDataReady[i]));

            fifo
                #(
                  // Parameters
                  .C_WIDTH             (C_FIFO_WIDTH),
                  .C_DEPTH             (C_FIFO_DEPTH),
                  .C_DELAY             (0)
                  /*AUTOINSTPARAM*/)
            fifo_inst_
                (
                 // Outputs
                 .RD_DATA              ({wRdTxData[i], wRdTxDataStartFlags[i], wRdTxDataEndFlags[i]}),
                 .WR_READY             (wWrTxDataReady[i]),
                 .RD_VALID             (wRdTxDataValid[i]),
                 // Inputs
                 .WR_DATA              ({wWrTxData[i], wWrTxDataStartFlags[i], wWrTxDataEndFlags[i]}),
                 .WR_VALID             (wWrTxDataValid[i]),
                 .RD_READY             (wRdTxDataReady[i]),
                 /*AUTOINST*/
                 // Inputs
                 .CLK                   (CLK),
                 .RST                   (RST));

            pipeline
                #(
                  .C_DEPTH              (C_FIFO_OUTPUT_DEPTH),
                  .C_USE_MEMORY         (0),
                  .C_WIDTH              (C_FIFO_WIDTH)
                  /*AUTOINSTPARAM*/)
            fifo_pipeline_inst_
                (
                 // Outputs
                 .WR_DATA_READY         (wRdTxDataReady[i]),
                 .RD_DATA               ({RD_TX_DATA[i*32 +: 32],
                                          _wRdTxDataStartFlags[i],
                                          RD_TX_DATA_END_FLAGS[i]}),
                 .RD_DATA_VALID         (RD_TX_DATA_WORD_VALID[i]),
                 // Inputs
                 .WR_DATA               ({wRdTxData[i], 
                                          wRdTxDataStartFlags[i],
                                          wRdTxDataEndFlags[i]}),
                 .WR_DATA_VALID         (wRdTxDataValid[i]),
                 .RD_DATA_READY         (RD_TX_DATA_WORD_READY[i]),
                 /*AUTOINST*/
                 // Inputs
                 .CLK                   (CLK),
                 .RST_IN                (RST_IN));
        end // for ( i = 0 ; i < C_NUM_FIFOS ; i = i + 1 )
    endgenerate
endmodule
// Local Variables:
// verilog-library-directories:("." "../../common/")
// End:


