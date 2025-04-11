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
  extern task slv_reg_addr();
  extern task data(); 

endclass: i2c_slv_driver

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
    `uvm_info("INFO - SLV_DRV", "Get my next item", UVM_LOW)
    send_to_dut();
    seq_item_port.item_done();
  end
endtask: run_phase
  
// --------------------------------------------------------------------------
task i2c_slv_driver::send_to_dut();
  if(m_slv_trans_h.m_state == SLV_ADDR_ACK_NACK) begin
    check_addr();
  end

  if(m_slv_trans_h.m_state == REG_ADDR_ACK_NACK) begin
    slv_reg_addr();
  end

  if(m_slv_trans_h.m_state == ACK_NACK_WR || m_slv_trans_h.m_state == ACK_NACK_RD) begin
    data();
  end 
endtask: send_to_dut
  
// --------------------------------------------------------------------------
task i2c_slv_driver::check_addr();
  `uvm_info(get_type_name(), "Check slave address ...", UVM_LOW)
  if(m_slv_trans_h.m_slv_addr == slv_addr) begin
    m_vif.sda_oe = m_slv_trans_h.m_ack_nack;

    @(negedge m_vif.scl_in);
    m_vif.sda_oe <= 0;
  end
  else begin
    m_vif.sda_oe <= 0;
  end
endtask: check_addr 

// --------------------------------------------------------------------------
task i2c_slv_driver::slv_reg_addr();
  m_vif.sda_oe <= m_slv_trans_h.m_ack_nack;

  @(negedge m_vif.scl_in);
  m_vif.sda_oe <= 0;
endtask: slv_reg_addr

// --------------------------------------------------------------------------
task i2c_slv_driver::data();
  if(m_slv_trans_h.m_kind == WRITE) begin
    mem[m_slv_trans_h.m_reg_addr].push_back(m_slv_trans_h.m_data);
    `uvm_info(get_type_name(), $sformatf("SLV_MEM: %0p", mem), UVM_LOW)

    m_vif.sda_oe <= m_slv_trans_h.m_ack_nack;
    @(negedge m_vif.scl_in);
    m_vif.sda_oe <= 0;
  end

  else begin
    if(mem.exists(m_slv_trans_h.m_reg_addr)) begin
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
    else begin
    `uvm_error(get_type_name(), "Register Address is not available !")
    end
  end
endtask: data
`endif
