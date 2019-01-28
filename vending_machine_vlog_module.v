`define INFO
`define DEBUG

module vending_machine(c1, c2, in0, in1, in2, in3, cnl, pdt, cng, rtn,
	         	item0_available, item1_available, item2_available,
			item3_available, rst, clk);
	reg [5:0] state, nextstate; 

	/* Vending machine inputs */
   	input c1, c2, in0, in1, in2, in3, cnl;
	input item0_available, item1_available, item2_available, item3_available;

   	input rst;
	input clk;

	/* Vending machine outputs  */
	output reg pdt;
	output reg [2:0] cng;
	output reg [2:0] rtn;

	/* Vending machine inner variables  */
	reg [2:0] coincount;

	/***** Vending machine state declaration - standard encoding *****/
	/*** Stage 1 item selection ***/
	localparam [5:0] 
		IDLE	  = 5'h00,
		ITEM0_IN0 = 5'h01,
		ITEM1_IN1 = 5'h02,
		ITEM2_IN2 = 5'h03,
		ITEM3_IN3 = 5'h04; 

	/*** Stage 2 waiting states ***/
	localparam [5:0]
       		WAITING_0 = 5'h05,
		WAITING_1 = 5'h06,
		WAITING_2 = 5'h07,
		WAITING_3 = 5'h08;

	/** Stage 3 coin insertion **/
	localparam [5:0]
		ST0  = 5'h09, 
		ST1  = 5'h0A,
		ST2  = 5'h0B,
		ST3  = 5'h0C,
		ST4  = 5'h0D,
		ST5  = 5'h0E,
		ST6  = 5'h0F,
		ST7  = 5'h10;

	localparam [5:0] CNL_ST = 5'h11;

	/* Stage 4 release item  */
	localparam [5:0]
 		VAFLA_BOROVEC 	= 5'h12,
		ZLATNA_ARDA   	= 5'h13,
		SLANINA		      = 5'h14,
		PATRON_VODKA	  = 5'h15;

	/* Variables initialization */
	initial begin
		coincount = 3'b000;
	`ifdef INFO
		$display("Variable Initialization Completed!");
	`endif
	end

	/* Always block to update state */
	always @(posedge clk, negedge rst)
	begin
		if (rst)
			state <= IDLE;
		else 
			state <= nextstate;
	end

	/* Always block to compute nextstate */
	always @(state, c1, c2, in0, in1, in2, in3, cnl)
	begin
		nextstate = state;
		case(state)
			IDLE:
			begin
				if(in0 & !in1 & !in2 & !in3)
					nextstate = ITEM0_IN0;
				else if (!in0 & in1 & !in2 & !in3)	
					nextstate = ITEM1_IN1;
				else if (!in0 & !in1 & in2 & !in3)	
					nextstate = ITEM2_IN2;
				else if (!in0 & !in1 & !in2 & in3)	
					nextstate = ITEM3_IN3;
				else
					nextstate = IDLE;
			end
			
			ITEM0_IN0:
			begin
				if (item0_available)
					nextstate = WAITING_0;
				else
					begin
						$display("No Vafla Borovec available!");
						nextstate = IDLE;
					end
			end

			ITEM1_IN1:
			begin
				if (item1_available)
					nextstate = WAITING_1;
				else
					begin
						$display("No Patron Vodka available!");
						nextstate = IDLE;
					end
			end

			ITEM2_IN2:
			begin
				if (item2_available)
					nextstate = WAITING_2;
				else
					begin
						$display("No Zlatna Arda available!");
						nextstate = IDLE;
					end
			end
			
			ITEM3_IN3:
			begin
				if (item3_available)
					nextstate = WAITING_3;
				else
					begin
						$display("No Slanina available!");
						nextstate = IDLE;
					end
			end
			
			WAITING_0:
			begin
				pdt = 1'b0;
				cng = 3'b000;
				if (coincount > 2)
					nextstate = VAFLA_BOROVEC;
				else if (c1 & !c2 & (coincount < 3))
					nextstate = ST0;
				else if (!c1 & c2 & (coincount < 3))
					nextstate = ST1;
				else if (cnl)
					nextstate = CNL_ST;
			end

			WAITING_1:
			begin
				if (coincount > 3)
					nextstate = PATRON_VODKA;
				if (c1 & !c2 & (coincount < 4))
					nextstate = ST2;	
				if (!c1 & c2 & (coincount < 4))
					nextstate = ST3;
				if (cnl)
					nextstate = CNL_ST;
			end

			WAITING_2:
			begin
				pdt = 1'b0;
				cng = 3'b000;
				if (coincount > 4)
					nextstate = ZLATNA_ARDA;
				if (c1 & !c2 & (coincount < 5))
					nextstate = ST4;	
				if (!c1 & c2 & (coincount < 5))
					nextstate = ST5;
				if (cnl)
					nextstate = CNL_ST;		
			end
			
			WAITING_3:
			begin
				if (coincount > 5)
					nextstate = SLANINA;
				if (c1 & !c2 & (coincount < 6))
					nextstate = ST6;	
				if (!c1 & c2 & (coincount < 6))
					nextstate = ST7;
				if (cnl)
					nextstate = CNL_ST;		
			end

			ST0:
				nextstate = WAITING_0;

			ST1:
				nextstate = WAITING_0;

			ST2:
				nextstate = WAITING_1;

			ST3:
				nextstate = WAITING_1;

			ST4:
				nextstate = WAITING_2;

			ST5:
				nextstate = WAITING_2;

			ST6:
				nextstate = WAITING_3;

			ST7:
				nextstate = WAITING_3;

			VAFLA_BOROVEC:
			begin
	`ifdef DEBUG
				$display("VAFLA_BOROVEC");
	`endif
				nextstate = IDLE; 
			end
			
			PATRON_VODKA:
			begin
	`ifdef DEBUG
				$display("PATRON_VODKA");
	`endif
				nextstate = IDLE; 
			end

			ZLATNA_ARDA:
			begin
	`ifdef DEBUG
				$display("ZLATNA_ARDA");
	`endif
				nextstate = IDLE; 
			end

			SLANINA:
			begin
	`ifdef DEBUG
				$display("SLANINA");
	`endif
				nextstate = IDLE; 
			end

			CNL_ST:
				nextstate = IDLE;
			
			default:
			begin
				nextstate = IDLE;
				$display("You shouldn't be here");		
			end
		endcase
	end

	/* Always block to compute output logic */
	always @(posedge clk)
		case (state)
		IDLE:
			begin
				pdt  	  = 1'b0;
				coincount = 3'b000;
				cng	  = 3'b000;
				rtn 	  = 3'b000;
			end
		ITEM0_IN0:
			begin
				pdt  	  = 1'b0;
				coincount = 3'b000;
				cng	  = 3'b000;
			end
		ITEM1_IN1:
			begin
				pdt  	  = 1'b0;
				coincount = 3'b000;
				cng	  = 3'b000;
			end

		ITEM2_IN2:
			begin
				pdt  	  = 1'b0;
				coincount = 3'b000;
				cng	  = 3'b000;
		end

		ITEM3_IN3:
			begin
				pdt  	  = 1'b0;
				coincount = 3'b000;
				cng	  = 3'b000;
			end

		WAITING_0:
			begin
				pdt = 1'b0;
				cng = 3'b000;
			end

		WAITING_1:
			begin
				pdt = 1'b0;
				cng = 3'b000;
			end

		WAITING_2:
			begin
				pdt = 1'b0;
				cng = 3'b000;
			end

		WAITING_3:
			begin
				pdt = 1'b0;
				cng = 3'b000;
			end

		ST0:
			begin
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

		ST1:
			begin
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end

		ST2:
			begin
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

		ST3:
			begin
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end

		ST4:
			begin
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

		ST5:
			begin
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end

		ST6:
			begin
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

		ST7:
			begin
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end

		VAFLA_BOROVEC:
			begin
				cng	  = coincount - 3;
				pdt   = 1'b1;
			end
			
		PATRON_VODKA:
			begin
				cng = coincount - 4;
				pdt = 1'b1;
			end

		ZLATNA_ARDA:
			begin
				cng = coincount - 5;
				pdt = 1'b1;
			end

		SLANINA:
			begin
				cng = coincount - 6;
				pdt = 1'b1;
			end

		CNL_ST:
			begin
				rtn = coincount;
			end
		endcase

