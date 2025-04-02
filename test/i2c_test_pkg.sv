/////////////////////////////////////////////////////////////////
//  file name   : i2c_test_pkg.sv
//  module name : i2c_test_pkg
//////////////////////////////////////////////////////////////////

`ifndef i2c_test_pkg
`define i2c_test_pkg

package i2c_test_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
 
  import i2c_env_pkg::*;
  `include "i2c_base_test.sv"
  
  parameter MAX_MST = 10;
  parameter MAX_SLV = 10;

endpackage: i2c_test_pkg
`endif
