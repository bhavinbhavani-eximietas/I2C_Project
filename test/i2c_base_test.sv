/////////////////////////////////////////////////////////////////
//  file name   : i2c_base_test.sv
//  module name : i2c_base_test class
//////////////////////////////////////////////////////////////////

`ifndef i2c_base_test
`define i2c_base_test

class i2c_base_test extends uvm_test;
	
  //-------factory registration
  `uvm_component_utils(i2c_base_test)
	
  //------- APB ENVIRONMENT
  i2c_env m_env_h;

  //-------constructor 
  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation();
   
endclass: i2c_base_test
`endif 

function i2c_base_test::new(string name = "", uvm_component parent = null);
  super.new(name,parent);
endfunction

function void i2c_base_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_env_h = i2c_env::type_id::create("m_env_h", this);
endfunction: build_phase 

function void i2c_base_test::start_of_simulation();
  super.start_of_simulation(); 
  uvm_top.print_topology();
endfunction: start_of_simulation 
