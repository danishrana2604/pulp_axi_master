class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)

  axi_master_driver drv;
  axi_monitor mon;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    $display("[%0t] axi_test::new called", $time);
  endfunction

  function void build_phase(uvm_phase phase);
    $display("[%0t] axi_test::build_phase START", $time);
    super.build_phase(phase);
    drv = axi_master_driver::type_id::create("drv", this);
    mon = axi_monitor::type_id::create("mon", this);
    $display("[%0t] axi_test::build_phase END", $time);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    $display("[%0t] axi_test::end_of_elaboration_phase", $time);
    uvm_root::get().print_topology();
  endfunction

  task run_phase(uvm_phase phase);
    axi_transaction tr;
    
    $display("[%0t] axi_test::run_phase START", $time);
    phase.raise_objection(this);
    $display("[%0t] axi_test: Objection raised", $time);
    
    // Wait for reset
    repeat(5) @(posedge drv.vif.clk);
    
    // Write transaction
    tr = axi_transaction::type_id::create("wr");
    tr.is_write = 1;
    tr.addr = 32'h1000;
    tr.data = 32'hDEADBEEF;
    drv.drive_transaction(tr);
    
    // Read transaction
    tr = axi_transaction::type_id::create("rd");
    tr.is_write = 0;
    tr.addr = 32'h1000;
    drv.drive_transaction(tr);
    
    repeat(10) @(posedge drv.vif.clk);
    
    $display("[%0t] axi_test: Dropping objection", $time);
    phase.drop_objection(this);
    $display("[%0t] axi_test::run_phase END", $time);
  endtask

  function void report_phase(uvm_phase phase);
    $display("[%0t] axi_test::report_phase", $time);
    $display("=== TEST COMPLETED ===");
  endfunction

endclass
