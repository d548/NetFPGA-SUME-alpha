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
`include "functions.vh"
module offset_to_mask
    #(parameter C_MASK_SWAP = 1,
      parameter C_MASK_WIDTH = 4)
    (
     input                            OFFSET_ENABLE,
     input [clog2s(C_MASK_WIDTH)-1:0] OFFSET,
     output [C_MASK_WIDTH-1:0]        MASK
     );

    reg [7:0]                         _rMask,_rMaskSwap; 
    wire [3:0]                        wSelect;
    assign wSelect = {OFFSET_ENABLE,{{(3-clog2s(C_MASK_WIDTH)){1'b0}},OFFSET}};
    assign MASK = (C_MASK_SWAP)? _rMaskSwap[7 -: C_MASK_WIDTH]: _rMask[C_MASK_WIDTH-1:0];
    always @(*) begin
        _rMask = 0;
        _rMaskSwap = 0;
        /* verilator lint_off CASEX */
        casex(wSelect)
            default: begin
                _rMask = 8'b1111_1111;
                _rMaskSwap = 8'b1111_1111;
            end
            4'b1000: begin
                _rMask = 8'b0000_0001;
                _rMaskSwap = 8'b1111_1111;
            end
            4'b1001: begin
                _rMask = 8'b0000_0011;
                _rMaskSwap = 8'b0111_1111;
            end
            4'b1010: begin
                _rMask = 8'b0000_0111;
                _rMaskSwap = 8'b0011_1111;
            end
            4'b1011: begin
                _rMask = 8'b0000_1111;
                _rMaskSwap = 8'b0001_1111;
            end
            4'b1100: begin
                _rMask = 8'b0001_1111;
                _rMaskSwap = 8'b0000_1111;
            end
            4'b1101: begin
                _rMask = 8'b0011_1111;
                _rMaskSwap = 8'b0000_0111;
            end
            4'b1110: begin
                _rMask = 8'b0111_1111;
                _rMaskSwap = 8'b0000_0011;
            end
            4'b1111: begin
                _rMask = 8'b1111_1111;
                _rMaskSwap = 8'b0000_0001;
            end
        endcase // casez ({OFFSET_MASK,OFFSET})

        /* verilator lint_on CASEX */
    end
endmodule
