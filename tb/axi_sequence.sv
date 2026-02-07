// Fixed AXI Sequence
// Key fix: Removed redundant import (already in tb_pkg)

// REMOVED: import uvm_pkg::*;  - Already imported by tb_pkg

class axi_sequence extends uvm_sequence #(axi_transaction);

  `uvm_object_utils(axi_sequence)

  function new(string name = "axi_sequence");
    super.new(name);
  endfunction

  task body();
    axi_transaction tr;

    // Write transaction
    tr = axi_transaction::type_id::create("wr");
    tr.is_write = 1;
    tr.addr = 32'h1000;
    tr.data = 32'hDEADBEEF;
    start_item(tr);
    finish_item(tr);

    // Read transaction
    tr = axi_transaction::type_id::create("rd");
    tr.is_write = 0;
    tr.addr = 32'h1000;
    start_item(tr);
    finish_item(tr);
  endtask

endclass
