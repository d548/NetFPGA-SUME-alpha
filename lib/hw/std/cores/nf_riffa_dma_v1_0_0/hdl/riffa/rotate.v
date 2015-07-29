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
// Filename:			rotate.v
// Version:				1.00
// Verilog Standard:	Verilog-2001
// Description:			A simple module to perform to rotate the input data
// Author:				Dustin Richmond (@darichmond)
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "functions.vh"
module rotate
    #(
      parameter C_DIRECTION = "LEFT",
      parameter C_WIDTH = 4
      )
    (
     input [C_WIDTH-1:0]        WR_DATA,
     input [clog2s(C_WIDTH)-1:0] WR_SHIFTAMT,
     output [C_WIDTH-1:0]       RD_DATA
     );

    wire [2*C_WIDTH-1:0]        wPreShiftR;
    wire [2*C_WIDTH-1:0]        wPreShiftL;

    wire [2*C_WIDTH-1:0]        wShiftR;
    wire [2*C_WIDTH-1:0]        wShiftL;

    assign wPreShiftL = {WR_DATA,WR_DATA};
    assign wPreShiftR = {WR_DATA,WR_DATA};

    assign wShiftL = wPreShiftL << WR_SHIFTAMT;
    assign wShiftR = wPreShiftR >> WR_SHIFTAMT;

    generate
        if(C_DIRECTION == "LEFT") begin
            assign RD_DATA = wShiftL[2*C_WIDTH-1:C_WIDTH];
        end else if (C_DIRECTION == "RIGHT") begin
            assign RD_DATA = wShiftR[C_WIDTH-1:0];
        end
    endgenerate
endmodule