endmodule

`timescale 1 ns / 1 ns
module vending_machine_test();
	reg c1, c2, in0, in1, in2, in3, cnl, clk, rst;
	reg item0_available, item1_available, item2_available, item3_available;
	wire pdt;
	wire [2:0] cng;
	wire [2:0] rtn;

	vending_machine dut(.c1(c1), .c2(c2), .in0(in0), .in1(in1), .in2(in2), .in3(in3),
			    .cnl(cnl), .clk(clk), .rst(rst), .item0_available(item0_available),
			    .item1_available(item1_available), .item2_available(item2_available),
			    .item3_available(item3_available),
			    .pdt(pdt), .cng(cng), .rtn(rtn));
	
	initial begin
		#10;
		/* Reset active low */
		rst = 1'b1;
		#1;
		/* Clock starting with high */
		clk = 1'b1;
		#1;
		/* Init the vending machine */
		rst = 1'b0;
		#1;
		c1 = 0;
		c2 = 0;

		/* Indicate that all items are available */
		item0_available = 1'b1;
		item1_available = 1'b1;
		item2_available = 1'b1;
		item3_available = 1'b1;

		/* Select item0 - VAFLA_BOROVEC */
		in0 = 1'b1;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;
		#10;
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;

		/* Insert one coin with value 1 */
		c2  = 1'b1;
		#2;
		c2  = 1'b0;

		/* Insert one coin with value 2 */
		#1000
		c2  = 1'b1;
		#2;
		c2  = 1'b0;

		/* Select item3 - SLANINA */
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b1;
		#10;
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;

		/* Insert one coin with value 2 */
		#1000
		c2  = 1'b1;
		#2;
		c2  = 1'b0;

		/* Insert one coin with value 2 */
		#1000
		c2  = 1'b1;
		#2;
		c2  = 1'b0;

		/* Insert one coin with value 2 */
		#1000
		c2  = 1'b1;
		#2;
		c2  = 1'b0;

		/* Select item3 - SLANINA */
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b1;
		in3 = 1'b0;
		#10;
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;

		/* Insert one coin with value 2 */
		#1000;
		c2  = 1'b1;
		#2;
		c2  = 1'b0;
	
		#1000;
		cnl = 1'b1;
		#2;
		cnl = 1'b0;

		in0 = 1'b0;
		in1 = 1'b1;
		in2 = 1'b0;
		in3 = 1'b0;
		#10;
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;
	
		/* Insert one coin with value 2 */
		#1000;
		c2  = 1'b1;
		#2;
		c2  = 1'b0;
	
		/* Insert one coin with value 2 */
		#1000;
		c2  = 1'b1;
		#2;
		c2  = 1'b0;
		
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b1;
		in3 = 1'b0;
		#10;
		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;
	
		/* Insert one coin with value 2 */
		#1000;
		c2  = 1'b1;
		#2;
		c2  = 1'b0;
	
		/* Insert one coin with value 2 */
		#1000;
		c2  = 1'b1;
		#2;
		c2  = 1'b0;

		/* Insert one coin with value 2 */
		#1000;
		c2  = 1'b1;
		#2;
		c2  = 1'b0;
		
	end

	always #1
       	begin
		clk   = ~clk;
  	end

`ifdef DEBUG
	always #2
	begin
		if (pdt)
			$display("PDT = 1 CNG = %d", cng);
		if (rtn)
			$display("Coins returned after cancleing order = %d", rtn);

	end
`endif

endmodule
