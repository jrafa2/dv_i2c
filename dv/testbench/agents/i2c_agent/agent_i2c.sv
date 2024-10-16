`ifndef _I2C_AGT
`define _I2C_AGT

`include "transaction_i2c.sv"
`include "monitor_i2c.sv"
`include "driver_i2c.sv"

class i2c_agent extends uvm_agent;
  `uvm_component_utils(i2c_agent)
    
  //instanciate components
    
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
    
  function void build_phase(uvm_phase phase);
    //create components
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    //connect driver
  endfunction : connect_phase
    
  task run_phase(uvm_phase phase);
  endtask : run_phase
endclass : i2c_agent

`endif  // _I2C_AGT
