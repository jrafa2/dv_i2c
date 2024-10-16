/**
* Module: cic
* Cascaded Integrator-Comb filter.
* The sigmadelta modulation is based on oversampling and noise-shaping.
* The noise-shaping effect is responsible for increasing the noise
* power at high-frequencies, outside the signal bandwidth. To
* remove this noise, a decimation filter must be employed.
* This filter is usually composed of a Cascaded IntegratorComb (CIC) filter
* https://sbmicro.org.br/sforum-eventos/sforum2022/Design%20of%20a%20Digital%20CIC%20Filter%20for%20an%20Audio%20Sigma-Delta%20ADC%20in%20the%20Scilab%20Environment.pdf
*/
module cic #(
	parameter ORDER = 3,
	parameter MIN_DEC_RATE = 1,
	parameter MAX_DEC_RATE = 8,
	parameter INPUT_WIDTH = 8,
	parameter INPUT_FRAC_WIDTH = 7,
	parameter OUTPUT_WIDTH = 8,
	parameter OUTPUT_FRAC_WIDTH = 7
)

(
	input resetn,
	input clk,
	input clear,
	input enable,
	
	// Data Input
    input signed [INPUT_WIDTH-1:0] data_in,	
	input data_in_ready,
	input [$clog2($clog2(MAX_DEC_RATE+1))-1:0] filter_dec_factor,
	
	// Data Output
	output reg data_out_ready,
	output reg signed [OUTPUT_WIDTH-1:0] data_out
);


	localparam int FULL_WIDTH = INPUT_WIDTH + 9;
	localparam int INT0_WIDTH = FULL_WIDTH;
	localparam int INT1_WIDTH = FULL_WIDTH;
	localparam int INT2_WIDTH = FULL_WIDTH;
	localparam int COMB1_WIDTH = FULL_WIDTH;
	localparam int COMB2_WIDTH = FULL_WIDTH;
	localparam int TRUNC_LSB = COMB2_WIDTH - (INPUT_WIDTH - INPUT_FRAC_WIDTH) - OUTPUT_FRAC_WIDTH;
	
	// Internal variables
	reg signed [INT0_WIDTH-1:0] cic_int_0;
	reg signed [INT1_WIDTH-1:0] cic_int_1;
	reg signed [INT2_WIDTH-1:0] cic_int_2;
	reg signed [COMB1_WIDTH-1:0] cic_comb_1;
	reg signed [COMB2_WIDTH-1:0] cic_comb_2;
	logic signed [COMB1_WIDTH-1:0] cic_comb_out_1;
	logic signed [COMB2_WIDTH-1:0] cic_comb_out_2;
	reg [$clog2(MAX_DEC_RATE)-1:0] cic_dec_factor_counter;
	logic signed [OUTPUT_WIDTH-1:0] truncated_data_out;
	
	// Comb logic
	always_comb begin
		cic_comb_out_1 = cic_int_2 - cic_comb_1;
		cic_comb_out_2 = cic_comb_out_1 - cic_comb_2;
		
		truncated_data_out = cic_comb_out_2[(OUTPUT_WIDTH-1)+TRUNC_LSB:TRUNC_LSB];
		truncated_data_out += $unsigned(cic_comb_out_2[TRUNC_LSB-1]);
	end
	
	// Seq logic
	always_ff @(posedge clk, negedge resetn) begin
		if(!resetn) begin
			cic_dec_factor_counter <= 'd0;
			data_out_ready <= 1'b0;
			data_out <= 'sd0;
			cic_int_0 <= 'sd0;
			cic_int_1 <= 'sd0;
			cic_int_2 <= 'sd0;
			cic_comb_1 <= 'sd0;
			cic_comb_2 <= 'sd0;
		end else if(clear) begin
			cic_dec_factor_counter <= 'd0;
			data_out_ready <= 1'b0;
			data_out <= 'sd0;
			cic_int_0 <= 'sd0;
			cic_int_1 <= 'sd0;
			cic_int_2 <= 'sd0;
			cic_comb_1 <= 'sd0;
			cic_comb_2 <= 'sd0;
		end else if(enable) begin
			data_out_ready <= 1'b0;
			if(data_in_ready) begin
				case(filter_dec_factor)
					0: cic_int_0 <= cic_int_0 + (data_in <<< 9);
					1: cic_int_0 <= cic_int_0 + (data_in <<< 6);
					2: cic_int_0 <= cic_int_0 + (data_in <<< 3);
					default: cic_int_0 <= cic_int_0 + data_in;
				endcase
				cic_int_1 <= cic_int_1 + cic_int_0;
				cic_int_2 <= cic_int_2 + cic_int_1;
				if(cic_dec_factor_counter == (2**filter_dec_factor-1)) begin
					cic_dec_factor_counter <= 'd0;
					cic_comb_1 <= cic_int_2;
					cic_comb_2 <= cic_comb_out_1;
					cic_int_2 <= cic_int_1;
					data_out_ready <= 1'b1;
					data_out <= truncated_data_out;
				end else begin
					cic_dec_factor_counter <= cic_dec_factor_counter + 1'b1;
				end
			end
		end
	end
	
endmodule
