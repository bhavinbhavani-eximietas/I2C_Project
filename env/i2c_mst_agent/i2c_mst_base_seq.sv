/////////////////////////////////////////////////////////////////
//  file name   : i2c_mas_base_seq.sv
//  module name : i2c_mst_base_seq class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_base_seq
`define i2c_mst_base_seq

class i2c_mst_base_seq extends uvm_sequence #(i2c_mst_seq_item);

  i2c_env_config m_env_cfg_h;
  //-------factory registration
  `uvm_object_utils(i2c_mst_base_seq)
  
  //--------seq_item handle
  i2c_mst_seq_item m_mst_trans_h;
  
  //-------constructor 
  extern function new(string name = "");
  extern task pre_start();
  extern task body();

endclass: i2c_mst_base_seq

function i2c_mst_base_seq::new(string name = "");
  super.new(name);
endfunction

task i2c_mst_base_seq::pre_start();
  if(!uvm_config_db #(i2c_env_config)::get(null, "*", "m_env_cfg_h", m_env_cfg_h)) begin
     `uvm_fatal(get_full_name(), "env config is not available")
  end
endtask: pre_start 


task i2c_mst_base_seq::body();
 m_mst_trans_h = i2c_mst_seq_item::type_id::create("m_mst_trans_h");

 repeat(4) begin
   start_item(m_mst_trans_h);
   if(!m_mst_trans_h.randomize() with { m_mst_trans_h.m_slv_addr inside {m_env_cfg_h.m_slv_addr_arr};}) begin
     `uvm_fatal(get_type_name(), "RANDOMIZATION FAILED !!!");
   end
   `uvm_info("mst_seq",$sformatf("Data is generated =  ",m_mst_trans_h.sprint()), UVM_LOW);
   finish_item(m_mst_trans_h);
 end
endtask
`endif 
