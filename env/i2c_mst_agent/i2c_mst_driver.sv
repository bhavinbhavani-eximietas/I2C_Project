/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_drv_sv.sv
//  module name : i2c_mst_driver class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_driver
`define i2c_mst_driver

class i2c_mst_driver extends uvm_driver #(i2c_mst_seq_item);
  
  //factory registration
  `uvm_component_utils(i2c_mst_driver)
  virtual i2c_if m_vif;
  i2c_mst_seq_item m_mst_trans_h;
  
  bit clk_en;
  bit [7:0] rd_data;
  int duty_time = 5, period = 10;
  enum bit [2:0]  {IDLE, START, SLV_ADDR, REG_ADDR, DATA_WR, DATA_RD, STOP} state;
  parameter CLK_CHECK_TIME = 2;

  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  
  extern task gen_clk();
  extern task start_condition();
  extern task stop_condition();
  extern task send_info(input bit[7:0] info_byte);
  extern task check_ack_nack();
  extern task mst_drv_fsm();
  
endclass: i2c_mst_driver

// --------------------------------------------------------------------------
function i2c_mst_driver::new(string name = "", uvm_component parent = null);
  super.new(name, parent); 
endfunction
  
// --------------------------------------------------------------------------
function void i2c_mst_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  m_mst_trans_h = i2c_mst_seq_item::type_id::create("m_mst_trans_h", this);
endfunction: build_phase
  
// --------------------------------------------------------------------------
task i2c_mst_driver::run_phase(uvm_phase phase);
  fork 
    gen_clk();
    mst_drv_fsm();
  join_none
endtask: run_phase

// --------------------------------------------------------------------------
task i2c_mst_driver::gen_clk();
  forever begin
    if(clk_en == 1) begin
      #(period - duty_time);
      m_vif.scl_oe <= 0;
      
      #(duty_time);
      m_vif.scl_oe <= 1;
    end
    else begin  // release SCL line
      m_vif.scl_oe <= 0;
      #(CLK_CHECK_TIME);
    end
  end
endtask: gen_clk

// --------------------------------------------------------------------------
task i2c_mst_driver::start_condition();
  m_vif.sda_oe <= 1;
  #(duty_time/2);
  m_vif.scl_oe <= 1;
  clk_en <= 1;
endtask: start_condition

// --------------------------------------------------------------------------
task i2c_mst_driver::stop_condition();
  begin
    @(negedge m_vif.scl_in);
    m_vif.sda_oe <= 1;

    @(posedge m_vif.scl_in);
    #(duty_time/2);
    m_vif.sda_oe <= 0;
    clk_en <= 0;
  end 
endtask: stop_condition

// --------------------------------------------------------------------------
task i2c_mst_driver::send_info(input bit[7:0] info_byte);
  for(int i = 7; i >=0; i -= 1) begin
    @(negedge m_vif.scl_in);
    m_vif.sda_oe <= !info_byte[i];
  end
  
  @(negedge m_vif.scl_in);
  m_vif.sda_oe <= 0;  // release SDA
  `uvm_info("DRV", $sformatf("Send Info: %b | 0x%0h", info_byte, info_byte), UVM_LOW)
endtask: send_info

// --------------------------------------------------------------------------
task i2c_mst_driver::check_ack_nack();
  @(posedge m_vif.scl_in);
  if(m_vif.sda_in == 0)
    m_mst_trans_h.m_ack = 1;
  else
    m_mst_trans_h.m_ack = 0;
endtask: check_ack_nack

// --------------------------------------------------------------------------
task i2c_mst_driver::mst_drv_fsm();
  forever begin

  case(state) 
    IDLE :
      begin
        #(duty_time);
        seq_item_port.get_next_item(m_mst_trans_h);
        state = START;
      end
    
    START :
      begin
        start_condition();  // drive start condition
        state = SLV_ADDR;
      end
    
    SLV_ADDR :
      begin
        send_info({m_mst_trans_h.m_slv_addr, m_mst_trans_h.m_kind});
        check_ack_nack();
        if(m_mst_trans_h.m_ack == 1)
          state = REG_ADDR;
        else
          state = STOP;
      end
    
    REG_ADDR :
      begin
        send_info(m_mst_trans_h.m_reg_addr);
        check_ack_nack();
        if(m_mst_trans_h.m_ack == 1) begin
          if(m_mst_trans_h.m_kind == 0)  // write read operation
            state = DATA_WR;
          else
            state = DATA_RD;
        end
        else
          state = STOP;
      end
    
    DATA_WR :
      begin
        while(m_mst_trans_h.m_data.size() > 0) begin
          send_info(m_mst_trans_h.m_data.pop_front());
          check_ack_nack();
          if(m_mst_trans_h.m_ack == 1)
            continue;
          else begin
            state = STOP;
            break;
          end
        end
        state = STOP;
      end
    
    DATA_RD :
      begin
        // driver read data and send ack
        for(int i = 0; i < m_mst_trans_h.no_rd_data; i += 1) begin
          for(int j = 7; j >= 0; j--) begin
            @(posedge m_vif.scl_in);
            rd_data[j] <= m_vif.sda_in;
          end
          @(negedge m_vif.scl_in);
          m_vif.sda_oe <= 1;
          // release SDA
        end
        @(negedge m_vif.scl_in);
        m_vif.sda_oe <= 0;
        state = STOP;
      end
    
    STOP :
      begin
        stop_condition(); // drive stop condition 
        state = IDLE;
        seq_item_port.item_done();
      end
    default :
      begin
        state = IDLE;
      end
  endcase
  end
endtask: mst_drv_fsm
`endif 
