/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_seq_item.sv
//  module name : i2c_slv_seq_item class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_seq_item
`define i2c_slv_seq_item

class i2c_slv_seq_item extends uvm_sequence_item;
		
  //signal
  bit[7:0] m_data[$];
  bit m_ack;
  bit m_repeated_start;
		
  extern function new(string name = "");
   
  //------FACTORY REGISTRATION 
  `uvm_object_utils_begin(i2c_slv_seq_item)
    `uvm_field_queue_int(m_data, UVM_ALL_ON) 
    `uvm_field_int(m_ack, UVM_ALL_ON)
    `uvm_field_int(m_repeated_start, UVM_ALL_ON)
  `uvm_object_utils_end 

endclass: i2c_slv_seq_item
`endif

function i2c_slv_seq_item::new(string name = "");
  super.new(name);
endfunction 

