
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
  i2c_slv_seq_item  m_slv_seq_h;
  
  //virtual interface declaration
  virtual i2c_if m_vif;
  
  //Analysis Port declaration
  uvm_analysis_port #(i2c_slv_seq_item) m_slv_an_port_h;
  
  bit [7:0] info_byte;

  extern function new(string name = "", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task check_start();
  extern task check_stop();
  extern task get_info();
  extern task mon_fsm();

endclass: i2c_bus_monitor
`endif

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

  m_slv_seq_h = i2c_slv_seq_item::type_id::create("m_slv_seq_h", this);
  
endfunction: build_phase
  
// --------------------------------------------------------------------------

task i2c_bus_monitor::run_phase(uvm_phase phase); 
  forever begin
    mon_fsm();
  end
endtask: run_phase

// --------------------------------------------------------------------------

task i2c_bus_monitor::check_start();
  @(negedge m_vif.sda_in);
  if(m_vif.scl_in == 1) begin
    m_slv_seq_h.state = addr_rw; // else what 
  end
endtask: check_start

// --------------------------------------------------------------------------

task i2c_bus_monitor::check_stop();
  @(posedge m_vif.sda_in);
  if(m_vif.scl_in == 1) begin
    m_slv_seq_h.state = start;
  end
endtask: check_stop

// --------------------------------------------------------------------------

task i2c_bus_monitor::get_info();
  for(int i = 7; i >= 0; i -= 1) begin
    fork
      begin
        @(posedge m_vif.scl_in);
        info_byte[i] = m_vif.sda_in;
        `uvm_info("get_info1", $sformatf("SDA_IN : %b for %d", m_vif.sda_in, i), UVM_NONE) 
        
        
        @(negedge m_vif.scl_in);
        if(info_byte[i] == m_vif.sda_in) begin
          // data stable 
        end
        else begin
          // data not stable
        end
        
      end
      begin
        @(posedge m_vif.scl_in);
        check_start();
      end
      
      begin
        @(posedge m_vif.scl_in);
        check_stop();
      end

    join_any
    disable fork;
  end
endtask

// --------------------------------------------------------------------------

task i2c_bus_monitor::mon_fsm();
  case(m_slv_seq_h.state)
    start:
      begin
        check_start();
      end
      
    addr_rw:
      begin
        get_info();
        {m_slv_seq_h.m_slv_addr, m_slv_seq_h.kind_e} = info_byte; 
        `uvm_info("MON", $sformatf("Info: %b ", info_byte), UVM_NONE)
        
        m_slv_seq_h.state = slv_addr_ack_nack;
        m_slv_an_port_h.write(m_slv_seq_h); 
      end
      
    slv_addr_ack_nack:
      begin
        fork
          begin
            @(posedge m_vif.scl_in);
            m_slv_seq_h.m_ack = m_vif.sda_in;
            @(negedge m_vif.scl_in);
            if(m_slv_seq_h.m_ack == m_vif.sda_in) begin
              // data stable 
            end
            else begin
              // data not stable
            end
          end
          check_start();
          check_stop();
        join_any
        disable fork;

        // check ack or nack
        if(m_slv_seq_h.m_ack == 0) begin
          m_slv_seq_h.state = reg_addr;
        end
        else begin
          fork
            check_start();
            check_stop();
          join_any
          disable fork;
        end
      end
      
    reg_addr:
      begin
        get_info();
        m_slv_seq_h.m_reg_addr = info_byte;
        m_slv_an_port_h.write(m_slv_seq_h); 
        m_slv_seq_h.state = ack_nack;
      end
     
    ack_nack:
      begin
        fork
          begin
            @(posedge m_vif.scl_in);
            m_slv_seq_h.m_ack = m_vif.sda_in;
            @(negedge m_vif.scl_in);
            if(m_slv_seq_h.m_ack == m_vif.sda_in) begin
              // data stable 
            end
            else begin
              // data not stable
            end
          end
          check_start();
          check_stop();
        join_any
        disable fork;

        // check ack or nack
        if(m_slv_seq_h.m_ack == 0) begin
          if(m_slv_seq_h.kind_e) begin
            m_slv_seq_h.state = data_rd;
          end
          else begin
            m_slv_seq_h.state = data_wr;
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

    data_wr:
      begin
        fork
          check_start();
          check_stop();
          begin
            get_info();
            m_slv_seq_h.m_data = info_byte;
            m_slv_seq_h.state = ack_nack;
            m_slv_an_port_h.write(m_slv_seq_h); 
          end
        join_any
        disable fork;
      end
      
    data_rd:
      begin
        get_info();
        m_slv_seq_h.m_data = info_byte;
        m_slv_seq_h.state = ack_nack_rd;
        m_slv_an_port_h.write(m_slv_seq_h); 
      end
      
    ack_nack_rd:
      begin
        fork
          begin
            @(posedge m_vif.scl_in);
            m_slv_seq_h.m_ack = m_vif.sda_in;
            @(negedge m_vif.scl_in);
            if(m_slv_seq_h.m_ack == m_vif.sda_in) begin
              // data stable 
            end
            else begin
              // data not stable
            end
          end
          check_start();
          check_stop();
        join_any
        disable fork;
        
        if(m_slv_seq_h.m_ack == 0) begin
          m_slv_seq_h.state = data_rd;
        end
        else begin 
          check_stop();
        end
      end
      
  endcase
endtask
