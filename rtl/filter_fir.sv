/**
* Module: fir
* FIR filter
* Digital filter to select some frequencies and attenuate others.
*/
module fir  #(parameter WIDTH = 8)(
  input clk, 
  input reset_n, 
  input enable,
  
  input                          in_ready, 
  input  signed [WIDTH-1:0]      data_in, 
  output reg signed [WIDTH-1:0]  data_out,
  output reg                     out_ready,
  
  input  signed [WIDTH-1:0]      coef0,
  input  signed [WIDTH-1:0]      coef1,
  input  signed [WIDTH-1:0]      coef2,
  
  input  signed [WIDTH-1:0]       div
);
  
  localparam ACCUM_WIDTH      = WIDTH+WIDTH+WIDTH+2;   //result is bigger than operands
  localparam ACCUM_FRAC_WIDTH = (WIDTH-1)+(WIDTH-1)+(WIDTH-1);
  
  reg [WIDTH-1:0] data_in_reg[0:1];        //internal buffer for previous inputs
  logic signed [ACCUM_WIDTH-1:0] accum_data;
  
  // Filter implementation
  always_comb begin
    if(enable && in_ready) begin
      accum_data <= coef0 * data_in + coef1 * data_in_reg[0] + coef2 * data_in_reg[1];
    end
    else begin
      accum_data <= 'sd0;
    end
  end

  // Shifting and output
  always @(posedge clk, negedge reset_n) begin
    if(!reset_n) begin
      data_in_reg[0] <= 0;
      data_in_reg[1] <= 0;
      data_out <= 'd0;
      out_ready <= 1'b0;
    end else if(enable && in_ready) begin
      data_in_reg[1] <= data_in_reg[0];
      data_in_reg[0] <= data_in;
      
      //data_out <= accum_data >>> (ACCUM_FRAC_WIDTH-(WIDTH-1));
      data_out <= accum_data >>> div;
      
      out_ready <= 1'b1;
    end else if(!enable) begin
      data_in_reg[0] <= 0;
      data_in_reg[1] <= 0;
      data_out <= 'd0;
      out_ready <= 1'b0;
    end else begin
      //out_ready <= 1'b0;
    end
  end
  
endmodule : fir
