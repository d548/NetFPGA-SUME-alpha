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
// Filename:            riffa.vh
// Version:             1.0
// Verilog Standard:    Verilog-2001
// Description:         The riffa.vh file is a header file that defines
// various RIFFA-specific primitives.
// Author:              Dustin Richmond (@darichmond)
//-----------------------------------------------------------------------------
`ifndef __RIFFA_VH
`define __RIFFA_VH 1
`include "widths.vh"

// User Interface Signals
`define SIG_CHNL_OFFSET_W 31
`define SIG_CHNL_LENGTH_W 32
`define SIG_CHNL_LAST_W 1

// Engine/Channel interface signals
`define SIG_TXRLEN_W 32
`define SIG_OFFLAST_W 32
`define SIG_LAST_W 1
`define SIG_TXDONELEN_W 32
`define SIG_RXDONELEN_W 32
`define SIG_CORESETTINGS_W 32

// Writable addresses
`define ADDR_SGRX_LEN 4'b0000
`define ADDR_SGRX_ADDRLO 4'b0001
`define ADDR_SGRX_ADDRHI 4'b0010
`define ADDR_RX_LEN 4'b0011
`define ADDR_RX_OFFLAST 4'b0100
`define ADDR_SGTX_LEN 4'b0101
`define ADDR_SGTX_ADDRLO 4'b0110
`define ADDR_SGTX_ADDRHI 4'b0111
// Readable Addresses
`define ADDR_TX_LEN 4'b1000
`define ADDR_TX_OFFLAST 4'b1001
`define ADDR_CORESETTINGS 4'b1010
`define ADDR_INTR_VECTOR_0 4'b1011
`define ADDR_INTR_VECTOR_1 4'b1100
`define ADDR_RX_LEN_XFERD 4'b1101
`define ADDR_TX_LEN_XFERD 4'b1110
`define ADDR_FPGA_NAME 4'b1111

`endif
