`default_nettype none

module hw3(
  input CLK,
  input RX,
  input BTN_N,
  output TX,
  output SEG_AN,
  output [0:6] SEG_C,
  output LEDG_N,
  output LEDR_N,
);

  // To start, here's an instance of the UART receiver.
  // You don't need to add anything here, but make sure you understand the syntax!

  wire rx_busy;
  wire [7:0] rx_data;
  wire rx_valid;
  reg rx_ready;

  uart_rx rx (
    .clk(CLK),
    .rst(1'b0),

    .rxd(RX),

    .busy(rx_busy),

    .data(rx_data),
    .valid(rx_valid),
    .ready(rx_ready),

    // This configures the UART to 9600 baud.
    .prescale(12000000 / (9600*8)),
  );


  // First, let's make `rx_busy` visible on an LED.
  // It will blink whenever there's UART activity.

  // assign ...


  // Now, set `rx_ready` to be true whenever the button is pressed.
  // This will allow you to push the button to "consume" data.

  // always @(posedge CLK) ...


  // Now, instantiate the `dual_seven_seg` module below.
  // Connect its ports so it makes the value of `rx_data` visible on the display.
  // Connect its `enable` port to `rx_valid`: this will make the display visible
  // only when the data is valid.

  // dual_seven_seg ...


  // At this point, you can test using minicom!


  // Next, create a "rot13" module and instantiate it here.
  // See the skeleton definition below!

  // wire [7:0] rot13_data;
  // rot13 r13(.in(rx_data), .out(rot13_data));


  // Finally, we can instantiate `uart_tx`.  It's alreayd here doing nothing,
  // you'll just need to wire it up as detailed below.

  wire tx_ready, tx_busy;

  uart_tx tx (
    .clk(CLK),
    .rst(1'b0),

    .txd(TX),

    .busy(tx_busy),

    .data(8'b0),  // wire this to `rot13_data`
    .valid(1'b0),  // wire this to `rx_valid`
    .ready(tx_ready),

    .prescale(12000000 / (9600*8)),
  );

  // Let's make `tx_busy` visible on an LED.
  // assign ...

  // Finally, set `rx_ready` from `tx_ready`.
  // NOTE: You'll want to comment out the code that sets it from the button!

  // always @* ...

endmodule


// Define a "ROT13" module.
// ROT13 is a "cipher" which rotates letters of the alphabet by 13 places.
// So "A" becomes "N", "Z" becomes "M", etc.

module rot13(
  // declare your input and output here... both 8-bit values
);

  always @* begin
    // You can write this as three cases...
    // First, if the input is between "A" and "M", the output is the input plus 13.
    // Second, if the input is between "N" and "Z", the output is the input minus 13.
    // Otherwise, the output is just the input unchanged!
  end

endmodule


// You don't need to edit any of the below.

module seven_seg(
  input [3:0] digit,
  input enable,
  output reg [0:6] seg_c
);

  always @(digit)
    if (enable)
      case (digit)
        'h0: seg_c = 'b0000001;
        'h1: seg_c = 'b1001111;
        'h2: seg_c = 'b0010010;
        'h3: seg_c = 'b0000110;
        'h4: seg_c = 'b1001100;
        'h5: seg_c = 'b0100100;
        'h6: seg_c = 'b0100000;
        'h7: seg_c = 'b0001111;
        'h8: seg_c = 'b0000000;
        'h9: seg_c = 'b0000100;
        'hA: seg_c = 'b0001000;
        'hB: seg_c = 'b1100000;
        'hC: seg_c = 'b0110001;
        'hD: seg_c = 'b1000010;
        'hE: seg_c = 'b0110000;
        'hF: seg_c = 'b0111000;
      endcase
    else
      seg_c = 'b1111111;

endmodule

module dual_seven_seg(
  input clk,
  input [7:0] digits,
  input enable,
  output seg_an,
  output [0:6] seg_c
);

  reg [15:0] counter;
  always @(posedge clk) counter <= counter + 1;
  assign seg_an = counter[15];

  seven_seg ss(
    .digit(seg_an ? digits[3:0] : digits[7:4]),
    .enable(enable),
    .seg_c(seg_c)
  );

endmodule

`include "uart.v"
