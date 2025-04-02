

vlog ..\RTL\ahb_inf.sv ..\ENV\ahb_env_pkg.sv ..\TEST\ahb_test_pkg.sv ..\TOP\ahb_top.sv +incdir+..\ENV\AHB_MAS_AGENT +incdir+..\ENV\AHB_SLAVE_AGENT +incdir+..\ENV +incdir+..\TEST
vsim -voptargs=+acc ahb_tb_top  



