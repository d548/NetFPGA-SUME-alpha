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
// Filename:			fifo.v
// Version:				1.00
// Verilog Standard:	Verilog-2001
// Description: Standard 0-delay fifo implementation. Takes WR_DATA on WR_READY
// and WR_VALID. RD_DATA is read on RD_READY and RD_VALID
// Author:				Dustin Richmond (@darichmond)
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "functions.vh"
module fifo 
    #(
      parameter C_WIDTH = 32,   // Data bus width
      parameter C_DEPTH = 1024, // Depth of the FIFO
      parameter C_DELAY = 2
      )
    (
     input                CLK, // Clock
     input                RST, // Sync reset, active high

     input [C_WIDTH-1:0]  WR_DATA, // Write data input
     input                WR_VALID, // Write enable, high active
     output               WR_READY, // ~Full condition

     output [C_WIDTH-1:0] RD_DATA, // Read data output
     input                RD_READY, // Read enable, high active
     output               RD_VALID // ~Empty condition
     );

    // Local parameters
    localparam C_POW2_DEPTH = 2**clog2(C_DEPTH);
    localparam C_DEPTH_WIDTH = clog2s(C_POW2_DEPTH);

    wire [C_DELAY:0]      wDelayTaps;
    wire                  wDelayWrEn;
    wire                  wWrEn;
    wire                  wRdEn;
    wire                  wRdRdy;
    
    wire                  wRdEnInternal;
    wire                  wRdEnExternal;
    wire                  wEmptyNow;
    wire                  wEmptyNext;

    wire                  wOutputEmpty;
    
    wire                  wFullNow;
    wire                  wFullNext;
    
    reg                   rValid;
    reg [C_DEPTH_WIDTH:0] rWrPtr,_rWrPtr;
    reg [C_DEPTH_WIDTH:0] rWrPtrPlus1, _rWrPtrPlus1;
    reg [C_DEPTH_WIDTH:0] rRdPtr,_rRdPtr;
    reg [C_DEPTH_WIDTH:0] rRdPtrPlus1,_rRdPtrPlus1;
    reg                   rFull,_rFull;
    reg                   rEmpty,_rEmpty;

    assign wRdEnInternal = ~wEmptyNow & ~rValid; // Read enable to propogate data to the BRAM output
    assign wRdEnExternal = RD_READY & !rEmpty;   // Read enable to change data on the output
    assign wRdEn = wRdEnInternal | wRdEnExternal;
    assign wRdRdy = RD_READY & rValid; // Read Data already on the output bus

    assign wWrEn = WR_VALID & !rFull;

    assign wEmptyNow = (rRdPtr == rWrPtr); 
    assign wEmptyNext = (wRdEn & ~wWrEn & (rWrPtr == rRdPtrPlus1));

    assign wFullNow = (rRdPtr[C_DEPTH_WIDTH-1:0] == rWrPtr[C_DEPTH_WIDTH-1:0]) & 
                      (rWrPtr[C_DEPTH_WIDTH] != rRdPtr[C_DEPTH_WIDTH]);
    assign wFullNext = wWrEn & ~wRdEn & (rWrPtrPlus1[C_DEPTH_WIDTH-1:0] == rRdPtr[C_DEPTH_WIDTH-1:0]) & 
                       (rWrPtrPlus1[C_DEPTH_WIDTH] != rRdPtr[C_DEPTH_WIDTH]);

    // Calculate empty
    assign RD_VALID = rValid;

    always @ (posedge CLK) begin
        rEmpty <= #1 (RST ? 1'd1 : _rEmpty);
    end

    always @ (*) begin
        _rEmpty = (wEmptyNow & ~wWrEn) | wEmptyNext;
    end

    always @(posedge CLK) begin
        if(RST) begin
            rValid <= #1 0;
        end else if(wRdEn | wRdRdy) begin
            rValid <= #1 ~(wEmptyNow);
        end
    end

    // Write pointer logic.
    always @ (posedge CLK) begin
        if (RST) begin
            rWrPtr <= #1 0;
            rWrPtrPlus1 <= #1 1;
        end else begin
            rWrPtr <= #1 _rWrPtr;
            rWrPtrPlus1 <= #1 _rWrPtrPlus1;
        end
    end

    always @ (*) begin
        if (wWrEn) begin
            _rWrPtr = rWrPtrPlus1;
            _rWrPtrPlus1 = rWrPtrPlus1 + 1'd1;
        end else begin
            _rWrPtr = rWrPtr;
            _rWrPtrPlus1 = rWrPtrPlus1;
        end
    end

    // Read pointer logic.
    always @ (posedge CLK) begin
        if (RST) begin
            rRdPtr <= #1 0;
            rRdPtrPlus1 <= #1 1;
        end else begin
            rRdPtr <= #1 _rRdPtr;
            rRdPtrPlus1 <= #1 _rRdPtrPlus1;
        end
    end

    always @ (*) begin
        if (wRdEn) begin
            _rRdPtr = rRdPtrPlus1;
            _rRdPtrPlus1 = rRdPtrPlus1 + 1'd1;
        end else begin
            _rRdPtr = rRdPtr;
            _rRdPtrPlus1 = rRdPtrPlus1;
        end
    end


    // Calculate full
    assign WR_READY = ~rFull;

    always @ (posedge CLK) begin
        rFull <= #1 (RST ? 1'd0 : _rFull);
    end

    always @ (*) begin
        _rFull = wFullNow | wFullNext;
    end

    // Memory block (synthesis attributes applied to this module will
    // determine the memory option).
    scsdpram
        #(
          .C_WIDTH(C_WIDTH), 
          .C_DEPTH(C_POW2_DEPTH)
          /*AUTOINSTPARAM*/) 
    mem 
        (
         .WR1_EN                        (wWrEn),
         .WR1_ADDR                      (rWrPtr[C_DEPTH_WIDTH-1:0]),
         .WR1_DATA                      (WR_DATA),

         .RD1_EN                        (wRdEn),
         .RD1_ADDR                      (rRdPtr[C_DEPTH_WIDTH-1:0]),
         .RD1_DATA                      (RD_DATA),
         /*AUTOINST*/
         // Inputs
         .CLK                           (CLK));

    shiftreg
        #(
          // Parameters
          .C_DEPTH          (C_DELAY),
          .C_WIDTH          (1'b1)
          /*AUTOINSTPARAM*/)
    shiftreg_wr_delay_inst
        (
         // Outputs
         .RD_DATA                       (wDelayTaps),
         // Inputs
         .RST_IN                        (RST),
         .WR_DATA                       (wWrEn),
         /*AUTOINST*/
         // Inputs
         .CLK                           (CLK));


endmodule

