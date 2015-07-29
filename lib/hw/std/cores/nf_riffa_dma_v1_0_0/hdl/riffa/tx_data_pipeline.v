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
// Filename: tx_data_pipeline
// Version: 1.0
// Verilog Standard: Verilog-2001
//
// Description: The TX Data pipeline module takes arbitrarily 32-bit aligned data
// from the WR_TX_DATA interface and shifts the data so that it is 0-bit
// aligned. This data is presented on a set of N fifos, where N =
// (C_DATA_WIDTH/32). Each fifo provides it's own VALID signal and is
// controlled by a READY signal. Each fifo also provides an independent DATA bus
// and additional END_FLAG signal which inidicates that the dword provided in this
// fifo is the last dword in the current payload. The START_FLAG signal indicates
// that the dword at index N = 0 is the start of a new packet.
// 
// The TX Data Pipeline is built from two modules: tx_data_shift.v and
// tx_data_fifo.v. See these modules for more information.
// 
// Author: Dustin Richmond (@darichmond) 
//----------------------------------------------------------------------------
`include "trellis.vh" // Defines the user-facing signal widths.
module tx_data_pipeline
    #(
      parameter C_DATA_WIDTH = 128,
      parameter C_PIPELINE_INPUT = 1,
      parameter C_PIPELINE_OUTPUT = 1,
      parameter C_MAX_PAYLOAD = 256,
      parameter C_DEPTH_PACKETS = 10,
      parameter C_VENDOR = "ALTERA"
      )
    (
     // Interface: Clocks
     input                               CLK,
     // Interface: Resets
     input                               RST_IN,

     // Interface: WR TX DATA
     input                               WR_TX_DATA_VALID,
     input [C_DATA_WIDTH-1:0]            WR_TX_DATA,
     input                               WR_TX_DATA_START_FLAG,
     input [clog2s(C_DATA_WIDTH/32)-1:0] WR_TX_DATA_START_OFFSET,
     input                               WR_TX_DATA_END_FLAG,
     input [clog2s(C_DATA_WIDTH/32)-1:0] WR_TX_DATA_END_OFFSET,
     output                              WR_TX_DATA_READY,

     // Interface: TX DATA FIFOS
     input [(C_DATA_WIDTH/32)-1:0]       RD_TX_DATA_WORD_READY,
     output [C_DATA_WIDTH-1:0]           RD_TX_DATA,
     output [(C_DATA_WIDTH/32)-1:0]      RD_TX_DATA_END_FLAGS,
     output                              RD_TX_DATA_START_FLAG,
     output [(C_DATA_WIDTH/32)-1:0]      RD_TX_DATA_WORD_VALID
     );
    
    wire                                 wRdTxDataValid;
    wire                                 wRdTxDataReady;
    wire                                 wRdTxDataStartFlag;
    wire [C_DATA_WIDTH-1:0]              wRdTxData;
    wire [(C_DATA_WIDTH/32)-1:0]         wRdTxDataEndFlags;
    wire [(C_DATA_WIDTH/32)-1:0]         wRdTxDataWordValid;

    /*AUTOWIRE*/
    /*AUTOINPUT*/
    /*AUTOOUTPUT*/

    tx_data_shift
        #(
          .C_PIPELINE_OUTPUT            (0),
          .C_PIPELINE_INPUT             (C_PIPELINE_INPUT),
          /*AUTOINSTPARAM*/
          // Parameters
          .C_DATA_WIDTH                 (C_DATA_WIDTH),
          .C_VENDOR                     (C_VENDOR))
    tx_shift_inst
        (
         // Outputs
         .WR_TX_DATA_READY              (WR_TX_DATA_READY),
         .RD_TX_DATA                    (wRdTxData),
         .RD_TX_DATA_VALID              (wRdTxDataValid),
         .RD_TX_DATA_START_FLAG         (wRdTxDataStartFlag),
         .RD_TX_DATA_WORD_VALID         (wRdTxDataWordValid),
         .RD_TX_DATA_END_FLAGS          (wRdTxDataEndFlags),
         // Inputs
         .WR_TX_DATA                    (WR_TX_DATA[C_DATA_WIDTH-1:0]),
         .WR_TX_DATA_VALID              (WR_TX_DATA_VALID),
         .WR_TX_DATA_START_FLAG         (WR_TX_DATA_START_FLAG),
         .WR_TX_DATA_START_OFFSET       (WR_TX_DATA_START_OFFSET[clog2s(C_DATA_WIDTH/32)-1:0]),
         .WR_TX_DATA_END_FLAG           (WR_TX_DATA_END_FLAG),
         .WR_TX_DATA_END_OFFSET         (WR_TX_DATA_END_OFFSET[clog2s(C_DATA_WIDTH/32)-1:0]),
         .RD_TX_DATA_READY              (wRdTxDataReady),
         /*AUTOINST*/
         // Inputs
         .CLK                           (CLK),
         .RST_IN                        (RST_IN));

    // TX Data Fifo
    tx_data_fifo
        #(
          .C_PIPELINE_OUTPUT            (C_PIPELINE_OUTPUT),
          .C_PIPELINE_INPUT             (1),
          .C_DEPTH_PACKETS              (C_DEPTH_PACKETS),
          .C_MAX_PAYLOAD                (C_MAX_PAYLOAD),
          /*AUTOINSTPARAM*/
          // Parameters
          .C_DATA_WIDTH             (C_DATA_WIDTH))
    txdf_inst
        (
         // Outputs
         .WR_TX_DATA_READY            (wRdTxDataReady),
         .RD_TX_DATA                  (RD_TX_DATA[C_DATA_WIDTH-1:0]),
         .RD_TX_DATA_START_FLAG       (RD_TX_DATA_START_FLAG),
         .RD_TX_DATA_WORD_VALID       (RD_TX_DATA_WORD_VALID[(C_DATA_WIDTH/32)-1:0]),
         .RD_TX_DATA_END_FLAGS        (RD_TX_DATA_END_FLAGS[(C_DATA_WIDTH/32)-1:0]),
         // Inputs
         .WR_TX_DATA                  (wRdTxData),
         .WR_TX_DATA_VALID            (wRdTxDataValid),
         .WR_TX_DATA_START_FLAG       (wRdTxDataStartFlag),
         .WR_TX_DATA_WORD_VALID       (wRdTxDataWordValid),
         .WR_TX_DATA_END_FLAGS        (wRdTxDataEndFlags),
         .RD_TX_DATA_WORD_READY       (RD_TX_DATA_WORD_READY),
         /*AUTOINST*/
         // Inputs
         .CLK                           (CLK),
         .RST_IN                        (RST_IN));

endmodule
// Local Variables:
// verilog-library-directories:("." "../../../common/")
// End:
