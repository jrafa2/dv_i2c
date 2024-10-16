// https://dvcon-proceedings.org/wp-content/uploads/Modeling-Analog-Devices-using-SV-RNM-1.pdf
module adc_dms_model #(parameter nlevels = 8)(
  input  logic      clk,
  input  logic      rst_n,
  input  real       v_in,
  input  real       v_ref,
  input  logic      enable,
  
  output logic      data_ready,
  output logic[nlevels-1:0] adc_q
);
  real delta;
  parameter real v_zero = 0;
  reg [nlevels-1:0] V_conv;
  bit use_delay = 0;
  
  assign delta = real'((v_ref-v_zero) / real'(2**nlevels)); 

  initial begin
    if($test$plusargs("ADC_DELAY")) begin
      use_delay = 1;
    end
  end
  
  always @ (posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      adc_q <= 0;
      data_ready <= 0;
    end else if(enable) begin
      data_ready = 0;
      
      if (v_in >= v_ref) begin
          V_conv <= '1;
      end else if (v_in == v_zero) begin
          V_conv = '0;
      end else if ((v_zero < v_in) && (v_in < v_ref)) begin
          V_conv <= v_in / delta;
      end else begin
          V_conv <= 'X;
      end

      if(use_delay) begin
      	repeat(nlevels) @(posedge clk);
      end
      
      if(!$isunknown(V_conv)) begin
        adc_q <= V_conv;
        data_ready = 1;
      end
    end else begin
      adc_q <= 0;
      data_ready = 0;
    end
  end

endmodule : adc_dms_model
