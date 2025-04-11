/////////////////////////////////////////////////////////////////
//  file name   : i2c_bus_mon.sv
//  module name : i2c_bus_monitor class
//////////////////////////////////////////////////////////////////

`ifndef i2c_bus_monitor
`define i2c_bus_monitor

class i2c_bus_monitor extends uvm_monitor;

  //Factory Registration
  `uvm_component_utils(i2c_bus_monitor)

  //handle of seq_item (transaction class)
  i2c_slv_seq_item  m_slv_trans_h;
  
  //virtual interface declaration
  virtual i2c_if m_vif;
  
  //Analysis Port declaration
  uvm_analysis_port #(i2c_slv_seq_item) m_slv_an_port_h;
  
  // bit [7:0] info_byte;

  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task check_start();
  extern task check_stop();
  extern task get_info(output bit [7:0] info_byte);
  extern task mon_fsm();

endclass: i2c_bus_monitor

// --------------------------------------------------------------------------
function i2c_bus_monitor::new(string name = "", uvm_component parent = null);
  super.new(name, parent);
  m_slv_an_port_h = new("m_slv_an_port_h", this);
endfunction
  
// --------------------------------------------------------------------------
function void i2c_bus_monitor::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  //get virtual interface 
  if(!uvm_config_db #(virtual i2c_if)::get(this, "", "m_vif", m_vif)) begin
    `uvm_fatal(get_full_name(), "Master Interface is not available")
  end

  m_slv_trans_h = i2c_slv_seq_item::type_id::create("m_slv_trans_h", this);
  
endfunction: build_phase
  
// --------------------------------------------------------------------------
task i2c_bus_monitor::run_phase(uvm_phase phase); 
  forever begin
    mon_fsm();
  end
endtask: run_phase

// --------------------------------------------------------------------------
task i2c_bus_monitor::check_start();
  forever begin
    @(negedge m_vif.sda_in);
    if(m_vif.scl_in == 1) begin
      m_slv_trans_h.m_state = ADDR_RW;
      break;
    end
  end
endtask: check_start

// --------------------------------------------------------------------------
task i2c_bus_monitor::check_stop();
  forever begin
    @(posedge m_vif.sda_in);
    if(m_vif.scl_in == 1) begin
      m_slv_trans_h.m_state = START;
      break;
    end
  end
endtask: check_stop

