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
/*
 Filename: shiftreg.v
 Version: 1.0
 Verilog Standard: Verilog-2001

 Description: A simple, single clock, simple dual port (SCSDP) ram
 
 Notes: Any modifications to this file should meet the conditions set
 forth in the "Trellis Style Guide"
 
 Author: Dustin Richmond (@darichmond) 
 Co-Authors:
 */
`timescale 1ns/1ns
`include "functions.vh"
module scsdpram
    #(
      parameter C_WIDTH = 32,
      parameter C_DEPTH = 1024
      )
    (
     input                       CLK,

     input                       RD1_EN,
     input [clog2s(C_DEPTH)-1:0] RD1_ADDR,
     output [C_WIDTH-1:0]        RD1_DATA,

     input                       WR1_EN,
     input [clog2s(C_DEPTH)-1:0] WR1_ADDR,
     input [C_WIDTH-1:0]         WR1_DATA
     );

    reg [C_WIDTH-1:0]            rMemory [C_DEPTH-1:0];
    reg [C_WIDTH-1:0]            rDataOut;   

    assign RD1_DATA = rDataOut;

    always @(posedge CLK) begin
        if (WR1_EN) begin
            rMemory[WR1_ADDR] <= #1 WR1_DATA;
        end
        if(RD1_EN) begin
            rDataOut <= #1 rMemory[RD1_ADDR];
        end
    end   
endmodule
