/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_base_seq.sv
//  module name : i2c_slv_base_seq class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_base_seq
`define i2c_slv_base_seq

class i2c_slv_base_seq extends uvm_sequence #(i2c_slv_seq_item);
    
  //-------factory registration
  `uvm_object_utils(i2c_slv_base_seq)
  `uvm_declare_p_sequencer(i2c_slv_seqr)

  //seq_item handal
  i2c_slv_seq_item m_slv_trans_h;

  //-------constructor 
  extern function new(string name = "");
  extern task body();

endclass: i2c_slv_base_seq

function i2c_slv_base_seq::new(string name = "");
  super.new(name);
endfunction 

task i2c_slv_base_seq::body();
  forever begin
    `uvm_info(get_type_name(), "Before fifo get", UVM_LOW)
    p_sequencer.m_fifo_h.get(m_slv_trans_h);
    `uvm_info(get_type_name(), $sformatf("Getting FIFO data", m_slv_trans_h.sprint()), UVM_LOW)
    
    start_item(m_slv_trans_h);
    if(!m_slv_trans_h.randomize() with {m_slv_trans_h.m_ack_nack == 1'b1;}) begin
      `uvm_fatal(get_full_name(), "m_slv_trans_h not randomize")
    end
    finish_item(m_slv_trans_h);
  end
endtask
`endif 
