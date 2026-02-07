module debug_signals;
  initial begin
    forever begin
      @(posedge tb_top.clk);
      if (tb_top.axi_if_inst.aw_valid || tb_top.axi_if_inst.ar_valid) begin
        $display("[%0t] DEBUG: aw_valid=%0d aw_ready=%0d ar_valid=%0d ar_ready=%0d", 
                 $time, tb_top.axi_if_inst.aw_valid, tb_top.axi_if_inst.aw_ready,
                 tb_top.axi_if_inst.ar_valid, tb_top.axi_if_inst.ar_ready);
        $display("[%0t] DEBUG: w_valid=%0d w_ready=%0d b_valid=%0d b_ready=%0d",
                 $time, tb_top.axi_if_inst.w_valid, tb_top.axi_if_inst.w_ready,
                 tb_top.axi_if_inst.b_valid, tb_top.axi_if_inst.b_ready);
        $display("[%0t] DEBUG: r_valid=%0d r_ready=%0d resp_valid=%0d",
                 $time, tb_top.axi_if_inst.r_valid, tb_top.axi_if_inst.r_ready,
                 tb_top.axi_if_inst.resp_valid);
      end
      
      if (tb_top.axi_if_inst.b_ready || tb_top.axi_if_inst.b_valid) begin
        $display("[%0t] B-Channel: b_valid=%0d b_ready=%0d resp_valid=%0d", 
                 $time, tb_top.axi_if_inst.b_valid, 
                 tb_top.axi_if_inst.b_ready, tb_top.axi_if_inst.resp_valid);
      end
    end
  end
endmodule
