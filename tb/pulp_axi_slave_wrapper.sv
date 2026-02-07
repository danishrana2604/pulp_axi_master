module pulp_axi_slave_wrapper (
  input  logic clk_i, rst_ni,
  input  logic [31:0] axi_aw_addr_i,
  input  logic [7:0] axi_aw_len_i,
  input  logic [2:0] axi_aw_size_i, axi_aw_prot_i,
  input  logic [1:0] axi_aw_burst_i,
  input  logic axi_aw_valid_i,
  input  logic [3:0] axi_aw_id_i,
  output logic axi_aw_ready_o,
  input  logic [31:0] axi_w_data_i,
  input  logic [3:0] axi_w_strb_i,
  input  logic axi_w_last_i, axi_w_valid_i,
  output logic axi_w_ready_o,
  output logic [1:0] axi_b_resp_o,
  output logic axi_b_valid_o,
  output logic [3:0] axi_b_id_o,
  input  logic axi_b_ready_i,
  input  logic [31:0] axi_ar_addr_i,
  input  logic [7:0] axi_ar_len_i,
  input  logic [2:0] axi_ar_size_i, axi_ar_prot_i,
  input  logic [1:0] axi_ar_burst_i,
  input  logic axi_ar_valid_i,
  input  logic [3:0] axi_ar_id_i,
  output logic axi_ar_ready_o,
  output logic [31:0] axi_r_data_o,
  output logic [1:0] axi_r_resp_o,
  output logic axi_r_last_o, axi_r_valid_o,
  output logic [3:0] axi_r_id_o,
  input  logic axi_r_ready_i
);

  // Simple memory: write data, read it back
  logic [31:0] memory [256];
  logic [31:0] aw_addr_reg, ar_addr_reg;
  logic [7:0] aw_len_reg, ar_len_reg;
  logic [3:0] aw_id_reg, ar_id_reg;
  logic [7:0] w_count, r_count;
  
  typedef enum logic [2:0] {
    W_IDLE, W_DATA, W_RESP,
    R_IDLE, R_DATA
  } state_t;
  
  state_t w_state, r_state;
  
  // Write path
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      w_state <= W_IDLE;
      axi_aw_ready_o <= 1'b1;
      axi_w_ready_o <= 1'b0;
      axi_b_valid_o <= 1'b0;
      w_count <= 0;
    end else begin
      case (w_state)
        W_IDLE: begin
          axi_w_ready_o <= 1'b0;
          if (axi_aw_valid_i && axi_aw_ready_o) begin
            aw_addr_reg <= axi_aw_addr_i;
            aw_len_reg <= axi_aw_len_i;
            aw_id_reg <= axi_aw_id_i;
            axi_aw_ready_o <= 1'b0;
            axi_w_ready_o <= 1'b1;
            w_count <= 0;
            w_state <= W_DATA;
          end
        end
        
        W_DATA: begin
          if (axi_w_valid_i && axi_w_ready_o) begin
            memory[aw_addr_reg[9:2] + w_count] <= axi_w_data_i;
            if (axi_w_last_i) begin
              axi_w_ready_o <= 1'b0;
              axi_b_valid_o <= 1'b1;
              axi_b_id_o <= aw_id_reg;
              axi_b_resp_o <= 2'b00;
              w_state <= W_RESP;
            end else begin
              w_count <= w_count + 1;
            end
          end
        end
        
        W_RESP: begin
          if (axi_b_ready_i) begin
            axi_b_valid_o <= 1'b0;
            axi_aw_ready_o <= 1'b1;
            w_state <= W_IDLE;
          end
        end
      endcase
    end
  end
  
  // Read path
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      r_state <= R_IDLE;
      axi_ar_ready_o <= 1'b1;
      axi_r_valid_o <= 1'b0;
      r_count <= 0;
    end else begin
      case (r_state)
        R_IDLE: begin
          if (axi_ar_valid_i && axi_ar_ready_o) begin
            ar_addr_reg <= axi_ar_addr_i;
            ar_len_reg <= axi_ar_len_i;
            ar_id_reg <= axi_ar_id_i;
            axi_ar_ready_o <= 1'b0;
            r_count <= 0;
            r_state <= R_DATA;
            axi_r_valid_o <= 1'b1;
            axi_r_data_o <= memory[axi_ar_addr_i[9:2]];
            axi_r_id_o <= axi_ar_id_i;
            axi_r_resp_o <= 2'b00;
            axi_r_last_o <= (axi_ar_len_i == 0);
          end
        end
        
        R_DATA: begin
          if (axi_r_ready_i && axi_r_valid_o) begin
            if (axi_r_last_o) begin
              axi_r_valid_o <= 1'b0;
              axi_ar_ready_o <= 1'b1;
              r_state <= R_IDLE;
            end else begin
              r_count <= r_count + 1;
              axi_r_data_o <= memory[ar_addr_reg[9:2] + r_count + 1];
              axi_r_last_o <= (r_count + 1 == ar_len_reg);
            end
          end
        end
      endcase
    end
  end

endmodule
