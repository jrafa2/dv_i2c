/**
* Module: fsm
* Finite States Machine.
* It controls the digital filters and ADC based on register values
*/
module fsm(
  input        clk,
  input        rst_n,
  
  input        conv_en,
  
  output reg adc_en,
  output reg cic_en,
  output reg cic_clr,
  output reg fir_en
);
  
  enum reg {IDLE, ACTIVE} state;

  // FSM block
  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      state <= IDLE;
      adc_en <= 1'b0;
      cic_en <= 1'b0;
      fir_en <= 1'b0;
      cic_clr <= 1'b0;  //unused
    end else begin
      case(state)
        IDLE: begin
          if(conv_en) begin
            state <= ACTIVE;
            adc_en <= 1'b1;
            cic_en <= 1'b1;
            fir_en <= 1'b1;
          end
        end
        ACTIVE: begin
          if(!conv_en) begin
            state <= IDLE;
            adc_en <= 1'b0;
            cic_en <= 1'b0;
            fir_en <= 1'b0;
          end
        end
        default: begin
          state <= IDLE;
          adc_en <= 1'b0;
          cic_en <= 1'b0;
          fir_en <= 1'b0;
        end
      endcase
    end
  end
  
endmodule
