`ifndef I2C_INTERFACE_SV
`define I2C_INTERFACE_SV
import uvm_pkg::*;
`include "uvm_macros.svh"

interface i2c_if (inout tri1 sda, inout tri1 scl);

  logic sda_in;
  logic scl_in;
  bit sda_oe;
  bit scl_oe;

  assign sda = !sda_oe ? 1'bz : 0;
  assign sda_in = sda;
  
  assign scl = !scl_oe ? 1'bz : 0;
  assign scl_in = scl;

endinterface: i2c_if

module interconnect_if(inout tri1 SDA, inout tri1 SCL);

  i2c_if master_if[10](SDA, SCL);
  i2c_if slave_if[10](SDA, SCL);
  i2c_if bus_mon_if(SDA, SCL);

endmodule: interconnect_if
`endif
