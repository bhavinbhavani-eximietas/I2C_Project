/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_config_sv.sv
//  module name : i2c_mst_config class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_config
`define i2c_mst_config

class i2c_mst_config extends uvm_object;
  
  //To set i2c Master agent mode i.e. ACTIVE, PASSIVE
  uvm_active_passive_enum is_active = UVM_ACTIVE;  //by default it is active 
  bit[6:0] m_slv_addr_arr[];
   
  //Factory Registeration
  `uvm_object_utils_begin(i2c_mst_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_object_utils_end
  
  extern function new(string name = "");
  
endclass: i2c_mst_config 

function i2c_mst_config::new(string name = "");
  super.new(name);
endfunction
`endif
