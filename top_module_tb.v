`timescale 1ns / 1ps
module top_module_tb ();



  reg clk_tb;
  reg [1:0] clk_freq_tb;
  reg rst_n_tb;
  reg coin_in_tb;
  reg double_wash_tb;
  reg timer_pause_tb;
  wire wash_done_tb;



  top_module t_m (

      .clk(clk_tb),
      .clk_freq(clk_freq_tb),
      .rst_n(rst_n_tb),
      .coin_in(coin_in_tb),
      .double_wash(double_wash_tb),
      .timer_pause(timer_pause_tb),
      .wash_done(wash_done_tb)

  );

  localparam clk_period = 100;
  always #(clk_period * 0.3125) clk_tb = ~clk_tb;  // Generate a 16 MHz clock


  initial begin

    $monitor("t=%3d wash_done_tb=%d timer_pause_tb=%d coin_in_tb=%d double_wash_tb=%d rst_n_tb=%d",
             $time, wash_done_tb, timer_pause_tb, coin_in_tb, double_wash_tb, rst_n_tb);

    clk_tb = 0;
    clk_freq_tb = 0;
    rst_n_tb = 1;
    coin_in_tb = 0;
    double_wash_tb = 0;
    timer_pause_tb = 0;

// these cases are with using 1MHz 
// normal run testing the condition of timer_pause
    #(clk_period * 0.2) rst_n_tb = 0;
    #(clk_period * 0.2) rst_n_tb = 1;
    coin_in_tb = 1;
    clk_freq_tb = 2'b00;
    double_wash_tb = 0;
    timer_pause_tb = 1;
//let coin_in = 0 after the first run then assert coin_in to begin a new run
    #(clk_period * 11000000) coin_in_tb = 0;
    #(clk_period * 0.2) coin_in_tb = 1;
    // this run will use a double wash
    double_wash_tb = 1;
    timer_pause_tb = 0;
    //let coin_in = 0 after the first run then assert coin_in to begin a new run
    #(clk_period * 18000000) coin_in_tb = 0;
    #(clk_period * 0.2) coin_in_tb = 1;
// this run will have a double wash and a delay 
    #(clk_period * 16000035) timer_pause_tb = 1;
    #(clk_period * 1000000) timer_pause_tb = 0;

 end

endmodule
