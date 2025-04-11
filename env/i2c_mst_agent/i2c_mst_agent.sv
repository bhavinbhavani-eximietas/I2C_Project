/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_agent.sv 
//  module name : i2c_mst_agt CLASS
/////////////////////////////////////////////////////////////////

`ifndef i2c_mst_agt
`define i2c_mst_agt

class i2c_mst_agt extends uvm_agent;
  
  //Factory Registration
  `uvm_component_utils(i2c_mst_agt)
  
  //virtual interface
  virtual i2c_if m_vif;
  
  //handle of components and config
  i2c_mst_config m_cfg_h;
  i2c_mst_driver m_drv_h;
  i2c_mst_seqr m_seqr_h;
 
  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: i2c_mst_agt

function i2c_mst_agt::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void i2c_mst_agt::build_phase(uvm_phase phase);
  super.build_phase(phase);

  //create handle of master config 
  m_cfg_h = i2c_mst_config::type_id::create("m_cfg_h", this); 
    
  //get master configuration 
  if(!uvm_config_db #(i2c_mst_config)::get(this, "", "mst_config", m_cfg_h)) begin
    `uvm_fatal(get_full_name(), "Master config is not available")
  end
 
  //if agent is active create driver and sequencer 
  if(m_cfg_h.is_active == UVM_ACTIVE) begin 
    m_drv_h = i2c_mst_driver::type_id::create("m_drv_h", this);
    m_seqr_h = i2c_mst_seqr::type_id::create("m_seqr_h", this);
  end 

  //get virtual interface 
  if(!uvm_config_db #(virtual i2c_if)::get(this, "", "m_vif", m_vif)) begin
    `uvm_fatal(get_full_name(), "Master Interface is not available")
  end
  
endfunction: build_phase 

function void i2c_mst_agt::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  if(m_cfg_h.is_active == UVM_ACTIVE) begin 
    m_drv_h.seq_item_port.connect(m_seqr_h.seq_item_export); 
    m_drv_h.m_vif = this.m_vif; 
  end

endfunction: connect_phase
`endif
