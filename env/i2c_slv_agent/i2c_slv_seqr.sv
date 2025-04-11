/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_seqr.sv
//  module name : i2c_slv_seqr class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_seqr
`define i2c_slv_seqr

class i2c_slv_seqr extends uvm_sequencer #(i2c_slv_seq_item);

  // Factory registeration
  `uvm_component_utils(i2c_slv_seqr)

  //export
  uvm_analysis_export #(i2c_slv_seq_item) m_seqr_an_export_h;
  uvm_tlm_analysis_fifo #(i2c_slv_seq_item) m_fifo_h;
  
  extern function new(string name = "", uvm_component parent = null);
  extern function void connect_phase(uvm_phase phase);

endclass: i2c_slv_seqr

function i2c_slv_seqr::new(string name = "", uvm_component parent = null);
  super.new(name,parent);

  m_seqr_an_export_h = new("m_seqr_an_export_h", this);
  m_fifo_h = new("m_fifo_h", this);
endfunction

function void i2c_slv_seqr::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  m_seqr_an_export_h.connect(m_fifo_h.analysis_export);
endfunction: connect_phase
`endif
