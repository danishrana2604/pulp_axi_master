// Fixed AXI Transaction
// Key fix: Removed redundant import (already in tb_pkg)

// REMOVED: import uvm_pkg::*;  - Already imported by tb_pkg

class axi_transaction extends uvm_sequence_item;
  `uvm_object_utils(axi_transaction)

  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit        is_write;

  function new(string name = "axi_transaction");
    super.new(name);
  endfunction

endclass
