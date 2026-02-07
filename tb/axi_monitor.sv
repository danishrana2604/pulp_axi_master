// Fixed AXI Monitor
// Key fixes:
// 1. Removed redundant imports (already in tb_pkg)
// 2. Proper null pointer handling
// 3. Separate state tracking for write and read transactions

// REMOVED: import uvm_pkg::*;  - Already imported by tb_pkg
// REMOVED: import tb_pkg::*;   - This file IS PART OF tb_pkg

class axi_monitor extends uvm_monitor;

  `uvm_component_utils(axi_monitor)

  axi_vif_t vif;
  uvm_analysis_port #(axi_transaction) ap;

  // State tracking for proper transaction correlation
  axi_transaction write_tr;  // Pending write transaction
  axi_transaction read_tr;   // Pending read transaction

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // FIX: Split the config_db get and check into separate statements
    // This avoids "write to virtual interface in if condition" error in Verilator
    void'(uvm_config_db#(axi_vif_t)::get(this, "", "vif", vif));
    if (vif == null)
      `uvm_fatal("MON", "AXI interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    write_tr = null;
    read_tr  = null;

    fork
      monitor_write_transactions();
      monitor_read_transactions();
    join
  endtask

  // Monitor WRITE transactions (AW + W + B channels)
  task monitor_write_transactions();
    forever begin
      @(posedge vif.clk);

      // Capture Write Address
      if (vif.aw_valid && vif.aw_ready) begin
        if (write_tr != null) begin
          `uvm_warning("MON", "Previous write transaction not completed")
        end
        write_tr = axi_transaction::type_id::create("write_tr");
        write_tr.addr     = vif.aw_addr;
        write_tr.is_write = 1;
        `uvm_info("MON", $sformatf("Captured WRITE ADDR: 0x%0h", vif.aw_addr), UVM_MEDIUM)
      end

      // Capture Write Data
      if (vif.w_valid && vif.w_ready) begin
        if (write_tr != null) begin
          write_tr.data = vif.w_data;
          `uvm_info("MON", $sformatf("Captured WRITE DATA: 0x%0h", vif.w_data), UVM_MEDIUM)
          
          // Transaction complete when W handshake occurs
          ap.write(write_tr);
          `uvm_info("MON", "Write transaction sent to analysis port", UVM_MEDIUM)
          write_tr = null;
        end else begin
          `uvm_warning("MON", "Write data without address")
        end
      end
    end
  endtask

  // Monitor READ transactions (AR + R channels)
  task monitor_read_transactions();
    forever begin
      @(posedge vif.clk);

      // Capture Read Address
      if (vif.ar_valid && vif.ar_ready) begin
        if (read_tr != null) begin
          `uvm_warning("MON", "Previous read transaction not completed")
        end
        read_tr = axi_transaction::type_id::create("read_tr");
        read_tr.addr     = vif.ar_addr;
        read_tr.is_write = 0;
        `uvm_info("MON", $sformatf("Captured READ ADDR: 0x%0h", vif.ar_addr), UVM_MEDIUM)
      end

      // Capture Read Data
      if (vif.r_valid && vif.r_ready) begin
        if (read_tr != null) begin
          read_tr.data = vif.r_data;
          `uvm_info("MON", $sformatf("Captured READ DATA: 0x%0h", vif.r_data), UVM_MEDIUM)
          
          // Transaction complete when R handshake occurs
          ap.write(read_tr);
          `uvm_info("MON", "Read transaction sent to analysis port", UVM_MEDIUM)
          read_tr = null;
        end else begin
          `uvm_warning("MON", "Read data without address")
        end
      end
    end
  endtask

endclass
