/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_pkg.sv
//  module name : i2c mst_PKG
//////////////////////////////////////////////////////////////////

`ifndef I2C_mst_PKG_SV
`define I2C_mst_PKG_SV

package i2c_mst_pkg;

  import uvm_pkg::*;
  
  `include "uvm_macros.svh"
  
  `include "i2c_mst_config.sv"
  `include "i2c_mst_seq_item.sv"
  `include "i2c_mst_driver.sv"
  `include "i2c_mst_seqr.sv"
  `include "i2c_mst_agent.sv"
  
  `include "i2c_mst_base_seqs.sv"

endpackage: i2c_mst_pkg

`endif



