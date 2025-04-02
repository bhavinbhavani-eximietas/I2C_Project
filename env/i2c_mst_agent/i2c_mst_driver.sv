/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_drv_sv.sv
//  module name : i2c_mst_driver class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_driver
`define i2c_mst_driver

class i2c_mst_driver extends uvm_driver #(i2c_mst_seq_item);
  
  //factory registration
  `uvm_component_utils(i2c_mst_driver)
   
  virtual i2c_if m_vif;
   
  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  
endclass: i2c_mst_driver
`endif 

function i2c_mst_driver::new(string name = "", uvm_component parent = null);
  super.new(name, parent);	 
endfunction
  
function void i2c_mst_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
endfunction: build_phase
  
task i2c_mst_driver::run_phase(uvm_phase phase);
endtask: run_phase  