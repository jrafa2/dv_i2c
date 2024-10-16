/**
* Module: datapath
* Receives the raw data and process with a CIC and FIR filter
*/
module datapath (
  input clk, 
  input reset_n, 
  
  input data_ready, 
  input  signed [7:0] data_in, 
  output signed [7:0] data_filtered,
  output filtered_ready,
  
  input cic_en,
  input fir_en,
  input clr_cic,
  
  input signed [7:0] coef0,
  input signed [7:0] coef1,
  input signed [7:0] coef2,
  input signed [7:0] div,
  input signed [1:0] decimation_ratio
);
  wire signed [7:0] data_cic;
  wire cic_ready;
  
  cic cic_u(.clk(clk), .resetn(reset_n), .clear(clr_cic), .enable(cic_en),	//control signals
            .data_in_ready(data_ready), .data_in(data_in), .filter_dec_factor(decimation_ratio),  //inputs
            .data_out_ready(cic_ready), .data_out(data_cic)                 //outputs
            );
  
  fir fir_u(.clk(clk), .reset_n(reset_n), .enable(fir_en),                  //control signals
            .in_ready(cic_ready), .data_in(data_cic),                       //inputs
            .coef0(coef0), .coef1(coef1), .coef2(coef2), 
            .div(div),
            .data_out(data_filtered), .out_ready(filtered_ready)            //outputs
           );
  
endmodule
