class axi_master_driver extends uvm_component;
  `uvm_component_utils(axi_master_driver)
  axi_vif_t vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    void'(uvm_config_db#(axi_vif_t)::get(this, "", "vif", vif));
    if (vif == null) `uvm_fatal("DRV", "AXI interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    vif.req_valid <= 0;
    vif.req_addr  <= 0;
    vif.req_we    <= 0;
    vif.req_wdata <= 0;
    vif.req_be    <= 0;
  endtask

  task drive_transaction(axi_transaction tr);
    $display("[%0t] DRIVER: Sending %s request addr=0x%0h", 
             $time, tr.is_write ? "WRITE" : "READ", tr.addr);
    
    @(posedge vif.clk);
    vif.req_valid <= 1;
    vif.req_addr  <= tr.addr;
    vif.req_we    <= tr.is_write;
    vif.req_wdata <= tr.data;
    vif.req_be    <= 4'hF;
    
    @(posedge vif.clk);
    while (!vif.req_ready) @(posedge vif.clk);
    
    vif.req_valid <= 0;
    $display("[%0t] DRIVER: Request accepted, waiting for response", $time);
    
    // Wait for resp_valid from PULP master
    while (!vif.resp_valid) @(posedge vif.clk);
    
    if (!tr.is_write) begin
      $display("[%0t] DRIVER: READ complete, data=0x%0h", $time, vif.resp_rdata);
    end else begin
      $display("[%0t] DRIVER: WRITE complete", $time);
    end
    
    @(posedge vif.clk);
  endtask
endclass
