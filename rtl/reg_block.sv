/**
* Module: reg_block
* Register to control and read. It implements write and read operations
* https://www.edaplayground.com/x/4bmC
*/
module reg_block(
  input        rst_n,
  input        clk,
  input        req,
  input        wr_en,
  input  [7:0] addr,
  input  [7:0] wr_data,
  
  output logic [7:0] rd_data,
  
  input      signed [7:0] I_adc_data,
  output reg signed [7:0] O_coef0,
  output reg signed [7:0] O_coef1,
  output reg signed [7:0] O_coef2,
  output reg signed [7:0] O_coef_div,
  output reg [1:0] O_decimation_ratio,
  output reg O_conv_en
);
  localparam ADDR_COEF0    = 0;
  localparam ADDR_COEF1    = 1;
  localparam ADDR_COEF2    = 2;
  localparam ADDR_DIV      = 3;
  localparam ADDR_COEF_CIC = 4;
  localparam ADDR_CHIP_ID  = 5;
  localparam ADDR_CONTROL  = 6;
  localparam ADDR_OUTPUT   = 7;
  
  wire  [7:0] chip_id = 8'hA5;			//Read-only;
  
  // Write blocks
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      O_coef0 <= 8'sd01;
    end else begin
      if(req && wr_en && (addr == ADDR_COEF0)) begin
        O_coef0 <= wr_data;
      end
    end
  end
  
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      O_coef1 <= 8'sd00; 
    end else begin
      if(req && wr_en && (addr == ADDR_COEF1)) begin
        O_coef1 <= wr_data;
      end
    end
  end
  
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      O_coef2 <= 8'sd00;
    end else begin
      if(req && wr_en && (addr == ADDR_COEF2)) begin
        O_coef2 <= wr_data;
      end
    end
  end
  
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      O_coef_div <= 8'sd00;
    end else begin
      if(req && wr_en && (addr == ADDR_DIV)) begin
        O_coef_div <= wr_data;
      end
    end
  end
  
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      O_decimation_ratio <= 2'd01;
    end else begin
      if(req && wr_en && (addr == ADDR_COEF_CIC)) begin
        O_decimation_ratio <= wr_data[1:0];
      end
    end
  end
  
  always_ff@(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      O_conv_en <= 1'd00;
    end else begin
      if(req && wr_en && (addr == ADDR_CONTROL)) begin
        O_conv_en <= wr_data[0:0];
      end
    end
  end
  
  //Read block
  always_comb begin
    case(addr) inside
      ADDR_COEF0:    rd_data = O_coef0;
      ADDR_COEF1:    rd_data = O_coef1;
      ADDR_COEF2:    rd_data = O_coef2;
      ADDR_DIV:      rd_data = O_coef_div;
      ADDR_COEF_CIC: rd_data = {6'd0, O_decimation_ratio};
      ADDR_CHIP_ID:  rd_data = chip_id;
      ADDR_OUTPUT:   rd_data = I_adc_data;
      default:       rd_data = 'h0;	
    endcase
  end

endmodule
