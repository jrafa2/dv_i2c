import uvm_pkg::*;
`include "uvm_macros.svh"

`include "dut_if.sv"
`include "lib_test.sv"
//`include "adc_dms_model.sv"

module top;
  //dut if instance
  
  //dut instance
  
  //other instances?
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    $shm_open("waves.shm");
    $shm_probe("ASM");
	//reset?
  end
  
  initial begin
	//interface to database?
    run_test(); //+UVM_TESTNAME=test_dummy
  end
    
endmodule : top
