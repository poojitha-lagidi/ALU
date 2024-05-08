module ALU_using_GOLDEN_Model 
#(parameter n = 3)
(input [n-1:0]a,
 input [n-1:0]b,
 input carry_in,
 input [4:0]opcode,
 output reg [n-1:0]y,
 output reg carry_out,
 output reg borrow,
 output reg invalid_op,
 output zero, 
 output parity);
 
 // Define a list of opcodes
    //Arithmetic Operations
    localparam OP_ADD       = 1; // a + b
    localparam OP_ADD_CARRY = 2; // a + b + carry_in
    localparam OP_2s_COMP=3; 	 // ~a + 1'b1
    localparam OP_SUB = 4;       // a-b
    localparam OP_INC = 5;       // a-1
    localparam OP_DEC = 6;       // a-1
    //Logical Operations
    localparam OP_AND = 7;       // a & b
    localparam OP_OR = 8;	 // a | b
    localparam OP_XOR = 9;	 // a ^ b
    localparam OP_NOT = 10;      // ~a
    localparam OP_ROL = 11;      // {a[n-2:0],a[n-1]}
    localparam OP_ROR = 12;      // {a[0], a[n-1:1]}
    localparam OP_ASR = 13;	 // a>>>1
    localparam OP_ASL = 14;	 // a<<<1
    localparam OP_LSR = 15;	 // a>>1
    localparam OP_LSL = 16;	 // a<<1
    localparam OP_EQ = 17;	 // A==B 
    localparam OP_GR = 18;	 // A>B 
    localparam OP_LS = 19;	 // A<B 

always @ (*) begin
	y = 0; borrow = 0; carry_out = 0; invalid_op = 0;
	case (opcode)
		OP_ADD : begin y = a + b; end
		OP_ADD_CARRY : begin {carry_out, y} = a + b + carry_in; end
		OP_2s_COMP : begin y = ~a + 1'b1; end
		OP_SUB : begin {borrow, y} = a - b; end
		OP_INC : begin y = a + 1'b1; end
		OP_DEC : begin y = a - 1'b1; end
		OP_AND : begin y = a & b; end
		OP_OR : begin y = a | b; end
		OP_XOR : begin y = a ^ b; end
		OP_NOT : begin y = ~a; end
		OP_ROL : begin y = {a[n-2:0],a[n-1]}; end
		OP_ROR : begin y = {a[0], a[n-1:1]}; end
		OP_ASR : begin y = a<<<1; end
		OP_ASL : begin y = a>>>1; end
		OP_LSR : begin y = a>>1; end
		OP_LSL : begin y = a<<1; end
		OP_EQ : begin y = (a == b); end
		OP_GR : begin y = (a > b); end
		OP_LS : begin y = (a < b); end
		default : begin invalid_op = 1; y = 0; borrow = 0; carry_out = 0; end
	endcase
end

assign zero = (y == 0);
assign parity = ^y;
endmodule

