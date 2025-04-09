# ==========================================================
# Makefile for UVM Testbench
# ==========================================================


VLOG = ${QUESTA}/vlog.exe
VSIM = ${QUESTA}/vsim.exe

FILELIST = filelist.f

TEST ?= i2c_base_test

# ==========================================================
# Compilation
# ==========================================================

compile:
	$(VLOG) -f $(FILELIST)

# ==========================================================
# Simulation
# ==========================================================

sim: compile
	$(VSIM) -voptargs="+acc" i2c_tb_top +UVM_TESTNAME=$(TEST) -c -do "run -all; exit"

wave: compile
	$(VSIM) -voptargs="+acc" i2c_tb_top +UVM_TESTNAME=$(TEST)

# ==========================================================
# Cleanup
# ==========================================================

clean:
	rm -rf work transcript vsim.wlf *.log *.ucdb *.vstf *.asdb *.vpd

.PHONY: compile sim wave clean

