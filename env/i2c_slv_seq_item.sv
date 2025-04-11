/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_seq_item.sv
//  module name : i2c_slv_seq_item class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_seq_item
`define i2c_slv_seq_item

class i2c_slv_seq_item extends uvm_sequence_item;

  //signal
  bit [7:0] m_data;
  bit [6:0] m_slv_addr;
  bit [7:0] m_reg_addr;
  rand bit m_ack_nack;
  trans_kind m_kind;
  fsm_state m_state;

  extern function new(string name = "");
   
  //------FACTORY REGISTRATION 
  `uvm_object_utils_begin(i2c_slv_seq_item)
    `uvm_field_int(m_data, UVM_ALL_ON) 
    `uvm_field_int(m_ack_nack, UVM_ALL_ON)
    `uvm_field_int(m_slv_addr, UVM_ALL_ON)
    `uvm_field_int(m_reg_addr, UVM_ALL_ON)
    `uvm_field_enum(trans_kind, m_kind, UVM_ALL_ON)
    `uvm_field_enum(fsm_state, m_state, UVM_ALL_ON)
  `uvm_object_utils_end 

endclass: i2c_slv_seq_item

function i2c_slv_seq_item::new(string name = "");
  super.new(name);
endfunction 
`endif
