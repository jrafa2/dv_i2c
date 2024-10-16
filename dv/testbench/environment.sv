class environment extends uvm_env;  
  `uvm_component_utils(environment)
  
  //agents

  virtual dut_if dut_vif;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction
	
  function void build_phase(uvm_phase phase);
	//create other agents
  endfunction

  function void connect_phase(uvm_phase phase);
    //get interface from database 
  endfunction
endclass : environment
