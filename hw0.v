`default_nettype none

module hw0(
  input wire CLK,
  output wire [0:6] SEG_C,
  output wire SEG_AN,
);

  // declare a counter register
  reg [15:0] cnt;

  // divide the clock by 65536 (12 MHz becomes ~180 Hz)
  always @(posedge CLK)
    cnt <= cnt + 16'd1;

  // switch digits at the divided clock rate
  assign SEG_AN = cnt[15];

  // assign segment values based on which digit is active
  assign SEG_C =
    SEG_AN ?
      // low-active
      7'b1110001 :   // digit 0
      7'b0011000;    // digit 1
      
  // The segments within a digit are numbered left-to-right as follows:
  //
  //  -0-
  // |   |
  // 5   1
  // |   |
  //  -6-
  // |   |
  // 4   2
  // |   |
  //  -3-
  //
  // Note that a "1" bit turns the segment OFF, "0" turns the segment ON.

endmodule
