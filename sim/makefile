# ==========================================================
# Makefile for UVM Testbench
# ==========================================================


VLOG = vlog
VSIM = vsim

FILELIST = filelist.f

TEST ?= test

# ==========================================================
# Compilation
# ==========================================================

compile:
	$(VLOG) -f $(FILELIST)

# ==========================================================
# Simulation
# ==========================================================

sim:
	$(VSIM) -voptargs="+acc" i2c_tb_top -c -do "run -all; exit"

wave:
	$(VSIM) -voptargs="+acc" i2c_tb_top +UVM_TESTNAME=$(TEST)

# ==========================================================
# Cleanup
# ==========================================================

clean:
	rm -rf work transcript vsim.wlf *.log *.ucdb *.vstf *.asdb *.vpd

.PHONY: compile sim wave clean

		