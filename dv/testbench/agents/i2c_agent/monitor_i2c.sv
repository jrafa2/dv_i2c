`ifndef _I2C_MON
`define _I2C_MON

class i2c_monitor extends uvm_monitor;
  `uvm_component_utils(i2c_monitor)

  uvm_analysis_port #(i2c_basic_tr) port;
  virtual dut_if dut_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    port = new("port", this);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    //assert(uvm_config_db#(virtual dut_if)::get(this, "", "dut_if", dut_vif));  
  endfunction
  
  task run_phase(uvm_phase phase);
    
  endtask : run_phase
  
endclass: i2c_monitor

`endif // _I2C_MON
