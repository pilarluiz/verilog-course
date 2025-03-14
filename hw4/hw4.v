`default_nettype none

// This module will emit a specified message (held in RAM) whenever a button is clicked.

module hw4(
  input CLK,
  input BTN_N,
  output TX,
  output LEDG_N,
  output LEDR_N
);

  // First, define an array of 8-bit vectors to hold your message.
  // It should be at least 256 entries long.

  reg [7:0] memory[0:1023];


  // Now, initialize that array from a file using `$readmemh()`.
  // That file should contain hex codes (as text) which encode the ASCII
  // characters you want to send.  Use e.g. <https://www.rapidtables.com/convert/number/ascii-to-hex.html>
  // to create it.

  initial $readmemh("hello.hex", memory);


  // We'll need two variables to define the state of our system, one (call
  // it `idx`) to hold an index into our message, and the other (call it
  // `running`) to indicate whether we're currently sending the message or not.

  reg [9:0] idx = 0;
  reg running = 0;

  // Now instantiate a `uart_tx` module like in hw3.
  // You'll want to declare `tx_data` as a reg, and
  // the other signals (`tx_valid`, `tx_ready`, `tx_busy`) as wires.

  reg [7:0] tx_data;
  wire tx_valid, tx_ready, tx_busy;

  uart_tx tx (
    .clk(CLK),
    .rst(1'b0),
    .txd(TX),
    .busy(tx_busy),
    .data(tx_data),
    .valid(tx_valid),
    .ready(tx_ready),
    .prescale(12000000 / (9600*8))
  );


  // Let's assign `running` and `tx_busy` to LEDs so we can see what's happening.

  assign LEDG_N = ~running;
  assign LEDR_N = ~tx_busy;

  // Finally, our main logic!

  // First, let's read from memory into `tx_data` always on the *negative*
  // clock edge, so we don't have to worry about stall cycles.

  always @(negedge CLK) begin
    tx_data <= memory[idx];
  end


  // Now, we can specify `tx_valid`: data is valid so long as we're running,
  // *and* the data we've read is non-zero.  (Array elements after the file we've loaded
  // will all be zero.)

  assign tx_valid = running && |tx_data;


  // We need a way to detect a button click.
  // You can use your solution for this from hw2 here.

  reg btn;
  reg last_btn;
  always @(posedge CLK) begin
    btn <= ~BTN_N;
    last_btn <= btn;
  end
  wire btn_click = btn & ~last_btn;


  // Now our main logic!

  // If we're not running, and the button is clicked,
  // we should set our message index to 0,
  // and start running.

  // If we are running, and `tx_data` is 0, we should stop running.
  // If we are running, and an AXI transfer has occurred,
  // (both `tx_valid` and `tx_ready` are true),
  // we should increment the index.

  always @(posedge CLK) begin
    if (running) begin
      if (tx_valid && tx_ready) idx <= idx + 1;
      if (tx_data == 0) running <= 0;
    end else if (!running && btn_click) begin
      idx <= 0;
      running <= 1;
    end
  end

endmodule


`include "uart.v"
