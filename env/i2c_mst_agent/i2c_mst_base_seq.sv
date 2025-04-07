/////////////////////////////////////////////////////////////////
//  file name   : i2c_mas_base_seq.sv
//  module name : i2c_mst_base_seq class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_base_seq
`define i2c_mst_base_seq

class i2c_mst_base_seq extends uvm_sequence #(i2c_mst_seq_item);
	
  //-------factory registration
  `uvm_object_utils(i2c_mst_base_seq)
  
  //--------seq_item handle
  i2c_mst_seq_item m_mst_seq_h;
  
  //-------constructor 
  extern function new(string name = "");
  extern task body();

endclass: i2c_mst_base_seq
`endif 

function i2c_mst_base_seq::new(string name = "");
  super.new(name);
endfunction

task i2c_mst_base_seq::body();
 m_mst_seq_h = i2c_mst_seq_item::type_id::create("m_mst_seq_h");

 repeat(2) begin
 start_item(m_mst_seq_h);
   if(!m_mst_seq_h.randomize()) begin
     `uvm_fatal(get_type_name(), "RANDOMIZATION FAILED !!!");
   end
   `uvm_info("mst_seq",$sformatf("Data is generated =  ",m_mst_seq_h.sprint()), UVM_NONE);
   finish_item(m_mst_seq_h);
 end
endtask