`timescale 1us/1ns
module ALU_using_GOLDEN_Model_tb;

parameter n = 4;
reg [n-1:0]a; 
reg [n-1:0]b;
reg carry_in;
reg [4:0]opcode;
wire [n-1:0]y;
wire carry_out; 
wire borrow;
wire invalid_op;
wire zero;
wire parity;
integer success_count = 0;
integer error_count = 0; 
integer test_count = 0;
integer i = 0;

// Define a list of opcodes
    localparam OP_ADD       = 1; // a + b
    localparam OP_ADD_CARRY = 2; // a + b + carry_in
    localparam OP_2s_COMP=3; 	 // ~a + 1'b1
    localparam OP_SUB = 4;       // a-b
    localparam OP_INC = 5;       // a-1
    localparam OP_DEC = 6;       // a-1
    localparam OP_AND = 7;       // a & b
    localparam OP_OR = 8;	 // a | b
    localparam OP_XOR = 9;	 // a ^ b
    localparam OP_NOT = 10;      // ~a
    localparam OP_ROL = 11;      // {a[n-2:0],a[n-1]}
    localparam OP_ROR = 12;      // {a[0], a[n-1:1]}
    localparam OP_ASR = 13;	 // a>>>1
    localparam OP_ASL = 14;	 // a<<<1
    localparam OP_LSR = 15;	 // a>>1
    localparam OP_LSL = 16;	 // a<<1
    localparam OP_EQ = 17;	 // A==B 
    localparam OP_GR = 18;	 // A>B 
    localparam OP_LS = 19;	 // A<B  

ALU_using_GOLDEN_Model #(.n(n)) ALUGM
	(.a(a), 
	.b(b), 
	.carry_in(carry_in), 
	.opcode(opcode),
	.y(y), 
	.carry_out(carry_out), 
	.borrow(borrow), 
	.invalid_op(invalid_op), 
	.zero(zero), 
	.parity(parity)
	);

//The following is used to model the ALU behaviour at testbench level for creating the expected data
//The size of ALU is n-1(size of y) + 5(remaining 5 outputs)  = n + 4
function [n+4:0] function_ALU (input [n-1:0]a, input [n-1:0]b, input [4:0]opcode, input carry_in);
// Local variables used to model the ALU behavior
reg [n-1:0]y;
reg carry_out;
reg borrow; 
reg invalid_op;
reg zero;
reg parity;

begin
	y = 0; borrow = 0; carry_out = 0; invalid_op = 0;
	case (opcode)
		OP_ADD : begin {carry_out, y} = a + b; end //different from RTL code
		OP_ADD_CARRY : begin {carry_out, y} = a + b + carry_in; end
		OP_2s_COMP : begin y = ~a + 1'b1; end
		OP_SUB : begin {borrow, y} = a - b; end 
		OP_INC : begin {carry_out, y} = a + 1'b1; end //different from RTL code
		OP_DEC : begin {borrow, y} = a - 1'b1; end //different from RTL code
		OP_AND : begin y = a & b; end
		OP_OR : begin y = a | b; end
		OP_XOR : begin y = a ^ b; end
		OP_NOT : begin y = ~a; end
		OP_ROL : begin y = {a[n-2:0],a[n-1]}; end
		OP_ROR : begin y = {a[0], a[n-1:1]}; end
		OP_ASR : begin y = a<<<1; end
		OP_ASL : begin y = a>>>1; end
		OP_LSR : begin y = a>>1; end
		OP_LSL : begin y = a<<1; end
		OP_EQ : begin y = (a == b); end
		OP_GR : begin y = (a > b); end
		OP_LS : begin y = (a < b); end
		default : begin invalid_op = 1; y = 0; borrow = 0; carry_out = 0; end
	endcase
	zero = (y == 0);
	parity = ^y;
	function_ALU = {invalid_op, borrow, carry_out, zero, parity,  y};
end
endfunction

task compare_ALU (input [n+4:0] expected_output, input [n+4:0] observed_output);
	begin
		if (expected_output === observed_output) begin
			$display($time, " Success Expected invalid_op=%b, borrow=%b, carry_out=%b, zero=%b, parity=%b, y=%d",
					expected_output[n+4], expected_output[n+3], expected_output[n+2], expected_output[n+1], 
					expected_output[n], expected_output[n-1:0]);
			$display($time, "         Observed invalid_op=%b, borrow=%b, carry_out=%b, zero=%b, parity=%b, y=%d",
					observed_output[n+4], observed_output[n+3], observed_output[n+2], observed_output[n+1], 
					observed_output[n], observed_output[n-1:0]);
			success_count = success_count + 1;
		end else begin
			$display($time, " Error Expected invalid_op=%b, borrow=%b, carry_out=%b, zero=%b, parity=%b, y=%d",
					expected_output[n+4], expected_output[n+3], expected_output[n+2], expected_output[n+1], 
					expected_output[n], expected_output[n-1:0]);
			$display($time, "       Observed invalid_op=%b, borrow=%b, carry_out=%b, zero=%b, parity=%b, y=%d",
					observed_output[n+4], observed_output[n+3], observed_output[n+2], observed_output[n+1], 
					observed_output[n], observed_output[n-1:0]);
			error_count = error_count + 1;
		end
		test_count = error_count + success_count;
	end
endtask

initial begin
	for (i = 0; i < 100; i = i + 1) begin
		a = $random;
		b = $random;
		carry_in = $random;
		opcode = $random % 10'd21;
		#1; // give some time to the combinational circuit to compute (propagation delay)
		$display($time, " Test%d a=%d, b=%d, carry_in=%b, opcode=%d", i, a, b, carry_in, opcode);
		compare_ALU(function_ALU(a, b, opcode, carry_in), {invalid_op, borrow, carry_out, zero, parity,  y});
		#1; // wait some time before the next test
	end
	$display($time," Test Results success_count=%d, error_count=%d, test_count=%d", success_count, error_count, test_count);
	#10; $stop;
end
endmodule	