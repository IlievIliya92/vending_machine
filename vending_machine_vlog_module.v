module vending_machine(c1, c2, in0, in1, in2, in3, cnl, pdt, cng, rtn, rst, clk);
	
	reg [5:0] state, nextstate; 

	/* Vending machine inputs */
   	input c1, c2, in0, in1, in2, in3, cnl;

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
		SLANINA		= 5'h14,
		PATRON_VODKA	= 5'h15;

	/* Variables initialization */
	initial begin
		coincount = 3'b000;
		$display("Variable Initialization Completed!");
	end

	/* Always block to update state */
	always @(posedge clk, negedge rst)
	begin
		if (rst)
		begin	
			state <= IDLE;
			$display("!rst");
		end
		else 
			state <= nextstate;
	end

	/* Always block to compute both output & nextstate */
	always @(state, c1, c2, in0, in1, in2, in3, cnl)
	begin
		nextstate = state;
		
		case(state)
			IDLE:
			begin
				coincount = 3'b000;
				cng	  = 3'b000;
	
				if(in0 & !in1 & !in2 & !in3)
					begin
						nextstate = ITEM0_IN0;
						pdt 	  = 1'b0;
						$display("ITEM0");
						$display("%h", nextstate);
					end						
				else if (!in0 & in1 & !in2 & !in3)	
					begin
						nextstate = ITEM1_IN1;
						pdt 	  = 1'b0;
						$display("ITEM1");
					end
				else if (!in0 & !in1 & in2 & !in3)	
					begin
						nextstate = ITEM2_IN2;
						pdt 	  = 1'b0;
						$display("ITEM2");
					end
				else if (!in0 & !in1 & !in2 & in3)	
					begin
						nextstate = ITEM3_IN3;
						pdt 	  = 1'b0;
						$display("ITEM3");
					end
				else
					nextstate = IDLE;
			end
			
			ITEM0_IN0:
			begin
				nextstate = WAITING_0;
				$display("ITEM0_IN0");
			end	

			ITEM1_IN1:
			begin
				nextstate = WAITING_1;
				$display("ITEM1_IN1");
			end

			ITEM2_IN2:
			begin
				nextstate = WAITING_2;
				$display("ITEM2_IN2");
			end
			
			ITEM3_IN3:
			begin
				nextstate = WAITING_3;
				$display("ITEM3_IN3");
			end
			
			WAITING_0:
			begin
				pdt = 1'b0;
				cng = 3'b000;
				$display("WAITING_0");
				$display("%d", coincount);
				if (coincount > 2)
				begin
					$display("COINC > 2 W0");
					nextstate = VAFLA_BOROVEC;
				end
				if (c1 & !c2 & (coincount < 3))
				begin
					$display("C1_W0");
					nextstate = ST0;	
				end
				if (!c1 & c2 & (coincount < 3))
				begin
					$display("C2_W0");
					nextstate = ST1;
				end
				if (cnl)
				begin
					$display("CNL W0");
					nextstate = CNL_ST;	
				end	
			end

			WAITING_1:
			begin
				pdt = 1'b0;
				cng = 3'b000;
				$display("WAITING_1");
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
				$display("WAITING_2");
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
				pdt = 1'b0;
				cng = 3'b000;
				$display("WAITING_3");
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
			begin
				nextstate = VAFLA_BOROVEC;
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

			ST1:
			begin
				$display("ST1");
				nextstate = VAFLA_BOROVEC;
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end

			ST2:
			begin
				nextstate = PATRON_VODKA;
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

			ST3:
			begin
				nextstate = PATRON_VODKA;
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end

			ST4:
			begin
				nextstate = ZLATNA_ARDA;
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

			ST5:
			begin
				nextstate = ZLATNA_ARDA;
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end

			ST6:
			begin
				nextstate = SLANINA;
				cng = 3'b000;
				coincount = coincount + 1;
				pdt = 1'b0;
			end

			ST7:
			begin
				nextstate = SLANINA;
				cng = 3'b000;
				coincount = coincount + 2;
				pdt = 1'b0;
			end


			VAFLA_BOROVEC:
			begin
				$display("FAFLA");
				cng	  = coincount - 3;
				pdt 	  = 1'b1;
				nextstate = IDLE; 
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
				nextstate = IDLE;
				rtn = coincount;
			end
			
			default:
			begin
				nextstate = IDLE;
				$display("You shouldn't be here");		
			end
		endcase
	end
endmodule

`timescale 1 ns / 1 ns
module vending_machine_test();
	reg c1, c2, in0, in1, in2, in3, cnl, clk, rst;
	wire pdt;
	wire [2:0] cng;
	wire [2:0] rtn;

	vending_machine dut(.c1(c1), .c2(c2), .in0(in0), .in1(in1), .in2(in2), .in3(in3), 
			    .cnl(cnl), .clk(clk), .rst(rst), .pdt(pdt), .cng(cng), .rtn(rtn));
	
	initial begin
		clk = 1'b1;
		#10;
		rst = 1'b1;
		#10;
		rst = 1'b0;
		in0 = 1'b1;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;
		rst = 1'b1;
		#10;
		rst = 1'b0;

		in0 = 1'b0;
		in1 = 1'b0;
		in2 = 1'b0;
		in3 = 1'b0;
		#100
		c2  = 1'b1;
		c1  = 1'b0;
		#100
		c2  = 1'b0;
		c1  = 1'b0;
		
	end

	always #1 
       	begin
		clk   = ~clk;
  	end

	always #1000
	begin
//		if (pdt)
//			$display("%b", pdt);
	end

endmodule
