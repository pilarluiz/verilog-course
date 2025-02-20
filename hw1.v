// This is a testbench for a pipelined 8-bit multiplier.
//
// You do not need to worry about how the multiplier works,
// except to know that its inputs are a and b, and after
// two clock cycles, x will be equal to a * b.
//
// Our goal is to write a test bench which confirms the
// multiplier is working correctly.  We'll do that
// by simply looping through all possible values of a and b
// and checking them.
//
// Of course, we'll need to wait two clock cycles before
// checking the result.  Recall that the `@(posedge clk)` and
// `@(negedge clk)` constructs allow us to wait for clock edges.
//
// Note: Most FPGA code is written in terms of positive clock edges:
// that is when input values are read and output values are changed.
//
// Because of this, we'll want to write our test code to wait for
// _negative_ clock edges: halfway between the positive clock edges.
// This avoids race conditions between the test bench and the module
// under test.
//
// Run with: make hw1.run OR iverilog -o hw1.vvp hw1.v

module multiplier_tb();

  // Declare and initialize clock, and registers and wires to connect to the module under test.
  reg clk = 0;
  reg [7:0] a = 0, b = 0;
  wire [7:0] x;

  // Instantiate the module under test.
  multiplier m(clk, a, b, x);

  // *** Create an `always` task which inverts the clock every 5 ticks.
  always #5 clk = ~clk;

  // *** Fill in test code in this `always` task.
  always @(negedge clk) begin
    // Wait for two clock cycles.
    #20;

    // Check that a * b == x, if not, show an error message and finish.
    // `!==` provides structural equality.
    if ((a*b) !== x) begin
      $display("Error! %d != %d", a*b, x);
      $finish;
    end

    // Increment a.
    a = a+8'b1;
    // If a loops back to 0, increment b.
    if (!a) begin
      b = b+8'b1;
      // If b loops back to 0, show a success message and finish.
      if (!b) begin
        $display("Success!");
        $finish;
      end
    end
  end

endmodule

// Below is the module under test.  You do not need to worry about it,
// except that after your test bench is working and showing success, try to
// introduce an error somewhere below (say, delete an `always` block or
// change a vector index) and see that your test bench catches it!

module multiplier(
  input clk,
  input [7:0] a,
  input [7:0] b,
  output reg [7:0] x
);

  reg [3:0] al_bh, ah_bl;
  reg [7:0] al_bl;

  always @(posedge clk)
    al_bh <= a[3:0] * b[7:4];

  always @(posedge clk)
    ah_bl <= a[7:4] * b[3:0];

  always @(posedge clk)
    al_bl <= a[3:0] * b[3:0];

  always @(posedge clk)
    x <= al_bl + ((al_bh + ah_bl) << 4);

endmodule
