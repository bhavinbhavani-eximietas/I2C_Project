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
  extern function void connect_phase(uvm_phase phase);
  
endclass: i2c_env

function i2c_env::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
endfunction 
  
function void i2c_env::build_phase(uvm_phase phase);
  m_env_cfg_h = i2c_env_config::type_id::create("m_env_cfg_h");
  
  if(!uvm_config_db #(i2c_env_config)::get(this, "*", "m_env_cfg_h", m_env_cfg_h)) begin 
    `uvm_fatal(get_full_name(), "env config is not available")
  end 

  m_mon_h = i2c_bus_monitor::type_id::create("m_mon_h", this);

  m_mst_agt_h = new[m_env_cfg_h.m_master_of_agts];
  m_mst_config_h = new[m_env_cfg_h.m_master_of_agts];

  m_slv_agt_h = new[m_env_cfg_h.m_slave_of_agts];
  m_slv_config_h = new[m_env_cfg_h.m_slave_of_agts]; 
  
  foreach(m_mst_agt_h[i]) begin
    m_mst_agt_h[i] = i2c_mst_agt::type_id::create($sformatf("m_mst_agt_h[%0d]", i), this);
    m_mst_config_h[i] = i2c_mst_config::type_id::create($sformatf("m_mst_config_h[%0d]", i), this);
    uvm_config_db #(i2c_mst_config)::set(this, $sformatf("m_mst_agt_h[%0d]", i), "mst_config", m_mst_config_h[i]);
  end  

  foreach(m_slv_agt_h[i]) begin
    m_slv_agt_h[i] = i2c_slv_agt::type_id::create($sformatf("m_slv_agt_h[%0d]", i), this);
    m_slv_config_h[i] = i2c_slv_config::type_id::create($sformatf("m_slv_config_h[%0d]", i), this); 
    m_slv_agt_h[i].m_slv_addr = m_env_cfg_h.m_slv_addr_arr[i];
    uvm_config_db #(i2c_slv_config)::set(this, $sformatf("m_slv_agt_h[%0d]", i), "slv_config", m_slv_config_h[i]);
  end    
    
endfunction: build_phase

function void i2c_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  foreach(m_slv_agt_h[i]) begin
    m_mon_h.m_slv_an_port_h.connect(m_slv_agt_h[i].m_seqr_h.m_seqr_an_export_h);
  end
endfunction: connect_phase

`endif 
