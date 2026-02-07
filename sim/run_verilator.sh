#!/bin/bash
# =============================================================================
# Fixed run script for UVM with Verilator
# Updated to work with pulp_axi_master directory structure
# =============================================================================

# Antmicro's UVM library
export UVM_HOME="/mnt/d/avm/current-patches-deprecated-api/src"

# Usage information
usage() {
  echo ""
  echo "Usage:   $(basename "$0") TESTNAME [-b(ugpoint)] [-h(elp)] "
  echo "Example: $(basename "$0") axi_test"
}

help() {
  usage
  echo ""
  echo "  - run specified TESTNAME"
  echo ""
  echo "Options:"
  echo "  -b(ugpoint)       - Generate sv-bugpoint-input.sv"
  echo "  -h(elp)           - print this message"
  echo ""
}

# Default values
OPT_TESTNAME="undefined"
OPT_BUGPOINT=0

# Decode command-line options
while [ $# -gt 0 ]; do
  opt=${1/#--/-}
  case "$opt" in
    -b*)      OPT_BUGPOINT=1;;
    -h*)      help; exit 0;;
    -*)       usage ; echo "Error: unknown option/argument $1" ; exit 1;;
    *test*)   OPT_TESTNAME=$1;;
  esac
  shift
done

if [ "$OPT_TESTNAME" = "undefined" ]; then
  usage >&2
  echo "Error: test name must be specified (e.g., axi_test)"
  exit 1
fi

# Process bugpoint option
if [ $OPT_BUGPOINT == 1 ]; then
  ARG_BUGPOINT="> sv-bugpoint-input.sv"
  ARG_VERILATOR="-E -P --cc"
else
  ARG_BUGPOINT=""
  ARG_VERILATOR="--binary --build --cc"
fi

# Check UVM_HOME
if [[ -z "${UVM_HOME}" ]]; then
  echo "ERROR: Please set UVM_HOME environment variable"
  exit 1
else
  echo "Using UVM_HOME: $UVM_HOME"
fi

# Determine script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Set TB_DIR - adjust this based on where your .sv files are located
# If script is in sim/, tb files are in ../tb/
if [ -d "$SCRIPT_DIR/../tb" ]; then
  TB_DIR="$SCRIPT_DIR/../tb"
# If script is in project root, tb files are in ./tb/
elif [ -d "$SCRIPT_DIR/tb" ]; then
  TB_DIR="$SCRIPT_DIR/tb"
# If script is in sim/ and tb files are also in sim/
elif [ -d "$SCRIPT_DIR" ]; then
  TB_DIR="$SCRIPT_DIR"
else
  echo "ERROR: Cannot find testbench directory"
  exit 1
fi

echo "Testbench directory: $TB_DIR"

# Check for sim_main.cpp
if [ -f "$SCRIPT_DIR/sim_main.cpp" ]; then
  SIM_MAIN="$SCRIPT_DIR/sim_main.cpp"
elif [ -f "$TB_DIR/sim_main.cpp" ]; then
  SIM_MAIN="$TB_DIR/sim_main.cpp"
else
  echo "ERROR: sim_main.cpp not found!"
  echo "Please ensure sim_main.cpp is in the same directory as this script"
  exit 1
fi

echo "Using sim_main.cpp: $SIM_MAIN"

# Verify all required files exist
REQUIRED_FILES=(
  "axi_if.sv"
  "pulp_axi_master_wrapper.sv"
  "pulp_axi_slave_wrapper.sv" \
  "debug_signals.sv"
  "tb_pkg.sv"
  "tb_top.sv"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$TB_DIR/$file" ]; then
    echo "ERROR: Required file not found: $TB_DIR/$file"
    exit 1
  fi
done

# Disabled warnings (from UVM class library)
DISABLED_WARNINGS="-Wno-DECLFILENAME \
                   -Wno-CONSTRAINTIGN \
                   -Wno-MISINDENT \
                   -Wno-VARHIDDEN \
                   -Wno-WIDTHTRUNC \
                   -Wno-CASTCONST \
                   -Wno-WIDTHEXPAND \
                   -Wno-UNDRIVEN \
                   -Wno-UNUSEDSIGNAL \
                   -Wno-UNUSEDPARAM \
                   -Wno-ZERODLY \
                   -Wno-SYMRSVDWORD \
                   -Wno-CASEINCOMPLETE \
                   -Wno-SIDEEFFECT \
                   -Wno-fatal \
                   -Wno-REALCVT"

echo "=================================="
echo "Compiling with Verilator..."
echo "Test: $OPT_TESTNAME"
echo "=================================="

# Compile with Verilator
# CRITICAL: File order matters!
# 1. UVM package first
# 2. Interface definitions
# 3. DUT/slave modules
# 4. Package with UVM components
# 5. Top module
# 6. C++ main file

verilator \
  -sv \
  -O1 \
  -j 4 \
  $ARG_VERILATOR \
  --exe \
  --Mdir "$SCRIPT_DIR/verilator_obj_dir" \
  --error-limit 10 \
  -Wall \
  $DISABLED_WARNINGS \
  +define+UVM_REPORT_DISABLE_FILE_LINE \
  +define+UVM_NO_DPI \
  +incdir+"$UVM_HOME" \
  +incdir+"$TB_DIR" \
  +incdir+"$TB_DIR/common_cells" \
  +incdir+"$TB_DIR/axi" \
  "$UVM_HOME/uvm_pkg.sv" \
  "$TB_DIR/axi_if.sv" \
  "$TB_DIR/axi_pkg.sv" \
  "$TB_DIR/fifo_v3.sv" \
  "$TB_DIR/stream_fifo.sv" \
  "$TB_DIR/shift_reg.sv" \
  "$TB_DIR/shift_reg_gated.sv" \
  "$TB_DIR/counter.sv" \
  "$TB_DIR/delta_counter.sv" \
  "$TB_DIR/axi_from_mem.sv" \
  "$TB_DIR/pulp_axi_master_wrapper.sv" \
  "$TB_DIR/pulp_axi_slave_wrapper.sv" \
  "$TB_DIR/debug_signals.sv" \
  "$TB_DIR/tb_pkg.sv" \
  "$TB_DIR/tb_top.sv" \
  $ARG_BUGPOINT

if [ $? -ne 0 ]; then
  echo "=================================="
  echo "ERROR: Compilation failed!"
  echo "=================================="
  exit 1
fi

if [ $OPT_BUGPOINT == 1 ]; then
  echo "=================================="
  echo "Bugpoint file generated: sv-bugpoint-input.sv"
  echo "=================================="
  exit 0
fi

echo "=================================="
echo "Running simulation..."
echo "=================================="

# Run simulation
cd "$SCRIPT_DIR"
./verilator_obj_dir/Vuvm_pkg +UVM_TESTNAME="$OPT_TESTNAME"

if [ $? -eq 0 ]; then
  echo "=================================="
  echo "Simulation completed successfully!"
  echo "Waveform: sim.fst"
  echo "=================================="
else
  echo "=================================="
  echo "ERROR: Simulation failed!"
  echo "=================================="
  exit 1
fi
