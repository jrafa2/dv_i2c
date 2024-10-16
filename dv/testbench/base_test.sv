`include "environment.sv"

class base_test extends uvm_test;
  
  environment env;
  
  `uvm_component_utils(base_test)
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    //create environment
  endfunction
  
endclass
