/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_seqr.sv
//  module name : i2c_slv_seqr class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_seqr
`define i2c_slv_seqr

class i2c_slv_seqr extends uvm_sequencer #(i2c_slv_seq_item);
	
  // Factory registeration
  `uvm_component_utils(i2c_slv_seqr)
  
  extern function new(string name = "", uvm_component parent = null);

endclass: i2c_slv_seqr
`endif

function i2c_slv_seqr::new(string name = "", uvm_component parent = null);
  super.new(name,parent);
endfunction
