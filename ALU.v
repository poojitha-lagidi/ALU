
module ALU
    // Parameters section
    #(parameter BUS_WIDTH = 8)
    // Ports section
    (input [BUS_WIDTH-1:0] a,
     input [BUS_WIDTH-1:0] b,
     input carry_in,
     input [4:0] opcode,
     output reg [BUS_WIDTH-1:0] y,
     output reg carry_out,
     output reg borrow,
     output zero,
     output parity,
     output reg invalid_op
    );
  
    // Define a list of opcodes
    //Arithmetic Operations
    localparam OP_ADD       = 1; // A + B
    localparam OP_ADD_CARRY = 2; // A + B + Carry
    localparam OP_2s_COMP=3; 	 // 2's complement of A
    localparam OP_SUB = 4;       // Subtract B from A
    localparam OP_INC = 5;       // Increment A
    localparam OP_DEC = 6;       // Decrement A
    //Logical Operations
    localparam OP_AND = 7;       // Bitwise AND
    localparam OP_OR = 8;	 // Bitwise OR
    localparam OP_XOR = 9;	 // Bitwise XOR
    localparam OP_NOT = 10;      // Bitwise NOT (or) 1's complement
    localparam OP_ROL = 11;      // Rotate Left
    localparam OP_ROR = 12;      // Rotate Right  
    localparam OP_ASR = 13;	 // Arithmetic Shift Right by one bit
    localparam OP_ASL = 14;	 // Arithmetic Shift Left by one bit
    localparam OP_LSR = 15;	 // Logical Shift Right by one bit
    localparam OP_LSL = 16;	 // Logical Shift Left by one bit
    localparam OP_EQ = 17;	 // Checks if A==B 
    localparam OP_GR = 18;	 // Checks if A>B 
    localparam OP_LS = 19;	 // Checks if A<B 

//`localparam` is used to define constants that are local to a module and cannot be overridden.
//`localparam` is similar to `parameter`, but with module scope.
  
    always @(*) begin
        y = 0; carry_out = 0; borrow = 0; invalid_op = 0;
        case (opcode)
        OP_ADD        :  begin y = a + b; end
        OP_ADD_CARRY  :  begin {carry_out, y} = a + b + carry_in; end
        OP_2s_COMP    :  begin y = ~a + 1'b1; end
        OP_SUB        :  begin {borrow, y} = a - b; end
        OP_INC        :  begin {carry_out, y} = a + 1'b1; end
        OP_DEC        :  begin {borrow, y} = a - 1'b1; end
        OP_AND        :  begin y = a & b; end
	OP_OR	      :  begin y = a | b; end 
	OP_XOR	      :  begin y = a ^ b; end
        OP_NOT        :  begin y = ~a; end
        OP_ROL        :  begin y = {a[BUS_WIDTH-2:0], a[BUS_WIDTH-1]}; end
        OP_ROR        :  begin y = {a[0], a[BUS_WIDTH-1:1]}; end
	OP_ASR	      :  begin y = a >>> 1; end
	OP_ASL	      :  begin y = a <<< 1; end
	OP_LSR	      :  begin y = a >> 1; end
	OP_LSL	      :  begin y = a << 1; end
	OP_EQ	      :  begin y = (a==b); end
	OP_GR	      :  begin y = (a>b); end
	OP_LS	      :  begin y = (a<b); end
        default	      :  begin invalid_op = 1; y = 0; carry_out = 0; borrow = 0;  end
        endcase
    end
  
    assign parity = ^y;
    assign zero = (y == 0);
endmodule




`timescale 1us/1ns

module ALU_tb();
	
    // Testbench variables
    parameter BUS_WIDTH = 8; // paramter value cannot be changed during runtime. They can be changed during module instantiation
    reg  [4:0] opcode;
    reg [BUS_WIDTH-1:0] a, b;
    reg carry_in;
    wire [BUS_WIDTH-1:0] y;
    wire carry_out;
    wire borrow;
    wire zero;
    wire parity;
    wire invalid_op;

    // Instantiate the DUT 
    ALU
    // Parameters section
    #(.BUS_WIDTH(BUS_WIDTH))
    ALU0
   (.a(a),
   .b(b),
   .carry_in(carry_in),
   .opcode(opcode),
   .y(y),
   .carry_out(carry_out),
   .borrow(borrow),
   .zero(zero),
   .parity,
   .invalid_op(invalid_op)
    );
  
    // Create stimulus
    initial begin
        $monitor($time, " opcode = %d, a = %d, b = %d, y = %d, carry_out=%b, borrow=%b, zero=%b, parity=%b, invalid_op=%b", 
	                  opcode, a, b, y, carry_out, borrow, zero, parity, invalid_op);
	// Test default from case
	#1; $display("Testing Invalid Opcode");
		opcode = 0; 
        // Test OP_ADD
        #1  $display("a+b");
		opcode = 1; a = 9; b = 33; carry_in = 0; 
        // Test OP_ADD_CARRY
        #1  $display("a+b+carry_in");
		opcode = 2; a = 9; b = 33; carry_in = 1;     
	// Test OP_2s_COMP
        #1  $display("2's complement of a");
		opcode = 3; a = 8'b1001_0110;
        // Test OP_SUB
        #1  $display("a-b");
		opcode = 4; a = 65; b = 64; carry_in = 0; 
        #1 	opcode = 4; a = 65; b = 66; carry_in = 0; 
        // Test OP_INC
        #1  $display("a+1");
		opcode = 5; a = 233; b = 69; carry_in = 1; 
        // Test OP_DEC
        #1  $display("a-1");
		opcode = 6; a = 0; b = 3; carry_in = 0; 
        // Test OP_AND
        #1  $display("a&b");
		opcode = 7; a = 8'b0000_0010; b = 8'b0000_0011; 
	// Test OP_OR
        #1  $display("a|b");
		opcode = 8; a = 8'b0000_0010; b = 8'b0000_0011;
	// Test OP_XOR
        #1  $display("a^b");
		opcode = 9; a = 8'b0000_0010; b = 8'b0000_0011;
        // Test OP_NOT
        #1  $display("~a");
		opcode = 10; a = 8'b1111_1111;  
	// Test OP_ROL
        #1  $display("Rotate Left a");
		opcode = 11; a = 8'b0000_0001; 
       // Test OP_ROR
        #1  $display("Rotate Right a");
		opcode = 12; a = 8'b1000_0000;
	// Test OP_ASR
        #1  $display("Arithmetic Shift Right a");
		opcode = 13; a = 8'b1000_0010;
	// Test OP_ASL
        #1  $display("Arithmetic Shift Left a");
		opcode = 14; a = 8'b1100_0010;
	// Test OP_LSR
        #1  $display("Logical Shift Right a");
		opcode = 15; a = 8'b1000_0010;
	// Test OP_LSL
        #1  $display("Logical Shift Left a");
		opcode = 16; a = 8'b1100_0010;
	// Test OP_EQ
        #1  $display("a==b");
		opcode = 17; a = 8'b1100_0010; b = 8'b0000_0010;
	// Test OP_GR
        #1  $display("a>b");
		opcode = 18; a = 8'b1100_0010; b = 8'b0000_0010;
	// Test OP_LS
        #1  $display("a<b");
		opcode = 19; a = 8'b1100_0010; b = 8'b0000_0010;
	end
endmodule 
