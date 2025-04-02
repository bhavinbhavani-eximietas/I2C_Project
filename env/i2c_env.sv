/////////////////////////////////////////////////////////////////
//  file name   : i2c_env.sv
//  module name : i2c_env class
//////////////////////////////////////////////////////////////////

`ifndef i2c_env
`define i2c_env

class i2c_env extends uvm_env;
	
  //-------factory registration
  `uvm_component_utils(i2c_env)

  // ------  env config
  i2c_env_config m_env_cfg_h;

  //-------monitor
  i2c_bus_monitor m_mon_h;
  
  //----config
  i2c_mst_config m_mst_config_h[];
  i2c_slv_config m_slv_config_h[];

  //----i2c_agent
  i2c_mst_agt m_mst_agt_h[];
  i2c_slv_agt m_slv_agt_h[];
	
  //-------constructor 
  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  
endclass: i2c_env
`endif 

function i2c_env::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
endfunction 
  
function void i2c_env::build_phase(uvm_phase phase);
  m_env_cfg_h = i2c_env_config::type_id::create("m_env_cfg_h");
  uvm_config_db #(i2c_env_config)::set(this, "*", "m_env_cfg_h", m_env_cfg_h);
	
  m_mon_h = i2c_bus_monitor::type_id::create("m_mon_h", this);
	
  m_mst_agt_h = new[m_env_cfg_h.m_master_of_agts];
  m_mst_config_h = new[m_env_cfg_h.m_master_of_agts];
	
  m_slv_agt_h = new[m_env_cfg_h.m_slave_of_agts];
  m_slv_config_h = new[m_env_cfg_h.m_slave_of_agts]; 
	  
  foreach(m_mst_agt_h[i]) begin
    m_mst_agt_h[i] = i2c_mst_agt::type_id::create($sformatf("m_mst_agt_h[%0d]", i), this);
	m_mst_config_h[i] = i2c_mst_config::type_id::create($sformatf("m_mst_config_h[%0d]", i), this); 
	uvm_config_db #(i2c_mst_config)::set(this, "*", "mas_config", m_mst_config_h[i]);
  end	  
       	
  foreach(m_slv_agt_h[i]) begin
    m_slv_agt_h[i] = i2c_slv_agt::type_id::create($sformatf("m_slv_agt_h[%0d]", i), this);
    m_slv_config_h[i] = i2c_slv_config::type_id::create($sformatf("m_slv_config_h[%0d]", i), this); 
    uvm_config_db #(i2c_slv_config)::set(this, "*", "slv_config", m_slv_config_h[i]);
  end  
    
endfunction: build_phase

