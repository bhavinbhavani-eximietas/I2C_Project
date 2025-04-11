/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_seq_item_sv.sv
//  module name : i2c_mst_seq_item class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_seq_item
`define i2c_mst_seq_item

class i2c_mst_seq_item  extends uvm_sequence_item;
  
  //signal
  rand bit[6:0] m_slv_addr;
  rand bit[7:0] m_reg_addr;
  rand bit[7:0] m_data [$];
  rand bit no_rd_data;
  rand trans_kind m_kind;
  bit m_ack;

  extern constraint data_size_c;

  extern function new(string name = "");

  //------FACTORY REGISTRATION 
  `uvm_object_utils_begin(i2c_mst_seq_item)
    `uvm_field_queue_int(m_data, UVM_ALL_ON)
    `uvm_field_int(m_slv_addr, UVM_ALL_ON)
    `uvm_field_int(m_reg_addr, UVM_ALL_ON)
    `uvm_field_int(m_ack, UVM_ALL_ON)
    `uvm_field_enum(trans_kind, m_kind, UVM_ALL_ON)
  `uvm_object_utils_end 
  
endclass: i2c_mst_seq_item

constraint i2c_mst_seq_item::data_size_c { m_data.size() inside {[1:3]}; }

function i2c_mst_seq_item::new(string name = "");
  super.new(name);
endfunction
`endif
