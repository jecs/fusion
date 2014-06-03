// NOTES TO SELF: 
// - Create dwt_disabled signal
// - Change behavior of dwt toggle to trigger when
//   first run is finished or when execution is finished

`default_nettype none

module arbiter3(
	clock,
	reset,
	dwt_read_addr,
	dwt_write_addr,
	display_read_addr,
	dwt_write_data,
	dwt_we,
	dwt_toggle_on,
	dwt_toggle_off,
	dwt_transposing,
   dwt_disabled,
	dwt_read_data,
	display_read_data
);

	parameter ADDR_BW = 18;

	input wire clock;
	input wire reset;
	input wire [ADDR_BW-1:0] dwt_read_addr;
	input wire [ADDR_BW-1:0] dwt_write_addr;
	input wire [ADDR_BW-1:0] display_read_addr;
	input wire [7:0] dwt_write_data;
	input wire dwt_we;
	input wire dwt_toggle_on;
	input wire dwt_toggle_off;
	input wire dwt_transposing;
   input wire dwt_disabled;
	output reg [7:0] dwt_read_data;
	output reg [7:0] display_read_data;
	
	// 2 memory modules
	reg [ADDR_BW-1:0] mem1_a_addr;
	reg [7:0] mem1_a_write_data;
	wire [7:0] mem1_a_read_data;
	reg mem1_a_we;
	
	reg [ADDR_BW-1:0] mem1_b_addr;
	reg [7:0] mem1_b_write_data;
	wire [7:0] mem1_b_read_data;
	reg mem1_b_we;
	
	reg [ADDR_BW-1:0] mem2_a_addr;
	reg [7:0] mem2_a_write_data;
	wire [7:0] mem2_a_read_data;
	reg mem2_a_we;
	
	reg [ADDR_BW-1:0] mem2_b_addr;
	reg [7:0] mem2_b_write_data;
	wire [7:0] mem2_b_read_data;
	reg mem2_b_we;
	
	reg [ADDR_BW-1:0] mem3_a_addr;
	reg [7:0] mem3_a_write_data;
	wire [7:0] mem3_a_read_data;
	reg mem3_a_we;
	
	reg [ADDR_BW-1:0] mem3_b_addr;
	reg [7:0] mem3_b_write_data;
	wire [7:0] mem3_b_read_data;
	reg mem3_b_we;
	
	// state variables
	parameter WRITING = 1'b1;
	parameter IDLE    = 1'b0;
	reg state = IDLE;
	
	always @(*) begin
		// 1
		mem1_a_addr = display_read_addr;
		mem1_a_write_data = 8'd0;
		mem1_a_we = 1'b0;
		
		mem1_b_addr = dwt_read_addr;
		mem1_b_write_data = 8'd0;
		mem1_b_we = 1'b0;
	
		// 2
		mem2_a_addr = dwt_read_addr;
		mem2_a_write_data = 8'd0;
		mem2_a_we = 1'b0;
		
		mem2_b_addr = dwt_write_addr;
		mem2_b_write_data = dwt_write_data;
		mem2_b_we = ~dwt_transposing & dwt_we;
		
		// 3
		case (state)
			IDLE: mem3_a_addr = display_read_addr;
			WRITING: mem3_a_addr = dwt_read_addr;
		endcase
		mem3_a_write_data = 8'd0;
		mem3_a_we = 1'b0;
		
		mem3_b_addr = dwt_write_addr;
		mem3_b_write_data = dwt_write_data;
		mem3_b_we = dwt_transposing & dwt_we;
		
		// read data
		case(state)
			IDLE: dwt_read_data = mem1_b_read_data;
			WRITING: begin
				if(dwt_transposing == 1'b1) begin
					dwt_read_data = mem2_a_read_data;
				end
				else begin
					dwt_read_data = mem3_a_read_data;
				end
			end
		endcase


		if(dwt_disabled == 1'b1 || state == WRITING) begin
			display_read_data = mem1_a_read_data;
		end
		else begin
			display_read_data = mem3_a_read_data;
		end
	end
	
	always @(posedge clock) begin
		if(reset) begin
			state <= IDLE;
		end
		else case(state)
			IDLE: state <= (dwt_toggle_on == 1'b1) ? WRITING : IDLE;
			WRITING: state <= (dwt_toggle_off == 1'b1) ? IDLE : WRITING;
			default: state <= IDLE;
		endcase
	end
	
	lena_source mem1
	(
		.clka(clock),
		.wea(mem1_a_we),
		.addra(mem1_a_addr),
		.dina(mem1_a_write_data),
		.douta(mem1_a_read_data),
		.clkb(clock),
		.web(mem1_b_we),
		.addrb(mem1_b_addr),
		.dinb(mem1_b_write_data),
		.doutb(mem1_b_read_data)
	);
	
	lena_source mem2
	(
		.clka(clock),
		.wea(mem2_a_we),
		.addra(mem2_a_addr),
		.dina(mem2_a_write_data),
		.douta(mem2_a_read_data),
		.clkb(clock),
		.web(mem2_b_we),
		.addrb(mem2_b_addr),
		.dinb(mem2_b_write_data),
		.doutb(mem2_b_read_data)
	);
	
	lena_source mem3
	(
		.clka(clock),
		.wea(mem3_a_we),
		.addra(mem3_a_addr),
		.dina(mem3_a_write_data),
		.douta(mem3_a_read_data),
		.clkb(clock),
		.web(mem3_b_we),
		.addrb(mem3_b_addr),
		.dinb(mem3_b_write_data),
		.doutb(mem3_b_read_data)
	);
endmodule
