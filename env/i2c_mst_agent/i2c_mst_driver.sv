/////////////////////////////////////////////////////////////////
//  file name   : i2c_mst_drv_sv.sv
//  module name : i2c_mst_driver class
//////////////////////////////////////////////////////////////////

`ifndef i2c_mst_driver
`define i2c_mst_driver

class i2c_mst_driver extends uvm_driver #(i2c_mst_seq_item);
  
  //factory registration
  `uvm_component_utils(i2c_mst_driver)
  event done; 
  virtual i2c_if m_vif;
  
  bit clk_en;
  bit [7:0] rd_data;
  int duty_time = 5, period = 10;
  enum {idle, start, slv_addr, reg_addr, data_wr, data_rd, stop} state;

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
`endif 

// --------------------------------------------------------------------------

function i2c_mst_driver::new(string name = "", uvm_component parent = null);
  super.new(name, parent);	 
endfunction
  
// --------------------------------------------------------------------------

function void i2c_mst_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
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
      #(2);
    end
    
  end
endtask: gen_clk

// --------------------------------------------------------------------------

task i2c_mst_driver::start_condition();
  fork
    begin
      @(negedge m_vif.sda_in);
      #(duty_time/2);
      m_vif.scl_oe <= 1;
      clk_en = 1;
    end
    begin 
      m_vif.sda_oe <= 1;
    end
  join
endtask: start_condition

// --------------------------------------------------------------------------

task i2c_mst_driver::stop_condition();
  begin
    @(negedge m_vif.scl_in);
    m_vif.sda_oe = 1;

    @(posedge m_vif.scl_in);
    #(duty_time/2);
    m_vif.sda_oe = 0;
    clk_en = 0;
  end 
endtask: stop_condition

// --------------------------------------------------------------------------

task i2c_mst_driver::send_info(input bit[7:0] info_byte);
  for(int i = 7; i >=0; i -= 1) begin
    @(negedge m_vif.scl_in);
    m_vif.sda_oe = !info_byte[i];
  end
  
  @(negedge m_vif.scl_in);
  m_vif.sda_oe = 0;  // release SDA
endtask: send_info

// --------------------------------------------------------------------------

task i2c_mst_driver::check_ack_nack();
  @(posedge m_vif.scl_in);
  if(m_vif.sda_in == 0)
    req.m_ack = 1;
  else
    req.m_ack = 0;
endtask: check_ack_nack

// --------------------------------------------------------------------------

task i2c_mst_driver::mst_drv_fsm();
  forever begin

  case(state)   
    idle :  
      begin
        #(duty_time);
        seq_item_port.get_next_item(req);
        state = start;
      end
    
    start :  
      begin
        start_condition();  // drive start condition
        state = slv_addr;
      end
    
    slv_addr :  
      begin    
        send_info({req.m_slv_addr, req.m_kind});
        check_ack_nack();
        if(req.m_ack == 1)
          state = reg_addr;
        else
          state = stop;
      end
    
    reg_addr :
      begin
        send_info(req.m_reg_addr);
        check_ack_nack();
        if(req.m_ack == 1) begin
          if(req.m_kind == 0)  // write read operation
          	state = data_wr;
          else
        	  state = data_rd;
        end
        else
          state = stop;
      end
    
    data_wr :  
      begin
        while(req.m_data.size() > 0) begin
          send_info(req.m_data.pop_back());
          check_ack_nack();
          if(req.m_ack == 1)
            continue;
          else begin
            state = stop;
            break;
          end
        end
        state = stop;
      end
    
    data_rd :
      begin
        // driver read data and send ack
        for(int i = 0; i < req.no_rd_data; i += 1) begin
          for(int j = 7; j >= 0; j--) begin
            @(posedge m_vif.scl_in);
            rd_data[j] = m_vif.sda_in;
          end
          @(negedge m_vif.scl_in);
          m_vif.sda_oe <= 1;
        end
        @(negedge m_vif.scl_in);
        m_vif.sda_oe <= 0;
        state = stop;
      end
    
    stop :  
      begin
        stop_condition();  // drive stop condition 
        state = idle;
        seq_item_port.item_done();
      end
    default :
      begin
        state = idle;
      end
  endcase
  end
endtask: mst_drv_fsm

