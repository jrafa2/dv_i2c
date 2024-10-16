module i2c_slave( 
  inout SDA,
  input SCL, rst_n,
  input [6:0] address,  //chip_id
  
  output reg[7:0] reg_addr,
  output reg wr1rd0,
  output reg[7:0] reg_wr_data,
  input reg[7:0] reg_rd_data,
  output reg reg_req
);

  reg [2:0] count;
  reg sda, sda_sense; // sda_sense is to sensetize sda in start and stop conditions to trigger logic otherwise stay insensetive.
  reg [7:0] chip_addr;
  wire sda_check;
  reg ACK;
  
  and a1(sda_check, SDA, sda_sense);
  
  enum reg[3:0] {IDLE, SAMPLE_BYTE_1, WR1, ACK1, SAMPLE_BYTE_2, ACK2, SAMPLE_BYTE_3, ACK3, ACK3_aux, SEND_BYTE_3_aux, SEND_BYTE_3} state;
  
  always_ff @(SCL, negedge rst_n) begin
    if(!rst_n) begin
      state <= IDLE;
      //dout <= 1'b0;
      wr1rd0 <= 1'b0;
      ACK <= 1'b0;
      count <= 7;
      //tx_reg <= 0;
      sda <= 1;
      chip_addr <= 0;
      reg_addr <= 0;
      reg_wr_data <= 0;
      reg_req <= 0;
    end else begin
      case(state)
        IDLE: begin
          if(SDA == 0 && SCL == 0) begin  //start condition
            state <= SAMPLE_BYTE_1;
            sda_sense <= 0;
          end else begin
            state <= IDLE;
          end
          ACK <= 0;
          count <= 7;
          chip_addr <= 0;
          reg_addr <= 0;
          reg_wr_data <= 0;
          reg_req <= 0;
        end  //IDLE
        
        SAMPLE_BYTE_1: begin
          if(SCL == 1) begin  //posedge
            chip_addr[count] <= SDA; 				//sample byte1
            if(count == 1) begin
              state <= WR1; 
            end
            count <= count - 1;
          end
        end //SAMPLE_BYTE1
        
        WR1 : begin
          if(SCL == 1) begin  //posedge
            if(chip_addr[7:1] == address) begin	//address chip?
                state <= ACK1; 
              end else begin
                state <= IDLE;
                count <= 7;
              end
           	  wr1rd0 <= SDA;
          end
        end
        
        ACK1 : begin
          if(SCL == 1) begin  //posedge
            state <= SAMPLE_BYTE_2;
            ACK <= 1;
            count <= 7;
          end
        end

        SAMPLE_BYTE_2: begin
          if(SCL == 1) begin  //posedge
            if(count == 0) begin
              state <= ACK2;
              count <= 7;
            end
            ACK <= 0;
            reg_addr[count] <= SDA;
            count <= count - 1;
          end
        end
        
        ACK2 : begin
          if(SCL == 1) begin  //posedge
            if(wr1rd0) begin
              state <= SAMPLE_BYTE_3;
              count <= 7;
            end else begin
              state <= SEND_BYTE_3_aux;
              reg_req <= 1;
              count <= 7;
            end
            ACK <= 1;
          end
        end
        
        SAMPLE_BYTE_3: begin
          if(SCL == 1) begin  //posedge
            if(count == 0) begin
              state <= ACK3;
              count <= 7;
              reg_req <= 1;
            end 
            ACK <= 0;
            reg_wr_data[count] <= SDA;
            count <= count - 1;
          end
        end
        
        ACK3: begin
          if(SCL == 1) begin  //posedge
            ACK <= 1;
            count <= 7;
            state <= IDLE;
          end
        end
        
        SEND_BYTE_3_aux: begin
          if(SCL == 0) begin  //negedge
            state <= SEND_BYTE_3;
            sda <= reg_rd_data[count];  //first bit
            count <= count - 1;
          end
        end
        
        SEND_BYTE_3: begin
          if(SCL == 0) begin  //negedge
            if(count == 0) begin
              sda_sense <= 1;
              sda <= 1;   //to set Z
              count <= 7;
              state <= ACK3_aux;
            end
            reg_req <= 0;
            sda <= reg_rd_data[count];
            count <= count - 1;
          end    
        end
        
        ACK3_aux: begin
          if(SCL == 0) begin  //negedge
            state <= ACK3;
          end
        end
        
      endcase
    end //if
  end   //always
        
  assign SDA = (sda == 1) ? 1'bz : 1'b0;
  
endmodule
