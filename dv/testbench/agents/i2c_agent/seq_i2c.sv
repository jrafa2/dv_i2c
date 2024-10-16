`ifndef _I2C_SEQ
`define _I2C_SEQ

`include "transaction_i2c.sv"

class i2c_basic_seq extends uvm_sequence#(i2c_basic_tr);
  //data?
  
  `uvm_object_utils(i2c_basic_seq)
  
  function new(string name = "i2c_basic_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "i2c_basic_seq created", UVM_LOW)
	//...
  endtask : body
endclass : i2c_basic_seq

`endif // _I2C_SEQ
