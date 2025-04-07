/////////////////////////////////////////////////////////////////
//  file name   : i2c_top.sv
//  module name : i2c_top
//////////////////////////////////////////////////////////////////

module i2c_tb_top();
  import uvm_pkg::*;
  import i2c_test_pkg::*;
  
  wire SDA;
  wire SCL;

  //interface instance
  interconnect_if m_vif(SDA, SCL);

  initial begin
    for(int i; i<MAX_MST; i++) begin
      uvm_config_db #(virtual i2c_if)::set(null, $sformatf("uvm_test_top.m_env_h.m_mst_agt_h[%0d]",
      i) ,"m_vif" ,m_vif.master_if[i]);
    end

    for(int i; i<MAX_SLV; i++) begin
      uvm_config_db #(virtual i2c_if)::set(null, $sformatf("uvm_test_top.m_env_h.m_slv_agt_h[%0d]",
      i) ,"m_vif" ,m_vif.slave_if[i]);
    end
	
	uvm_config_db #(virtual i2c_if)::set(null, "uvm_test_top.m_env_h.m_mon_h","m_vif", 
    m_vif.bus_mon_if);

    run_test("i2c_base_test");
  end
 
endmodule: i2c_tb_top
 
