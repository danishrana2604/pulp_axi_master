interface axi_if;
  logic clk, rst_n;
  
  // Request interface (Driver -> Master)
  logic req_valid, req_ready;
  logic [31:0] req_addr, req_wdata, resp_rdata;
  logic req_we, resp_valid;
  logic [3:0] req_be;
  
  // AXI Write Address
  logic [31:0] aw_addr;
  logic [7:0] aw_len;
  logic [2:0] aw_size, aw_prot;
  logic [1:0] aw_burst;
  logic aw_valid, aw_ready;
  logic [3:0] aw_id;
  
  // AXI Write Data
  logic [31:0] w_data;
  logic [3:0] w_strb;
  logic w_last, w_valid, w_ready;
  
  // AXI Write Response
  logic [1:0] b_resp;
  logic b_valid, b_ready;
  logic [3:0] b_id;
  
  // AXI Read Address
  logic [31:0] ar_addr;
  logic [7:0] ar_len;
  logic [2:0] ar_size, ar_prot;
  logic [1:0] ar_burst;
  logic ar_valid, ar_ready;
  logic [3:0] ar_id;
  
  // AXI Read Data
  logic [31:0] r_data;
  logic [1:0] r_resp;
  logic r_last, r_valid, r_ready;
  logic [3:0] r_id;
endinterface
