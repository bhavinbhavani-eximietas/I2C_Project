
/////////////////////////////////////////////////////////////////
//  file name   : i2c_bus_mon.sv
//  module name : i2c_bus_monitor class
//////////////////////////////////////////////////////////////////

`ifndef i2c_bus_monitor
`define i2c_bus_monitor

class i2c_bus_monitor extends uvm_monitor;

  //Factory Registration
  `uvm_component_utils(i2c_bus_monitor)

  //handle of seq_item (transaction class)
  i2c_mst_seq_item  m_mst_seq_h;
  i2c_slv_seq_item  m_slv_seq_h;
  
  //virtual interface declaration
  virtual i2c_if m_vif;
  
  //Analysis Port declaration
  uvm_analysis_port #(i2c_mst_seq_item) m_mst_an_port_h;
  uvm_analysis_port #(i2c_slv_seq_item) m_slv_an_port_h;
  
  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);

endclass: i2c_bus_monitor
`endif

function i2c_bus_monitor::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
  m_mst_an_port_h = new("m_mst_an_port_h", this);
  m_slv_an_port_h = new("m_slv_an_port_h", this);
endfunction
  
function void i2c_bus_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  //get virtual interface 
  if(!uvm_config_db #(virtual i2c_if)::get(this, "", "m_vif", m_vif)) begin
    `uvm_fatal(get_full_name(), "Master Interface is not available")
  end
  
endfunction: build_phase
  
task i2c_bus_monitor::run_phase(uvm_phase phase);  
endtask: run_phase



