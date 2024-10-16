`ifndef _DUT_IF
`define _DUT_IF

interface dut_if();
  logic clk;		//chip clock
  logic reset_n;	//chip reset
  
  //other signals?
  
  tri1 sclk;
  tri1 sdata;   //be aware with inout signals. It is an opendrain that must be driven by someone continiuously
  
  //internal variables to manage inout signals
  logic sda_drive;			//I2C interface. data
  logic scl_drive;			//I2C interface. clock
      
  logic sda_val;
  logic scl_val;
  
  //glue logic
  assign sdata = sda_drive ? sda_val : 'z;
  assign sclk = scl_drive ? scl_val : 'z;

endinterface

`endif // _DUT_IF
