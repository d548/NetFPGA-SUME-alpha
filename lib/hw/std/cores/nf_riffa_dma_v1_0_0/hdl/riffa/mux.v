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
// Filename:			mux.v
// Version:				1.00.a
// Verilog Standard:	Verilog-2001
// Description:			A simple multiplexer
// Author:				Dustin Richmond (@darichmond)
// TODO:                Remove C_CLOG_NUM_INPUTS
//-----------------------------------------------------------------------------
`timescale 1ns/1ns
`include "functions.vh"
module mux
    #(
      parameter C_NUM_INPUTS = 4,
      parameter C_CLOG_NUM_INPUTS = 2,
      parameter C_WIDTH = 32,
      parameter C_MUX_TYPE = "SELECT"
      )
    (
     input [(C_NUM_INPUTS)*C_WIDTH-1:0] MUX_INPUTS,
     input [C_CLOG_NUM_INPUTS-1:0]      MUX_SELECT,
     output [C_WIDTH-1:0]               MUX_OUTPUT
     );
    generate
        if(C_MUX_TYPE == "SELECT") begin
            mux_select
                #(/*AUTOINSTPARAM*/
                  // Parameters
                  .C_NUM_INPUTS             (C_NUM_INPUTS),
                  .C_CLOG_NUM_INPUTS        (C_CLOG_NUM_INPUTS),
                  .C_WIDTH                  (C_WIDTH))
            mux_select_inst
                (/*AUTOINST*/
                 // Outputs
                 .MUX_OUTPUT            (MUX_OUTPUT[C_WIDTH-1:0]),
                 // Inputs
                 .MUX_INPUTS            (MUX_INPUTS[(C_NUM_INPUTS)*C_WIDTH-1:0]),
                 .MUX_SELECT            (MUX_SELECT[C_CLOG_NUM_INPUTS-1:0]));
        end else if (C_MUX_TYPE == "SHIFT") begin
            mux_shift
                #(/*AUTOINSTPARAM*/
                  // Parameters
                  .C_NUM_INPUTS             (C_NUM_INPUTS),
                  .C_CLOG_NUM_INPUTS        (C_CLOG_NUM_INPUTS),
                  .C_WIDTH                  (C_WIDTH))
            mux_shift_inst
                (/*AUTOINST*/
                 // Outputs
                 .MUX_OUTPUT            (MUX_OUTPUT[C_WIDTH-1:0]),
                 // Inputs
                 .MUX_INPUTS            (MUX_INPUTS[(C_NUM_INPUTS)*C_WIDTH-1:0]),
                 .MUX_SELECT            (MUX_SELECT[C_CLOG_NUM_INPUTS-1:0]));
        end
    endgenerate
endmodule

module mux_select
    #(
      parameter C_NUM_INPUTS = 4,
      parameter C_CLOG_NUM_INPUTS = 2,
      parameter C_WIDTH = 32
      )
    (
     input [(C_NUM_INPUTS)*C_WIDTH-1:0] MUX_INPUTS,
     input [C_CLOG_NUM_INPUTS-1:0]      MUX_SELECT,
     output [C_WIDTH-1:0]               MUX_OUTPUT
     );
    genvar                              i;
    wire [C_WIDTH-1:0]                  wMuxInputs[C_NUM_INPUTS-1:0];
    assign MUX_OUTPUT = wMuxInputs[MUX_SELECT];
    generate
        for (i = 0; i < C_NUM_INPUTS ; i = i + 1) begin : gen_muxInputs_array
            assign wMuxInputs[i] = MUX_INPUTS[i*C_WIDTH +: C_WIDTH];
        end
    endgenerate
endmodule

module mux_shift
    #(
      parameter C_NUM_INPUTS = 4,
      parameter C_CLOG_NUM_INPUTS = 2,
      parameter C_WIDTH = 32
      )
    (
     input [(C_NUM_INPUTS)*C_WIDTH-1:0] MUX_INPUTS,
     input [C_CLOG_NUM_INPUTS-1:0]      MUX_SELECT,
     output [C_WIDTH-1:0]               MUX_OUTPUT
     );
    genvar                              i;
    wire [C_WIDTH*C_NUM_INPUTS-1:0]     wMuxInputs;
    assign wMuxInputs = MUX_INPUTS >> MUX_SELECT;   
    assign MUX_OUTPUT = wMuxInputs[C_WIDTH-1:0];
endmodule
