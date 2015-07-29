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
// Filename:			counter.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description: A simple up-counter. The maximum value is the largest expected
// value. The counter will not pass the SAT_VALUE. If the SAT_VALUE > MAX_VALUE,
// the counter will roll over and never stop. On RST_IN, the counter
// synchronously resets to the RST_VALUE
// Author:				Dustin Richmond (@darichmond)
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "functions.vh"
module counter
    #(parameter C_MAX_VALUE = 10,
      parameter C_SAT_VALUE = 10,
      parameter C_RST_VALUE = 0)
    (
     input                              CLK,
     input                              RST_IN,

     input                              ENABLE,
     output [clog2s(C_MAX_VALUE+1)-1:0] VALUE
     );
    wire                                wEnable;
    reg [clog2s(C_MAX_VALUE+1)-1:0]     wCtrValue;
    reg [clog2s(C_MAX_VALUE+1)-1:0]     rCtrValue;
    /* verilator lint_off WIDTH */
    assign wEnable = ENABLE & (C_SAT_VALUE > rCtrValue);
    /* verilator lint_on WIDTH */
    assign VALUE = rCtrValue;
    always @(posedge CLK) begin
        if(RST_IN) begin
            rCtrValue <= C_RST_VALUE;
        end else if(wEnable) begin
            rCtrValue <= rCtrValue + 1;
        end
    end
endmodule
