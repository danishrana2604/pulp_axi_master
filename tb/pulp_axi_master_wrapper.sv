module pulp_axi_master_wrapper (
  input  logic clk_i, rst_ni,
  input  logic req_valid_i, req_we_i,
  input  logic [31:0] req_addr_i, req_wdata_i,
  input  logic [3:0] req_be_i,
  output logic req_ready_o, resp_valid_o,
  output logic [31:0] resp_rdata_o,
  
  // Full AXI outputs
  output logic [31:0] axi_aw_addr_o,
  output logic [7:0] axi_aw_len_o,
  output logic [2:0] axi_aw_size_o, axi_aw_prot_o,
  output logic [1:0] axi_aw_burst_o,
  output logic axi_aw_valid_o,
  output logic [3:0] axi_aw_id_o,
  input  logic axi_aw_ready_i,
  
  output logic [31:0] axi_w_data_o,
  output logic [3:0] axi_w_strb_o,
  output logic axi_w_last_o, axi_w_valid_o,
  input  logic axi_w_ready_i,
  
  input  logic [1:0] axi_b_resp_i,
  input  logic axi_b_valid_i,
  input  logic [3:0] axi_b_id_i,
  output logic axi_b_ready_o,
  
  output logic [31:0] axi_ar_addr_o,
  output logic [7:0] axi_ar_len_o,
  output logic [2:0] axi_ar_size_o, axi_ar_prot_o,
  output logic [1:0] axi_ar_burst_o,
  output logic axi_ar_valid_o,
  output logic [3:0] axi_ar_id_o,
  input  logic axi_ar_ready_i,
  
  input  logic [31:0] axi_r_data_i,
  input  logic [1:0] axi_r_resp_i,
  input  logic r_last_i, axi_r_valid_i,
  input  logic [3:0] axi_r_id_i,
  output logic axi_r_ready_o
);

  import axi_pkg::*;
  `include "axi/typedef.svh"
  
  `AXI_TYPEDEF_AW_CHAN_T(aw_t, logic[31:0], logic[3:0], logic[0:0])
  `AXI_TYPEDEF_W_CHAN_T(w_t, logic[31:0], logic[3:0], logic[0:0])
  `AXI_TYPEDEF_B_CHAN_T(b_t, logic[3:0], logic[0:0])
  `AXI_TYPEDEF_AR_CHAN_T(ar_t, logic[31:0], logic[3:0], logic[0:0])
  `AXI_TYPEDEF_R_CHAN_T(r_t, logic[31:0], logic[3:0], logic[0:0])
  `AXI_TYPEDEF_REQ_T(req_t, aw_t, w_t, ar_t)
  `AXI_TYPEDEF_RESP_T(rsp_t, b_t, r_t)

  req_t axi_req;
  rsp_t axi_rsp;

  axi_from_mem #(
    .MemAddrWidth(32), .AxiAddrWidth(32), .DataWidth(32),
    .MaxRequests(4), .AxiProt(3'b000),
    .axi_req_t(req_t), .axi_rsp_t(rsp_t)
  ) i_axi_from_mem (
    .clk_i, .rst_ni,
    .mem_req_i(req_valid_i), .mem_addr_i(req_addr_i),
    .mem_we_i(req_we_i), .mem_wdata_i(req_wdata_i),
    .mem_be_i(req_be_i), .mem_gnt_o(req_ready_o),
    .mem_rsp_valid_o(resp_valid_o), .mem_rsp_rdata_o(resp_rdata_o),
    .mem_rsp_error_o(),
    .slv_aw_cache_i(4'b0011), .slv_ar_cache_i(4'b0011),
    .axi_req_o(axi_req), .axi_rsp_i(axi_rsp)
  );

  assign axi_aw_addr_o = axi_req.aw.addr;
  assign axi_aw_len_o = axi_req.aw.len;
  assign axi_aw_size_o = axi_req.aw.size;
  assign axi_aw_burst_o = axi_req.aw.burst;
  assign axi_aw_prot_o = axi_req.aw.prot;
  assign axi_aw_id_o = axi_req.aw.id;
  assign axi_aw_valid_o = axi_req.aw_valid;
  
  assign axi_w_data_o = axi_req.w.data;
  assign axi_w_strb_o = axi_req.w.strb;
  assign axi_w_last_o = axi_req.w.last;
  assign axi_w_valid_o = axi_req.w_valid;
  assign axi_b_ready_o = axi_req.b_ready;
  
  assign axi_ar_addr_o = axi_req.ar.addr;
  assign axi_ar_len_o = axi_req.ar.len;
  assign axi_ar_size_o = axi_req.ar.size;
  assign axi_ar_burst_o = axi_req.ar.burst;
  assign axi_ar_prot_o = axi_req.ar.prot;
  assign axi_ar_id_o = axi_req.ar.id;
  assign axi_ar_valid_o = axi_req.ar_valid;
  assign axi_r_ready_o = axi_req.r_ready;
  
  assign axi_rsp.aw_ready = axi_aw_ready_i;
  assign axi_rsp.w_ready = axi_w_ready_i;
  assign axi_rsp.b.id = axi_b_id_i;
  assign axi_rsp.b.resp = axi_b_resp_i;
  assign axi_rsp.b_valid = axi_b_valid_i;
  assign axi_rsp.ar_ready = axi_ar_ready_i;
  assign axi_rsp.r.id = axi_r_id_i;
  assign axi_rsp.r.data = axi_r_data_i;
  assign axi_rsp.r.resp = axi_r_resp_i;
  assign axi_rsp.r.last = r_last_i;
  assign axi_rsp.r_valid = axi_r_valid_i;

endmodule
