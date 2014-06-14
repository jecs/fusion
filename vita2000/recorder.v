`default_nettype none

module recorder(
	par_clock,
	cam_d,
	FS,
	FE,
	INV,
	REC,
	we,
	pixels
);

	input wire par_clock;
	input wire [31:0] cam_d;

	input wire FS;
	input wire FE;
	input wire INV;
	input wire REC;
	
	output reg we;
	output reg [63:0] pixels;

	parameter IDLE = 3'b001;
	parameter CAPT = 3'b010;
	parameter LAST = 3'b100;
	reg [2:0] state = IDLE;
	reg [2:0] control;

	reg data_valid;
	reg [1:0] record_stage = 2'd0;

	always @(*) begin
		control = {FS, FE, INV};
		case(state)
			IDLE: data_valid = FS;
			CAPT: data_valid = REC;
			LAST: data_valid = REC;
			default: data_valid = 1'b0;
		endcase
	end

	always @(posedge par_cock) begin
		case(state)
			IDLE: casex(control)
				3'b0XX: state <= IDLE;
				3'b1XX: state <= CAPT;
			endcase
			CAPT: casex(control)
				3'bXX1: state <= IDLE;
				3'bX00: state <= CAPT;
				3'bX10: state <= LAST;
			endcase
			LAST: state <= IDLE;
			default: state <= IDLE;
		endcase

		if(data_valid) begin
			record_stage <= record_stage + 2'd1;
		end
		else begin
			record_stage <= 2'd0;
		end
		we <= data_valid & record_stage[0];
	end

	genvar i;
	generate
		for(i=0;i < 4;i=i+1) begin : ARRANGE
			always @(posedge par_clock) begin
				case(data_valid_count)
					2'd0: begin
						pixels[(63-16*i):(56-16*i)] <= cam_d[(8*i+7):8*i];
						pixels[(55-16*i):(48-16*i)] <= pixels[(55-16*i):(48-16*i)];
					end
					2'd1: begin
						pixels[(63-16*i):(56-16*i)] <= pixels[(63-16*i):(56-16*i)];
						pixels[(55-16*i):(48-16*i)] <= cam_d[(8*i+7):8*i];
					end
					2'd2: begin
						pixels[(16*i+7):(16*i)]    <= cam_d[(8*i+7):8*i];
						pixels[(16*i+15):(16*i+8)] <= pixels[(16*i+15):(16*i+8)];
					end
					2'd3: begin
						pixels[(16*i+7):(16*i)]    <= pixels[(16*i+7):(16*i)];
						pixels[(16*i+15):(16*i+8)] <= cam_d[(8*i+7):8*i];
					end
				endcase
			end
		end
	endgenerate
endmodule
