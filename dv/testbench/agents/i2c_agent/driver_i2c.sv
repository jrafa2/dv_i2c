`ifndef _I2C_DRV
`define _I2C_DRV

class i2c_driver extends uvm_driver #(i2c_basic_tr);
  //i2c_basic_tr req;
  
  `uvm_component_utils(i2c_driver)

  virtual dut_if dut_vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
  endfunction : build_phase
  
  function void connect_phase(uvm_phase phase);
    assert(uvm_config_db#(virtual dut_if)::get(this, "", "dut_if", dut_vif));  
  endfunction

  task run_phase(uvm_phase phase);
    //...
  endtask : run_phase
  
  local task set_start();
    dut_vif.sda_drive = 1;
    dut_vif.scl_val = 1;
    dut_vif.sda_val = 0;
    #(period_ns*1ns);
    dut_vif.scl_val = 0;
    #(period_ns*1ns);
  endtask
        
  local task set_byte(logic[7:0] b);		//we assume SCLK=0, toggle data in posedge
    dut_vif.sda_drive = 1;  //get the use of the data line
    repeat(8) begin
      dut_vif.sda_val = b[7];
      b = b << 1;
      //...
    end
    dut_vif.sda_drive = 0;  //allow slave to set ACK
  endtask
  
  local task get_ack(output logic ack);
  endtask
        
  local task set_stop();
  endtask
  
  local task set_ack(logic ack = 1);
  endtask
  
endclass: i2c_driver

`endif // _I2C_DRV
