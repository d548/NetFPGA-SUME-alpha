//
// Copyright (c) 2015 University of Cambridge All rights reserved.
//
// This software was developed by the University of Cambridge Computer
// Laboratory under EPSRC INTERNET Project EP/H040536/1, National Science
// Foundation under Grant No. CNS-0855268, and Defense Advanced Research
// Projects Agency (DARPA) and Air Force Research Laboratory (AFRL), under
// contract FA8750-11-C-0249.
//
// @NETFPGA_LICENSE_HEADER_START@
//
// Licensed to NetFPGA C.I.C. (NetFPGA) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  NetFPGA licenses this
// file to you under the NetFPGA Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://netfpga-cic.org
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @NETFPGA_LICENSE_HEADER_END@


`timescale 1ns/1ps
// wrapper module for 10G interface with shared logic.

module nf_10g_interface_shared_block #(
    parameter 				C_M_AXIS_DATA_WIDTH	     = 256,
    parameter 				C_S_AXIS_DATA_WIDTH	     = 256,
    parameter 				C_AXIS_DATA_INTERNAL_WIDTH = 64,
    parameter 				C_M_AXIS_TUSER_WIDTH	= 128,
    parameter 				C_S_AXIS_TUSER_WIDTH    = 128	
)(
	// Shared logic
	output 					                 areset_clk156_out,
	output 					                 clk156_out,
	output 					                 gtrxreset_out,
  	output 					                 gttxreset_out,
  	output 					                 qplllock_out,
	output 					                 qplloutclk_out,
	output 					                 qplloutrefclk_out,
	output 					                 txuserrdy_out,
	output 					                 txusrclk_out,
	output 					                 txusrclk2_out,
	output 					                 reset_counter_done_out,

	//Clocks and resets
	input 					                 core_clk,	
	input [0:0]				                 core_resetn,
	input 					                 reset,
	input 					                 refclk_n,
  	input 					                 refclk_p,

	//SFP Controls and indications
	output 					                 resetdone,
	input 					                 tx_fault,
	input 					                 tx_abs,
	output 					                 tx_disable,

	//MAC configuration & status
	input [79:0] 						mac_tx_configuration_vector,
	input [79:0] 						mac_rx_configuration_vector,
	input [535:0]						pcs_pma_configuration_vector,
	output reg [7:0] 					pcspma_status,
	output reg [1:0] 					mac_status_vector,
	output reg [447:0]					pcs_pma_status_vector,



	//Interface number
	input [7:0] 				             interface_number,

	//AXI Interface 10GE -> DMA
	output [C_M_AXIS_DATA_WIDTH-1:0]	     m_axis_tdata,
	output [(C_M_AXIS_DATA_WIDTH/8)-1:0]	 m_axis_tkeep,
	output [4*C_M_AXIS_TUSER_WIDTH-1:0]	     m_axis_tuser,
   	output 					                 m_axis_tvalid,
	output 				                     m_axis_tlast,
	input 					                 m_axis_tready,

	//AXI Interface DMA -> 10GE
	input [C_S_AXIS_DATA_WIDTH-1:0]		     s_axis_tdata,
  	input [(C_S_AXIS_DATA_WIDTH/8)-1:0]	     s_axis_tkeep,
  	input 					                 s_axis_tlast,
   	input [4*C_S_AXIS_TUSER_WIDTH-1:0]	     s_axis_tuser,
  	input 					                 s_axis_tvalid,
	output 					                 s_axis_tready,

	 //Serial I/O from/to transceiver
	input 					                 rxn,
  	input 					                 rxp,
 	output 					                 txn,
  	output 					                 txp	
);

wire [C_AXIS_DATA_INTERNAL_WIDTH-1:0]	     dwidth1_axis_tdata;
wire 				     dwidth1_axis_tvalid;
wire 			             dwidth1_axis_tready;
wire [C_M_AXIS_TUSER_WIDTH-1:0]	     dwidth1_axis_tuser;
wire [(C_AXIS_DATA_INTERNAL_WIDTH/8)-1:0]     dwidth1_axis_tkeep;
wire                                 dwidth1_axis_tlast;

wire                                 signal_detect;
wire                                 areset_clk156_out_n;

wire [C_AXIS_DATA_INTERNAL_WIDTH-1:0]		     s_axis_tx_tdata;
wire [(C_AXIS_DATA_INTERNAL_WIDTH/8)-1:0]	     s_axis_tx_tkeep;
wire 					     s_axis_tx_tlast;
wire [C_S_AXIS_TUSER_WIDTH-1:0]		     s_axis_tx_tuser;
wire 					     s_axis_tx_tvalid;
wire 					     s_axis_tx_tready;

wire [C_AXIS_DATA_INTERNAL_WIDTH-1:0]	     m_axis_rx_tdata;
wire [(C_AXIS_DATA_INTERNAL_WIDTH/8)-1:0]    m_axis_rx_tkeep;
wire 					     m_axis_rx_tlast;
wire [C_M_AXIS_TUSER_WIDTH-1:0]					     m_axis_rx_tuser;
wire 					     m_axis_rx_tvalid;
wire 					     m_axis_rx_tready;

wire [C_AXIS_DATA_INTERNAL_WIDTH-1:0]		metadata_s_axis_tdata;
wire [(C_AXIS_DATA_INTERNAL_WIDTH/8)-1:0]	metadata_s_axis_tkeep;
wire 					     metadata_s_axis_tlast;
wire [C_M_AXIS_TUSER_WIDTH-1:0]	             metadata_s_axis_tuser;
wire 					     metadata_s_axis_tvalid;
wire 					     metadata_s_axis_tready;

wire [C_AXIS_DATA_INTERNAL_WIDTH-1:0]		metadata_m_axis_tdata;
wire [(C_AXIS_DATA_INTERNAL_WIDTH/8)-1:0]	metadata_m_axis_tkeep;
wire 					     metadata_m_axis_tlast;
wire [C_M_AXIS_TUSER_WIDTH-1:0]	             metadata_m_axis_tuser;
wire 					     metadata_m_axis_tvalid;
wire 					     metadata_m_axis_tready;


wire stat_fifo_empty;
wire stat_fifo_rden;
wire [29:0] stat_fifo_din;

wire [7:0] pcspma_status_internal;
wire [1:0] mac_status_vector_internal;
wire [447:0] pcs_pma_status_vector_internal;
wire [457:0] status_vector_internal;

wire [7 : 0] tx_ifg_delay;
wire [15 : 0] s_axis_pause_tdata;
wire s_axis_pause_tvalid;
wire sim_speedup_control;

wire [25:0] tx_statistics_vector;
wire [29:0] rx_statistics_vector;
wire [31:0] axis_data_count;
wire [31:0] axis_wr_data_count;
wire [31:0] axis_rd_data_count;


assign sim_speedup_control = 1'b0;
assign s_axis_pause_tvalid = 1'b0;
assign s_axis_pause_tdata = 16'b0;
assign tx_ifg_delay = 8'b0;


assign status_vector_internal = {pcs_pma_status_vector_internal,mac_status_vector_internal,pcspma_status_internal};

axi_10g_ethernet_shared axi_10g_ethernet_i (
  .tx_axis_aresetn(areset_clk156_out_n),                            
  .rx_axis_aresetn(areset_clk156_out_n),                            
  .tx_ifg_delay(tx_ifg_delay),                                  
  .dclk(clk156_out),                                            
  .txp(txp),                                                    
  .txn(txn),                                                    
  .rxp(rxp),                                                    
  .rxn(rxn),                                                    
  .signal_detect(signal_detect),                                
  .tx_fault(tx_fault),                                          
  .tx_disable(tx_disable),                                      
  .pcspma_status(pcspma_status_internal),                                
  .sim_speedup_control(sim_speedup_control),                    
  .mac_tx_configuration_vector(mac_tx_configuration_vector),    
  .mac_rx_configuration_vector(mac_rx_configuration_vector),    
  .mac_status_vector(mac_status_vector_internal),                        
  .pcs_pma_configuration_vector(pcs_pma_configuration_vector),  
  .pcs_pma_status_vector(pcs_pma_status_vector_internal),                
  .txusrclk_out(txusrclk_out),                                  
  .txusrclk2_out(txusrclk2_out),                                
  .gttxreset_out(gttxreset_out),                                
  .gtrxreset_out(gtrxreset_out),                                
  .txuserrdy_out(txuserrdy_out),                                
  .clk156_out(clk156_out),                                      
  .areset_clk156_out(areset_clk156_out),                       
  .resetdone(resetdone),                                        
  .reset_counter_done_out(reset_counter_done_out),              
  .qplllock_out(qplllock_out),                                  
  .qplloutclk_out(qplloutclk_out),                              
  .qplloutrefclk_out(qplloutrefclk_out),                        
  .refclk_p(refclk_p),                                          
  .refclk_n(refclk_n),                                          
  .reset(reset),                                                
  .s_axis_tx_tdata(s_axis_tx_tdata),                            
  .s_axis_tx_tkeep(s_axis_tx_tkeep),                            
  .s_axis_tx_tlast(s_axis_tx_tlast),                            
  .s_axis_tx_tready(s_axis_tx_tready),                          
  .s_axis_tx_tuser(s_axis_tx_tuser[0]),                            
  .s_axis_tx_tvalid(s_axis_tx_tvalid),                          
  .s_axis_pause_tdata(s_axis_pause_tdata),                      
  .s_axis_pause_tvalid(s_axis_pause_tvalid),                    
  .m_axis_rx_tdata(m_axis_rx_tdata),                            
  .m_axis_rx_tkeep(m_axis_rx_tkeep),                            
  .m_axis_rx_tlast(m_axis_rx_tlast),                            
  .m_axis_rx_tuser(m_axis_rx_tuser[0]),                            
  .m_axis_rx_tvalid(m_axis_rx_tvalid),                          
  .tx_statistics_valid(tx_statistics_valid),                    
  .tx_statistics_vector(tx_statistics_vector),                  
  .rx_statistics_valid(rx_statistics_valid),                    
  .rx_statistics_vector(rx_statistics_vector)                  
);

 assign m_axis_rx_tuser[127:1] = 127'h0;

inverter_0 areset_inverter_shared_i (
  .Op1(areset_clk156_out),  
  .Res(areset_clk156_out_n)  
);

axis_data_fifo_0 axis_data_fifo_shared_i0 (
  .s_axis_aresetn(areset_clk156_out_n),          
  .m_axis_aresetn(core_resetn),          
  .s_axis_aclk(clk156_out),                
  .m_axis_tvalid(metadata_s_axis_tvalid),            
  .m_axis_tready(metadata_s_axis_tready),            
  .m_axis_tdata(metadata_s_axis_tdata),              
  .m_axis_tuser(metadata_s_axis_tuser),              
  .m_axis_tkeep(metadata_s_axis_tkeep),             
  .m_axis_tlast(metadata_s_axis_tlast),
  .m_axis_aclk(core_clk),                
  .s_axis_tvalid(m_axis_rx_tvalid),          
  .s_axis_tready(m_axis_rx_tready),           
  .s_axis_tdata(m_axis_rx_tdata),              
  .s_axis_tuser(m_axis_rx_tuser),              
  .s_axis_tkeep(m_axis_rx_tkeep),	      
  .s_axis_tlast(m_axis_rx_tlast),
  .axis_data_count(axis_data_count),        
  .axis_wr_data_count(axis_wr_data_count),  
  .axis_rd_data_count(axis_rd_data_count)  
);

axis_data_fifo_0 axis_data_fifo_shared_i1 (
  .s_axis_aresetn(core_resetn),          
  .m_axis_aresetn(areset_clk156_out_n),          
  .s_axis_aclk(core_clk),                
  .s_axis_tvalid(dwidth1_axis_tvalid),            
  .s_axis_tready(dwidth1_axis_tready),            
  .s_axis_tdata(dwidth1_axis_tdata),             
  .s_axis_tuser(dwidth1_axis_tuser),             
  .s_axis_tkeep(dwidth1_axis_tkeep ),
  .s_axis_tlast(dwidth1_axis_tlast),
  .m_axis_aclk(clk156_out),                
  .m_axis_tvalid(s_axis_tx_tvalid),            
  .m_axis_tready(s_axis_tx_tready),           
  .m_axis_tdata(s_axis_tx_tdata),              
  .m_axis_tuser(s_axis_tx_tuser),             
  .m_axis_tkeep(s_axis_tx_tkeep),              
  .m_axis_tlast(s_axis_tx_tlast), 
  .axis_data_count(axis_data_count),        
  .axis_wr_data_count(axis_wr_data_count),  
  .axis_rd_data_count(axis_rd_data_count)  
);

axis_dwidth_converter_0 axis_dwidth_converter_shared_i0 (
  .aclk(core_clk),                    
  .aresetn(core_resetn),              
  .s_axis_tvalid(metadata_m_axis_tvalid),  
  .s_axis_tready(metadata_m_axis_tready),  
  .s_axis_tdata(metadata_m_axis_tdata),    
  .s_axis_tkeep(metadata_m_axis_tkeep),   
  .s_axis_tlast(metadata_m_axis_tlast),   
  .s_axis_tuser(metadata_m_axis_tuser),   
  .m_axis_tvalid(m_axis_tvalid),  
  .m_axis_tready(m_axis_tready),  
  .m_axis_tdata(m_axis_tdata),    
  .m_axis_tkeep(m_axis_tkeep),    
  .m_axis_tlast(m_axis_tlast),    
  .m_axis_tuser(m_axis_tuser)    
);

axis_dwidth_converter_1 axis_dwidth_converter_shared_i1 (
  .aclk(core_clk),                   
  .aresetn(core_resetn),              
  .s_axis_tvalid(s_axis_tvalid), 
  .s_axis_tready(s_axis_tready),  
  .s_axis_tdata(s_axis_tdata),    
  .s_axis_tkeep(s_axis_tkeep),
  .s_axis_tlast(s_axis_tlast),
  .s_axis_tuser(s_axis_tuser),
  .m_axis_tvalid(dwidth1_axis_tvalid), 
  .m_axis_tready(dwidth1_axis_tready),  
  .m_axis_tuser(dwidth1_axis_tuser), 
  .m_axis_tdata(dwidth1_axis_tdata),    
  .m_axis_tkeep(dwidth1_axis_tkeep),
  .m_axis_tlast(dwidth1_axis_tlast)
);

fifo_generator_0 fifo_generator_shared_i (
  .wr_clk(clk156_out),  
  .rd_clk(core_clk),  
  .din(rx_statistics_vector),        
  .wr_en(rx_statistics_valid),  
  .rd_en(stat_fifo_rden),    
  .dout(stat_fifo_din),      
  .full(full),      
  .empty(stat_fifo_empty)    
);


wire status_full, status_empty;
wire [457:0] status_vector_out;
 
fifo_generator_status fifo_generator_shared_status_i (
  .wr_clk(clk156_out),  
  .rd_clk(core_clk),  
  .din(status_vector_internal),        
  .wr_en(!status_full),    
  .rd_en(!status_empty),   
  .dout(status_vector_out),      
  .full(status_full),      
  .empty(status_empty)    
);

always@(posedge core_clk)
if (!core_resetn)
begin
 pcs_pma_status_vector <= #1 'b0;
 mac_status_vector <=#1 'b0;
 pcspma_status <=#1 'b0;
end
else
begin
      pcs_pma_status_vector <= #1 status_empty ? pcs_pma_status_vector : status_vector_out[457:10];
      mac_status_vector <=#1 status_empty ? mac_status_vector : status_vector_out[9:8];
      pcspma_status <=#1 status_empty ? pcspma_status : status_vector_out[7:0];
end

inverter_0 tx_abs_inverter_shared_i (
  .Op1(tx_abs),  
  .Res(signal_detect)  
);

nf_10g_metadata nf_10g_metadata_shared_i (
  .axis_aclk(core_clk),              
  .axis_resetn(core_resetn),          
  .m_axis_tdata(metadata_m_axis_tdata),        
  .m_axis_tkeep(metadata_m_axis_tkeep),       
  .m_axis_tuser(metadata_m_axis_tuser),        
  .m_axis_tvalid(metadata_m_axis_tvalid),      
  .m_axis_tready(metadata_m_axis_tready),      
  .m_axis_tlast(metadata_m_axis_tlast),        
  .s_axis_tdata(metadata_s_axis_tdata),       
  .s_axis_tkeep(metadata_s_axis_tkeep),       
  .s_axis_tuser(metadata_s_axis_tuser),        
  .s_axis_tvalid(metadata_s_axis_tvalid),     
  .s_axis_tready(metadata_s_axis_tready),      
  .s_axis_tlast(metadata_s_axis_tlast),       
  .stat_fifo_empty(stat_fifo_empty),  
  .stat_fifo_din(stat_fifo_din),     
  .stat_fifo_rden(stat_fifo_rden),    
  .src_port_num(interface_number)        
);



endmodule
