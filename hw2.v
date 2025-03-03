module hw2(
  input CLK,
  input BTN_N,
  output LEDR_N,
  output LEDG_N,
  output reg [0:6] SEG_C,
  output wire SEG_AN,
);

  // PART ONE
  // Let's set LEDR to light up while BTN is pressed.
  // (Recall, the N suffix means the signal is negated.)

  assign LEDR_N = BTN_N;


  // PART TWO
  // Let's set LEDG to blink about once per second.

  // First, define a counter based off of CLK.

  reg [15:0] counter = 0;
  always @(posedge CLK) begin
    counter <= counter + 1;
  end


  // Second, assign LEDG based on the value of the counter.

  assign LEDG_N = counter[0];

  // Experiment with changing the blinking pattern!  (e.g. 25% on, 75% off)


  // PART THREE
  // Let's make a 7-segment decoder.
  // Write a `case` statement which maps the 4-bit input `digit` to the 7-bit output SEG_C.
  // (Just set SEG_A to a fixed value for now.)

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

  // SEG_AN is the index on the LCD display. 0 = left digit, 1 = right digit
  assign SEG_AN = 1'b1;

  reg [3:0] digit = 3;

  always @(digit)
    case (digit)
      'h0 : SEG_C = 7'b0000001;
      'h1 : SEG_C = 7'b1001111;
      'h2 : SEG_C = 7'b0010010;
      'h3 : SEG_C = 7'b0000110;
      'h4 : SEG_C = 7'b1001100;
      'h5 : SEG_C = 7'b0100100;
      'h6 : SEG_C = 7'b0100000;
      'h7 : SEG_C = 7'b0001111;
      'h8 : SEG_C = 7'b0000000;
      'h9 : SEG_C = 7'b0001100;
      'hA : SEG_C = 7'b0001000;
      'hB : SEG_C = 7'b1100000;
      'hC : SEG_C = 7'b0110001;
      'hD : SEG_C = 7'b1000010;
      'hE : SEG_C = 7'b0110000;
      'hF : SEG_C = 7'b0111000;
    endcase


  // PART FOUR
  // Increment `digit` every time BTN is pressed.
  // HINT: You'll need an additional register to track the previous state of BTN.

  reg was_pressed = 0;

  always @(posedge CLK)
    was_pressed <= !BTN_N;

    if (!BTN_N && !was_pressed) 
      digit <= digit + 1; 

  // BONUS: Add a second digit!

endmodule
