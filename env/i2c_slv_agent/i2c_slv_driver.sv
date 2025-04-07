/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_driver.sv
//  module name : i2c_slv_driver class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_driver
`define i2c_slv_driver

class i2c_slv_driver extends uvm_driver #(i2c_slv_seq_item);
  
  //-------factory registration
  `uvm_component_utils(i2c_slv_driver)

  virtual i2c_if m_vif;
  i2c_env_config m_env_cfg_h;

  extern function new(string name = "", uvm_component parent = null); 
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task send_to_dut();
  
endclass: i2c_slv_driver
`endif 

function i2c_slv_driver::new(string name = "", uvm_component parent = null);
  super.new(name, parent);	 
endfunction
  
function void i2c_slv_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db#(i2c_env_config)::get(this, "", "m_env_cfg_h", m_env_cfg_h))
    `uvm_fatal(get_type_name(), "Missing env_config!")

endfunction: build_phase 
  
task i2c_slv_driver::run_phase(uvm_phase phase);
  super.run_phase(phase);
endtask: run_phase
  
task i2c_slv_driver::send_to_dut();
endtask: send_to_dut
  
  
