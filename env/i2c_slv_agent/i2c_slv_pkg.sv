/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_pkg.sv
//  module name : i2c_slv_pkg
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_pkg
`define i2c_slv_pkg

package i2c_slv_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  `include "i2c_slv_config.sv"
  `include "i2c_slv_seq_item.sv"
  `include "i2c_slv_driver.sv"
  `include "i2c_slv_seqr.sv"
  `include "i2c_slv_agent.sv"
  
  `include "i2c_slv_base_seqs.sv"
 
endpackage: i2c_slv_pkg

`endif



