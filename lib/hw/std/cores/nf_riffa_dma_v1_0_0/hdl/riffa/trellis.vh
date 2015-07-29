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
// Filename:            trellis.vh
// Version:             1.0
// Verilog Standard:    Verilog-2001
// Description:         The trellis.vh file is a header file with many interface
// width definitions for the Trellis stack
// Author:              Dustin Richmond (@darichmond)
//-----------------------------------------------------------------------------
`ifndef __TRELLIS_VH
`define __TRELLIS_VH 1
`include "widths.vh"
`include "types.vh"
`include "functions.vh"

// PCIe Signals
`define SIG_BARDECODE_W `BARDECODE_W
`define SIG_OFFSET_W `OFFSET_W
`define SIG_TC_W `TC_W
`define SIG_ATTR_W `ATTR_W
`define SIG_LEN_W `LEN_W
`define SIG_TD_W `TD_W
`define SIG_TYPE_W `EXT_TYPE_W
`define SIG_FMT_W `FMT_W
`define SIG_FBE_W `FBE_W
`define SIG_LBE_W `LBE_W
`define SIG_TAG_W `TAG_W
`define SIG_REQID_W `REQID_W
`define SIG_ADDR_W `ADDR_W
`define SIG_BYTECNT_W `BYTECNT_W
`define SIG_STAT_W `STAT_W
`define SIG_CPLID_W `CPLID_W
`define SIG_LOWADDR_W `LOWADDR_W

`define SIG_CFGREG_W `PCIE_CONFIGURATION_REGISTER_WIDTH
`define SIG_BUSID_W `PCIE_BUS_ID_WIDTH
`define SIG_DEVID_W `PCIE_DEVICE_ID_WIDTH // Device ID Width
`define SIG_FNID_W `PCIE_FUNCTION_ID_WIDTH // Function Number

`define SIG_LINKWIDTH_W `LINKWIDTH_W
`define SIG_LINKRATE_W `LINKRATE_W
`define SIG_MAXREAD_W `MAXREAD_W
`define SIG_MAXPAYLOAD_W `MAXPAYLOAD_W

`define SIG_FC_CPLD_W 12
`define SIG_FC_CPLH_W 8

// The maximum number of alignment blanks that can be inserted in a packet is 7
`define SIG_NONPAY_W 4
`define SIG_PACKETLEN_W (clog2s(4096/4) + `SIG_NONPAY_W + 1)
`define SIG_ALIGN_W 3
`define SIG_HDRLEN_W 3
`define SIG_MAXHDR_W 128

`endif
