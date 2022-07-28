// This module contains an instance of the clock divider module to take the required clock from it and pass it to an instance of the washing machine states module

module top_module (
    input clk,                // System clock, assume 16 MHz
    input [1:0] clk_freq,    // User input to select required frequency
    input rst_n,             // Active low reset
    input coin_in,          // Input flag which is asserted when a coin is deposited
    input double_wash,      //Input flag which is asserted if the user requires double wash option
    input timer_pause,       //Input flag when it is set to ‘1’ spinning phase is paused until this flag is de-asserted
    output wash_done        //Active high output asserted when spinning phase is done and deasserted when coin_in is set to ‘1’

);

 

  clock_divider clk_divider (


      .clk     (clk),
      .clk_freq(clk_freq),
      .new_clk (new_clk)
  );


  washing_machine_states wash_machine (

      .clock(new_clk),
      .clk_freq(clk_freq),
      .rst_n(rst_n),
      .coin_in(coin_in),
      .double_wash(double_wash),
      .timer_pause(timer_pause),
      .wash_done(wash_done),
      .click_fill(click_fill),
      .click_wash_1(click_wash_1),
      .click_wash_2(click_wash_2),
      .click_rinse_1(click_rinse_1),
      .click_rinse_2(click_rinse_2),
      .click_spin(click_spin)

  );
endmodule
