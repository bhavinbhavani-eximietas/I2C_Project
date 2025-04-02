/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_config.sv
//  module name : i2c_slv_config class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_config
`define i2c_slv_config

class i2c_slv_config extends uvm_object;
 
  //To set i2c slvter agent mode i.e. ACTIVE, PASSIVE
  uvm_active_passive_enum is_active = UVM_ACTIVE;  //by default it is active 
   
  //Factory Registeration
  `uvm_object_utils_begin(i2c_slv_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_object_utils_end
  
  extern function new(string name = "");
   
endclass: i2c_slv_config
`endif

function i2c_slv_config::new(string name = "");
  super.new(name);
endfunction
