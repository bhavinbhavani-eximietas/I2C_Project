/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_pkg.sv
//  module name : i2c mst_PKG
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_pkg_sv
`define i2c_mst_pkg_sv

package i2c_mst_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  `include "i2c_mst_config.sv"
  `include "i2c_mst_seq_item.sv"
  `include "i2c_mst_driver.sv"
  `include "i2c_mst_seqr.sv"
  `include "i2c_mst_agent.sv"
  
  `include "i2c_mst_base_seq.sv"

endpackage: i2c_mst_pkg

`endif
