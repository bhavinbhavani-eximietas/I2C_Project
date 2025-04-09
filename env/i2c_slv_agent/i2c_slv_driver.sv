/////////////////////////////////////////////////////////////////
//  file name   : i2c_slv_driver.sv
//  module name : i2c_slv_driver class
//////////////////////////////////////////////////////////////////

`ifndef i2c_slv_driver
`define i2c_slv_driver

typedef bit [7:0] queue[$];

class i2c_slv_driver extends uvm_driver #(i2c_slv_seq_item);
  
  //-------factory registration
  `uvm_component_utils(i2c_slv_driver)
  i2c_slv_agt m_slv_agt_h;

  virtual i2c_if m_vif;
  i2c_env_config m_env_cfg_h;
  queue mem [bit[7:0]];
  i2c_slv_seq_item m_slv_trans_h;
   
  bit [7:0] rd_data;   
  bit [6:0] slv_addr;

  extern function new(string name = "", uvm_component parent = null); 
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task send_to_dut();
  extern task check_addr();
  extern task reg_addr();
  extern task slv_reg_addr();
  extern task data(); 

endclass: i2c_slv_driver
`endif

// --------------------------------------------------------------------------

function i2c_slv_driver::new(string name = "", uvm_component parent = null);
  super.new(name, parent);     
endfunction
  
// --------------------------------------------------------------------------

function void i2c_slv_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);

  if (!uvm_config_db#(bit [6:0])::get(this, "", "slv_addr", slv_addr)) begin
    `uvm_fatal(get_type_name(), "Missing env_config!")
  end

endfunction: build_phase 
  
// --------------------------------------------------------------------------

task i2c_slv_driver::run_phase(uvm_phase phase);
  super.run_phase(phase); 

  forever begin
    seq_item_port.get_next_item(m_slv_trans_h);
    `uvm_info("INFO - SLV_DRV", "Get my next item", UVM_NONE)
    `uvm_info("INFO - FSM STATE", $sformatf("FSM state : %0s", m_slv_trans_h.state.name()), UVM_NONE)
    send_to_dut();
    seq_item_port.item_done();
  end
endtask: run_phase
  
// --------------------------------------------------------------------------

task i2c_slv_driver::send_to_dut();
  if(m_slv_trans_h.state == addr_rw) begin
    check_addr();
  end

  if(m_slv_trans_h.state == reg_addr) begin
    slv_reg_addr();
  end

  if(m_slv_trans_h.state == data_wr || m_slv_trans_h.state == data_rd) begin
    data();
  end 
endtask: send_to_dut
  
// --------------------------------------------------------------------------

task i2c_slv_driver::check_addr();
  `uvm_info(get_type_name(), "Check slave address ...", UVM_NONE)
  if(m_slv_trans_h.m_slv_addr == slv_addr) begin
    m_vif.sda_oe <= m_slv_trans_h.m_ack_nack;
  end
  else begin
    m_vif.sda_oe <= 1;
  end
endtask: check_addr 

// --------------------------------------------------------------------------

task i2c_slv_driver::slv_reg_addr();
    m_vif.sda_oe <= m_slv_trans_h.m_ack_nack;
endtask: slv_reg_addr

// --------------------------------------------------------------------------

task i2c_slv_driver::data();
  if(m_slv_trans_h.kind_e == write) begin
    mem[m_slv_trans_h.m_reg_addr].push_back(m_slv_trans_h.m_data);
    // ack nack
  end

  else begin
    // if((mem[m_slv_trans_h.m_reg_addr]).size() > 0) begin

      foreach(mem[m_slv_trans_h.m_reg_addr][i]) begin
        rd_data = mem[m_slv_trans_h.m_reg_addr][i];

        for(int j = 7; j >= 0; j--) begin
          @(negedge m_vif.scl_in);
          m_vif.sda_oe <= !rd_data[j];
        end 
        
        @(negedge m_vif.scl_in);
        m_vif.sda_oe <= 1'b0;

        @(posedge m_vif.scl_in);
        if(m_vif.sda_in == 1'b0) begin
          continue;
        end

        else begin
          break;
        end      
    end
  end
endtask: data
