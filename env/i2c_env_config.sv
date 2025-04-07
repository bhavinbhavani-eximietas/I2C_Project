/////////////////////////////////////////////////////////////////
//  file name   : i2c_env_config.sv
//  module name : i2c_env_config class
//////////////////////////////////////////////////////////////////

`ifndef i2c_env_config
`define i2c_env_config

class i2c_env_config extends uvm_object;
   
  //To set No of i2c Master Agent
  int m_master_of_agts = 1; 
  int m_slave_of_agts = 2;   
  
  rand bit [6:0] m_slv_addr_arr[];

  //Factory Registeration
  `uvm_object_utils_begin(i2c_env_config)
    `uvm_field_int(m_master_of_agts, UVM_ALL_ON)
    `uvm_field_int(m_slave_of_agts, UVM_ALL_ON)
    `uvm_field_array_int(m_slv_addr_arr, UVM_ALL_ON)
  `uvm_object_utils_end
  

  constraint slv_addr_value_c { unique {m_slv_addr_arr}; m_slv_addr_arr.size() == m_slave_of_agts; }

  extern function new(string name = "");
  extern function void set_no_master(int value_mst); 
  extern function void set_no_slave(int value_slv);
    
endclass: i2c_env_config
`endif

function i2c_env_config::new(string name = "");
  super.new(name);
endfunction
  
function void i2c_env_config::set_no_master(int value_mst); 
  
  if (value_mst < MAX_MST) begin
    m_master_of_agts = value_mst;
  end 
	
  else begin
    `uvm_error(get_full_name(), $sformatf("Invalid number of masters: %0d. MAX_MAS allowed is %0d. 
    Keeping previous value_mst: %0d", value_mst, MAX_MST, m_master_of_agts));
  end
  
endfunction: set_no_master
  
function void i2c_env_config::set_no_slave(int value_slv);

  if (value_slv  < MAX_SLV) begin
    m_slave_of_agts = value_slv;
  end
	
  else begin
     `uvm_error(get_full_name(), $sformatf("Invalid number of slaves: %0d. MAX_SLAVE allowed is 
     %0d. Keeping previous value_mst: %0d", value_slv, MAX_SLV, m_slave_of_agts))
  end
  
endfunction: set_no_slave
