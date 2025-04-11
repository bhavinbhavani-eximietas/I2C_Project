/////////////////////////////////////////////////////////////////
//  file name   : i2c_env_pkg.sv
//  module name : i2c_env_pkg
//////////////////////////////////////////////////////////////////

`ifndef i2c_env_pkg
`define i2c_env_pkg

package i2c_env_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  parameter MAX_MST = 10;
  parameter MAX_SLV = 10;
  
  // enum for read write
  typedef enum bit {WRITE, READ} trans_kind;
  typedef enum bit [3:0] {START, ADDR_RW, SLV_ADDR_ACK_NACK, REG_ADDR, REG_ADDR_ACK_NACK, DATA_WR, ACK_NACK_WR, DATA_RD, ACK_NACK_RD} fsm_state;
  
  // import i2c_mst_pkg ::*;
  // import i2c_slv_pkg ::*;
  
  `include "i2c_env_config.sv"
  `include "i2c_mst_seq_item.sv"
  `include "i2c_slv_seq_item.sv"
  
  `include "i2c_mst_config.sv"
  `include "i2c_mst_driver.sv"
  `include "i2c_mst_seqr.sv"
  `include "i2c_mst_agent.sv"
  `include "i2c_mst_base_seq.sv"
  
  `include "i2c_slv_config.sv"
  `include "i2c_slv_driver.sv"
  `include "i2c_slv_seqr.sv"
  `include "i2c_slv_agent.sv"
  `include "i2c_slv_base_seq.sv"
  
  `include "i2c_bus_monitor.sv"
  `include "i2c_env.sv"
  
endpackage: i2c_env_pkg
`endif
