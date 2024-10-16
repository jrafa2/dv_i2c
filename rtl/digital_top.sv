/**
* Module: digital_top
* Digital block of the chip. It will connect to the pins and analog block
*/
module digital_top(
  input wire reset_n,
  input wire clk,

  // I2C
  input wire sclk,
  inout wire sdata,
  
  // ADC
  output logic      adc_convert,    // convertion enabled
  input  logic      adc_ready,
  input  logic[7:0] adc_q           // adc value. Read after adc_ready
);
  
  wire   [6:0] i2c_addr = 1;        //i2c bus address

  wire         reg_wr1rd0;
  wire   [7:0] reg_wr_data;
  wire   [7:0] reg_rd_data;
  wire   [7:0] reg_address;
  wire         reg_req;
  wire         reg_ack;
  
  wire signed  [7:0] adc_filtered;
  wire         filtered_ready;
  
  wire signed  [7:0] O_coef0;
  wire signed  [7:0] O_coef1;
  wire signed  [7:0] O_coef2;
  wire signed  [7:0] O_div;
  wire   [1:0] O_decimation_ratio;
  wire   conv_en, cic_en, cic_clr, fir_en;

  reg_block u_regs(.rst_n(reset_n), .clk(clk),
                   .req(reg_req), .wr_en(reg_wr1rd0), .addr(reg_address), .wr_data(reg_wr_data), .rd_data(reg_rd_data),
                   .O_coef0(O_coef0), .O_coef1(O_coef1), .O_coef2(O_coef2), .O_coef_div(O_div),
                   .O_decimation_ratio(O_decimation_ratio), .O_conv_en(conv_en),
                   .I_adc_data(adc_filtered)
                  );
  
  i2c_slave u_i2c_slave(.SDA(sdata), .SCL(sclk), .rst_n(reset_n),
                        .address(i2c_addr),
                        .reg_addr(reg_address), .reg_wr_data(reg_wr_data), .wr1rd0(reg_wr1rd0), .reg_rd_data(reg_rd_data), .reg_req(reg_req));
  
  fsm u_fsm(.clk(clk), .rst_n(reset_n), 
            .conv_en(conv_en), 
            .adc_en(adc_convert),
            .cic_en(cic_en), .cic_clr(cic_clr),  
            .fir_en(fir_en)
           );
    
  datapath u_datapath(.clk(clk), .reset_n(reset_n),
                      .data_ready(adc_ready), .data_in(adc_q), .data_filtered(adc_filtered), .filtered_ready(filtered_ready),
                      .cic_en(cic_en), .fir_en(fir_en), .clr_cic(cic_clr),
                      .coef0(O_coef0), .coef1(O_coef1), .coef2(O_coef2), .div(O_div), .decimation_ratio(O_decimation_ratio)
                     );

endmodule : digital_top
