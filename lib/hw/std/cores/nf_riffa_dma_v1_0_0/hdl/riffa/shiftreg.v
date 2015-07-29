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

 Description: A simple parameterized shift register. 
 
 Notes: Any modifications to this file should meet the conditions set
 forth in the "Trellis Style Guide"
 
 Author: Dustin Richmond (@darichmond) 
 Co-Authors:
 */
`timescale 1ns/1ns
module shiftreg
    #(
      parameter C_DEPTH=10,
      parameter C_WIDTH=32
      )
    (
     input                            CLK,
     input                            RST_IN,
     input [C_WIDTH-1:0]              WR_DATA,
     output [(C_DEPTH+1)*C_WIDTH-1:0] RD_DATA
     );

    // Start Flag Shift Register. Data enables are derived from the 
    // taps on this shift register.

    wire [(C_DEPTH+1)*C_WIDTH-1:0]    wDataShift;
    reg [C_WIDTH-1:0]                 rDataShift[C_DEPTH:0];

    assign wDataShift[(C_WIDTH*0)+:C_WIDTH] = WR_DATA;
    always @(posedge CLK) begin
        rDataShift[0] <= WR_DATA;
    end
    
    genvar                                     i;
    generate
        for (i = 1 ; i <= C_DEPTH; i = i + 1) begin : gen_sr_registers
            assign wDataShift[(C_WIDTH*i)+:C_WIDTH] = rDataShift[i-1];
            always @(posedge CLK) begin
                rDataShift[i] <= rDataShift[i-1];
            end
        end
    endgenerate
    assign RD_DATA = wDataShift;
    
endmodule
