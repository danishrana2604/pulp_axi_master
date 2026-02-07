module tb_top;

import uvm_pkg::*;
import tb_pkg::*;

  logic clk, rst_n;
  axi_if axi_if_inst();

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  assign axi_if_inst.clk = clk;
  assign axi_if_inst.rst_n = rst_n;

  // PULP AXI Master (axi_from_mem)
  pulp_axi_master_wrapper pulp_master (
    .clk_i(clk), .rst_ni(rst_n),
    .req_valid_i(axi_if_inst.req_valid),
    .req_ready_o(axi_if_inst.req_ready),
    .req_addr_i(axi_if_inst.req_addr),
    .req_we_i(axi_if_inst.req_we),
    .req_wdata_i(axi_if_inst.req_wdata),
    .req_be_i(axi_if_inst.req_be),
    .resp_rdata_o(axi_if_inst.resp_rdata),
    .resp_valid_o(axi_if_inst.resp_valid),
    .axi_aw_addr_o(axi_if_inst.aw_addr),
    .axi_aw_len_o(axi_if_inst.aw_len),
    .axi_aw_size_o(axi_if_inst.aw_size),
    .axi_aw_prot_o(axi_if_inst.aw_prot),
    .axi_aw_burst_o(axi_if_inst.aw_burst),
    .axi_aw_id_o(axi_if_inst.aw_id),
    .axi_aw_valid_o(axi_if_inst.aw_valid),
    .axi_aw_ready_i(axi_if_inst.aw_ready),
    .axi_w_data_o(axi_if_inst.w_data),
    .axi_w_strb_o(axi_if_inst.w_strb),
    .axi_w_last_o(axi_if_inst.w_last),
    .axi_w_valid_o(axi_if_inst.w_valid),
    .axi_w_ready_i(axi_if_inst.w_ready),
    .axi_b_resp_i(axi_if_inst.b_resp),
    .axi_b_id_i(axi_if_inst.b_id),
    .axi_b_valid_i(axi_if_inst.b_valid),
    .axi_b_ready_o(axi_if_inst.b_ready),
    .axi_ar_addr_o(axi_if_inst.ar_addr),
    .axi_ar_len_o(axi_if_inst.ar_len),
    .axi_ar_size_o(axi_if_inst.ar_size),
    .axi_ar_prot_o(axi_if_inst.ar_prot),
    .axi_ar_burst_o(axi_if_inst.ar_burst),
    .axi_ar_id_o(axi_if_inst.ar_id),
    .axi_ar_valid_o(axi_if_inst.ar_valid),
    .axi_ar_ready_i(axi_if_inst.ar_ready),
    .axi_r_data_i(axi_if_inst.r_data),
    .axi_r_resp_i(axi_if_inst.r_resp),
    .r_last_i(axi_if_inst.r_last),
    .axi_r_id_i(axi_if_inst.r_id),
    .axi_r_valid_i(axi_if_inst.r_valid),
    .axi_r_ready_o(axi_if_inst.r_ready)
  );

  // PULP AXI Slave (axi_to_mem)
  pulp_axi_slave_wrapper pulp_slave (
    .clk_i(clk), .rst_ni(rst_n),
    .axi_aw_addr_i(axi_if_inst.aw_addr),
    .axi_aw_len_i(axi_if_inst.aw_len),
    .axi_aw_size_i(axi_if_inst.aw_size),
    .axi_aw_prot_i(axi_if_inst.aw_prot),
    .axi_aw_burst_i(axi_if_inst.aw_burst),
    .axi_aw_id_i(axi_if_inst.aw_id),
    .axi_aw_valid_i(axi_if_inst.aw_valid),
    .axi_aw_ready_o(axi_if_inst.aw_ready),
    .axi_w_data_i(axi_if_inst.w_data),
    .axi_w_strb_i(axi_if_inst.w_strb),
    .axi_w_last_i(axi_if_inst.w_last),
    .axi_w_valid_i(axi_if_inst.w_valid),
    .axi_w_ready_o(axi_if_inst.w_ready),
    .axi_b_resp_o(axi_if_inst.b_resp),
    .axi_b_id_o(axi_if_inst.b_id),
    .axi_b_valid_o(axi_if_inst.b_valid),
    .axi_b_ready_i(axi_if_inst.b_ready),
    .axi_ar_addr_i(axi_if_inst.ar_addr),
    .axi_ar_len_i(axi_if_inst.ar_len),
    .axi_ar_size_i(axi_if_inst.ar_size),
    .axi_ar_prot_i(axi_if_inst.ar_prot),
    .axi_ar_burst_i(axi_if_inst.ar_burst),
    .axi_ar_id_i(axi_if_inst.ar_id),
    .axi_ar_valid_i(axi_if_inst.ar_valid),
    .axi_ar_ready_o(axi_if_inst.ar_ready),
    .axi_r_data_o(axi_if_inst.r_data),
    .axi_r_resp_o(axi_if_inst.r_resp),
    .axi_r_last_o(axi_if_inst.r_last),
    .axi_r_id_o(axi_if_inst.r_id),
    .axi_r_valid_o(axi_if_inst.r_valid),
    .axi_r_ready_i(axi_if_inst.r_ready)
  );

  initial begin
    $display("[%0t] TB_TOP: PULP axi_from_mem → axi_to_mem validation", $time);
    uvm_config_db#(axi_vif_t)::set(null, "*", "vif", axi_if_inst);
    run_test();
  end

  initial begin
    #100000;
    $display("[%0t] ERROR: Simulation timeout!", $time);
    $finish;
  end

  debug_signals dbg();
endmodule
