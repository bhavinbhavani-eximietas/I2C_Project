/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_seqr_sv.sv
//  module name : i2c_mst_seqr class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_seqr
`define i2c_mst_seqr

class i2c_mst_seqr extends uvm_sequencer #(i2c_mst_seq_item);
  
  //-------- Factory registeration
  `uvm_component_utils(i2c_mst_seqr)
  
  extern function new(string name = "", uvm_component parent = null);
 
endclass: i2c_mst_seqr

function i2c_mst_seqr::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
endfunction
`endif
