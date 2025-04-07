/////////////////////////////////////////////////////////////////
//  file name   : i2c_base_test.sv
//  module name : i2c_base_test class
//////////////////////////////////////////////////////////////////

`ifndef i2c_base_test
`define i2c_base_test

class i2c_base_test extends uvm_test;
	
  //-------factory registration
  `uvm_component_utils(i2c_base_test)
  	
  //-------  ENVIRONMENT
  i2c_env m_env_h;
  
  //--------Env config
  i2c_env_config m_env_cfg_h;
  
  i2c_mst_base_seq m_mst_seq;
  //-------constructor 
  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void start_of_simulation();
   
endclass: i2c_base_test
`endif 

function i2c_base_test::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void i2c_base_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_env_h = i2c_env::type_id::create("m_env_h", this);
  m_env_cfg_h = i2c_env_config::type_id::create("m_env_cfg_h", this);

  if (!m_env_cfg_h.randomize())
    `uvm_fatal(get_type_name(), "Failed to randomize env config")
  
  `uvm_info("env_cfg",$sformatf("Address is generated =  ",m_env_cfg_h.sprint()), UVM_NONE);
  
  uvm_config_db #(i2c_env_config)::set(this, "*", "m_env_cfg_h", m_env_cfg_h);
endfunction: build_phase 

task i2c_base_test::run_phase(uvm_phase phase);
  phase.raise_objection(this);
  m_mst_seq = i2c_mst_base_seq::type_id::create("m_mst_seq");
  m_mst_seq.start(m_env_h.m_mst_agt_h[0].m_seqr_h);
  `uvm_info(get_type_name(), "Before drop objection",UVM_NONE)
  phase.drop_objection(this);
  `uvm_info(get_type_name(), "After drop objection",UVM_NONE)
endtask: run_phase 


function void i2c_base_test::start_of_simulation();
  super.start_of_simulation(); 
  uvm_top.print_topology();
endfunction: start_of_simulation 
