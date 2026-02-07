package tb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef virtual axi_if axi_vif_t;

  `include "axi_transaction.sv"
  `include "axi_sequence.sv"
  `include "axi_master_driver.sv"
  `include "axi_monitor.sv"
  `include "axi_test.sv"
endpackage
