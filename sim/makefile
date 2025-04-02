#Makefile for UVM testbench



cmp:
	vlog ../rtl/i2c_inf.sv ../env/i2c_env_pkg.sv ../test/i2c_test_pkg.sv ../top/i2c_top.sv +incdir+../env/i2c_mst_agent +incdir+../env/i2c_slv_agent +incdir+../env +incdir+../test
test=""

sim:
	vsim -voptargs="+acc" i2c_tb_top -c -do "run -all;exit" 

wave:
	vsim -voptargs="+acc" top +UVM_testNAME=$(test)
	

		