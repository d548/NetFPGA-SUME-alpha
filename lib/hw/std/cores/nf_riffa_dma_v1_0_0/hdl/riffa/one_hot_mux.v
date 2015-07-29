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
// Filename:			one_hot_mux.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description:			A mux module, where the output select is a one-hot bus
// Author:				Dustin Richmond
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "functions.vh"
module one_hot_mux
    #(parameter C_DATA_WIDTH = 1,
      parameter C_SELECT_WIDTH = 2,
      parameter C_AGGREGATE_WIDTH = C_SELECT_WIDTH*C_DATA_WIDTH
      )
    (
     input [C_SELECT_WIDTH-1:0]    ONE_HOT_SELECT,
     input [C_AGGREGATE_WIDTH-1:0] ONE_HOT_INPUTS,
     output [C_DATA_WIDTH-1:0]     ONE_HOT_OUTPUT);

    genvar                         i;

    wire [C_DATA_WIDTH-1:0]        wOneHotInputs[(1<<C_SELECT_WIDTH):1];
    reg [C_DATA_WIDTH-1:0]         _rOneHotOutput;

    assign ONE_HOT_OUTPUT = _rOneHotOutput;
    generate
        for( i = 0 ; i < C_SELECT_WIDTH; i = i + 1 ) begin : gen_input_array
            assign wOneHotInputs[(1<<i)] = ONE_HOT_INPUTS[C_DATA_WIDTH*i +: C_DATA_WIDTH];
        end
        if(C_SELECT_WIDTH == 1) begin
            always @(*) begin
                _rOneHotOutput = wOneHotInputs[1];
            end
        end else if(C_SELECT_WIDTH == 2) begin
            always @(*) begin
                case(ONE_HOT_SELECT)
                    2'b01: _rOneHotOutput = wOneHotInputs[1];
                    2'b10: _rOneHotOutput = wOneHotInputs[2];
                    default:_rOneHotOutput = wOneHotInputs[1];
                endcase // case (ONE_HOT_SELECT)
            end
        end else if( C_SELECT_WIDTH == 4) begin
            always @(*) begin
                case(ONE_HOT_SELECT)
                    4'b0001: _rOneHotOutput = wOneHotInputs[1];
                    4'b0010: _rOneHotOutput = wOneHotInputs[2];
                    4'b0100: _rOneHotOutput = wOneHotInputs[4];
                    4'b1000: _rOneHotOutput = wOneHotInputs[8];
                    default:_rOneHotOutput = wOneHotInputs[1];
                endcase // case (ONE_HOT_SELECT)
            end
        end else if( C_SELECT_WIDTH == 8) begin
            always @(*) begin
                case(ONE_HOT_SELECT)
                    8'b00000001: _rOneHotOutput = wOneHotInputs[1];
                    8'b00000010: _rOneHotOutput = wOneHotInputs[2];
                    8'b00000100: _rOneHotOutput = wOneHotInputs[4];
                    8'b00001000: _rOneHotOutput = wOneHotInputs[8];
                    8'b00010000: _rOneHotOutput = wOneHotInputs[16];
                    8'b00100000: _rOneHotOutput = wOneHotInputs[32];
                    8'b01000000: _rOneHotOutput = wOneHotInputs[64];
                    8'b10000000: _rOneHotOutput = wOneHotInputs[128];
                    default:_rOneHotOutput = wOneHotInputs[1];
                endcase // case (ONE_HOT_SELECT)
            end
        end 
    endgenerate
endmodule
