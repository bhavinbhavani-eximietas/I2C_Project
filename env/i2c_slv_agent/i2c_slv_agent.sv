/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_agent.sv 
//  module name : i2c_slv_agt class
/////////////////////////////////////////////////////////////////

`ifndef i2c_slv_agt
`define i2c_slv_agt

class i2c_slv_agt extends uvm_agent;
  
  i2c_slv_config m_slv_cfg_h;
  bit[6:0] m_slv_addr;
  
  //------Factory Registration
  `uvm_component_utils(i2c_slv_agt)
  
  //---virtual interface
  virtual i2c_if m_vif;
  
  //-------handle of components and config 
  i2c_slv_driver m_drv_h;
  i2c_slv_seqr m_seqr_h;
 
  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
   
endclass: i2c_slv_agt

function i2c_slv_agt::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
endfunction
  
function void i2c_slv_agt::build_phase(uvm_phase phase);
  super.build_phase(phase);
 
  //create handle of slvter config 
  m_slv_cfg_h = i2c_slv_config::type_id::create("m_slv_cfg_h", this);
 
  //get slv configuration 
  if(!uvm_config_db #(i2c_slv_config)::get(this, "", "slv_config", m_slv_cfg_h)) begin
    `uvm_fatal(get_full_name(), "slvter config is not available")
  end
  
  uvm_config_db #(bit [6:0])::set(this, "m_drv_h", "slv_addr", m_slv_addr);

  //if agent is active create driver and sequencer 
  if(m_slv_cfg_h.is_active == UVM_ACTIVE) begin 
    m_drv_h = i2c_slv_driver::type_id::create("m_drv_h", this);
    m_seqr_h = i2c_slv_seqr::type_id::create("m_seqr_h", this);
  end 
    
  //get virtual interface 
  if(!uvm_config_db #(virtual i2c_if)::get(this, "", "m_vif", m_vif)) begin
    `uvm_fatal(get_full_name(), "slvter Interface is not available")
  end
  
endfunction: build_phase
  
function void i2c_slv_agt::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  
  if(m_slv_cfg_h.is_active == UVM_ACTIVE) begin 
    m_drv_h.seq_item_port.connect(m_seqr_h.seq_item_export);
    m_drv_h.m_vif = this.m_vif; 
  end
  
endfunction: connect_phase
`endif