// --------------------------------------------------------------------------
task i2c_bus_monitor::get_info(output bit [7:0] info_byte);
  fork
    for(int i = 7; i >= 0; i -= 1) begin
      @(posedge m_vif.scl_in);
      info_byte[i] = m_vif.sda_in;
        
      @(negedge m_vif.scl_in);
      if(info_byte[i] == m_vif.sda_in) begin
          // data stable 
      end
      else begin
        `uvm_error(get_type_name(), "DATA IS NOT STABLE DURING HIGH PERIOD OF CLK")
      end
    end
      
    check_start();
    check_stop();
  join_any
  disable fork;
endtask

// --------------------------------------------------------------------------
task i2c_bus_monitor::mon_fsm();
  case(m_slv_trans_h.m_state)
    START:
      begin
        check_start();
      end
      
    ADDR_RW:
      begin
        bit [7:0] info_byte;
        //get_info({m_slv_trans_h.m_slv_addr, m_slv_trans_h.m_kind});
        get_info(info_byte);
        {m_slv_trans_h.m_slv_addr, m_slv_trans_h.m_kind} = info_byte; 
        // `uvm_info("INFO_MON - Get addr_rw", $sformatf("Info: %b ", info_byte), UVM_LOW)
        
        m_slv_trans_h.m_state = SLV_ADDR_ACK_NACK;
        m_slv_an_port_h.write(m_slv_trans_h); 
      end
      
    SLV_ADDR_ACK_NACK:
      begin
        fork
          begin
            @(posedge m_vif.scl_in);
            m_slv_trans_h.m_ack_nack = m_vif.sda_in;
            @(negedge m_vif.scl_in);
            if(m_slv_trans_h.m_ack_nack == m_vif.sda_in) begin
              `uvm_info(get_type_name(), $sformatf("ACK_NACK - %b is stable", 
              m_slv_trans_h.m_ack_nack), UVM_LOW) 
            end
            else begin
              `uvm_error(get_type_name(), "DATA IS NOT STABLE DURING HIGH PERIOD OF CLK")
            end
          end
          check_start();
          check_stop();
        join_any
        disable fork;

        // check ack or nack
        if(m_slv_trans_h.m_ack_nack == 0) begin
          m_slv_trans_h.m_state = REG_ADDR;
        end
        else begin
          fork
            check_start();
            check_stop();
          join_any
          disable fork;
        end
      end
      
    REG_ADDR:
      begin
        get_info(m_slv_trans_h.m_reg_addr);
        // m_slv_trans_h.m_reg_addr = info_byte;
        m_slv_an_port_h.write(m_slv_trans_h); 
        m_slv_trans_h.m_state = REG_ADDR_ACK_NACK;
      end
     
    REG_ADDR_ACK_NACK:
      begin
        fork
          begin
            @(posedge m_vif.scl_in);
            m_slv_trans_h.m_ack_nack = m_vif.sda_in;
            @(negedge m_vif.scl_in);
            if(m_slv_trans_h.m_ack_nack == m_vif.sda_in) begin
              `uvm_info(get_type_name(), $sformatf("ACK_NACK - %b is stable", 
              m_slv_trans_h.m_ack_nack), UVM_LOW) 
            end
            else begin
              `uvm_error(get_type_name(), "DATA IS NOT STABLE DURING HIGH PERIOD OF CLK")
            end
          end
          check_start();
          check_stop();
        join_any
        disable fork;

        // check ack or nack
        if(m_slv_trans_h.m_ack_nack == 0) begin
          if(m_slv_trans_h.m_kind) begin
            m_slv_trans_h.m_state = DATA_RD;
          end
          else begin
            m_slv_trans_h.m_state = DATA_WR;
          end 
        end
        else begin
          fork
            check_start();
            check_stop();
          join_any
          disable fork;
        end
      end

    DATA_WR:
      begin
        fork
          check_start();
          check_stop();
          begin
            get_info(m_slv_trans_h.m_data);
            // m_slv_trans_h.m_data = info_byte;
            m_slv_trans_h.m_state = ACK_NACK_WR;
            m_slv_an_port_h.write(m_slv_trans_h); 
          end
        join_any
        disable fork;
      end

     ACK_NACK_WR:
      begin
        fork
          begin
            @(posedge m_vif.scl_in);
            m_slv_trans_h.m_ack_nack = m_vif.sda_in;
            @(negedge m_vif.scl_in);
            if(m_slv_trans_h.m_ack_nack == m_vif.sda_in) begin
              `uvm_info(get_type_name(), $sformatf("ACK_NACK - %b is stable", 
              m_slv_trans_h.m_ack_nack), UVM_LOW) 
            end
            else begin
              `uvm_error(get_type_name(), "DATA IS NOT STABLE DURING HIGH PERIOD OF CLK")
            end
          end
          check_start();
          check_stop();
        join_any
        disable fork;

        // check ack or nack
        if(m_slv_trans_h.m_ack_nack == 0) begin
          m_slv_trans_h.m_state = DATA_WR;
        end
        else begin
          fork
            check_start();
            check_stop();
          join_any
          disable fork;
        end
      end
 
    DATA_RD:
      begin
        get_info(m_slv_trans_h.m_data);
        // m_slv_trans_h.m_data = info_byte;
        m_slv_trans_h.m_state = ACK_NACK_RD;
        m_slv_an_port_h.write(m_slv_trans_h); 
      end
      
    ACK_NACK_RD:
      begin
        fork
          begin
            @(posedge m_vif.scl_in);
            m_slv_trans_h.m_ack_nack = m_vif.sda_in;
            @(negedge m_vif.scl_in);
            if(m_slv_trans_h.m_ack_nack == m_vif.sda_in) begin
              // data stable 
              `uvm_info(get_type_name(), $sformatf("ACK_NACK - %b is stable", 
              m_slv_trans_h.m_ack_nack), UVM_LOW) 
            end
            else begin
              `uvm_error(get_type_name(), "DATA IS NOT STABLE DURING HIGH PERIOD OF CLK")
            end
          end
          check_start();
          check_stop();
        join_any
        disable fork;
        
        if(m_slv_trans_h.m_ack_nack == 0) begin
          m_slv_trans_h.m_state = DATA_RD;
        end
        else begin 
          check_stop();
        end
      end
      
  endcase
endtask
`endif
