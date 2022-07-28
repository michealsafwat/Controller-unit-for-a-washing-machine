// In this module a counter is used to create a timer that holds the duration of each state
// of the washing machine


module timer (

    input            clock,     // input clock 
    input            reset_n,   // active low reset
    input            start,     // when start is high the timer starts
    input      [2:0] state,     // input that indicates which state we are in
    input            p,         // this input signal if set high the the timer will pause
    input  [1:0] clk_freq,  // input frequency selection
    output           click      // this signal is set high when the timer expires

);

  reg [31:0] t;  // this variable holds the maximum value that the counter has to count up to
  reg [31:0] ticker = 0;  // this variable counts up every clk cycle and will overflow at the first cycle to start from zero


  localparam filling_water_state_duration = 120;    // This parameter holds the Filling Water state duration in seconds
  localparam washing_state_duration = 300;          // This parameter holds the Washing state duration in seconds
  localparam rinsing_state_duration = 120;          // This parameter holds the Rinsing state duration in seconds
  localparam spinning_state_duration = 60;         // This parameter holds the Spinning state duration in seconds


/*
// Using the following part to run the code and produce the results shown in the presentation
  localparam filling_water_state_duration = 0.2;    // This parameter holds the Filling Water state duration in seconds
  localparam washing_state_duration = 0.5;          // This parameter holds the Washing state duration in seconds
  localparam rinsing_state_duration = 0.2;          // This parameter holds the Rinsing state duration in seconds
  localparam spinning_state_duration = 0.1;         // This parameter holds the Spinning state duration in seconds
*/

  localparam clock_freq_1MHz = 1000000;  // This parameter holds the 1MHz value in Herts
  localparam clock_freq_2MHz = 2000000;  // This parameter holds the 2MHz value in Herts
  localparam clock_freq_4MHz = 4000000;  // This parameter holds the 4MHz value in Herts
  localparam clock_freq_8MHz = 8000000;  // This parameter holds the 8MHz value in Herts

  /* The following always block calculates the required maximum number of counts the the counter has to count
to provide the required duration for the current state and at the input clock frequency
Seven states are used but only six have durations which are: 
1.filling water   2.first wash   3.first rinse   4.spinning   5.second wash   6.second rinse
by muliplying the selected clock frequncy by the state duration time in the seconds we get the number of counts
 required to provides the duration of the state  */

  always @(*) begin


    if (state == 1 && clk_freq == 0) t = filling_water_state_duration * clock_freq_1MHz-1;
    else if (state == 2 && clk_freq == 0) t = washing_state_duration * clock_freq_1MHz-1;
    else if (state == 3 && clk_freq == 0) t = rinsing_state_duration * clock_freq_1MHz-1;
    else if (state == 4 && clk_freq == 0) t = spinning_state_duration * clock_freq_1MHz-1;
    else if (state == 5 && clk_freq == 0) t = washing_state_duration * clock_freq_1MHz-1;
    else if (state == 6 && clk_freq == 0) t = rinsing_state_duration * clock_freq_1MHz-1;

    else if (state == 1 && clk_freq == 1) t = filling_water_state_duration * clock_freq_2MHz-1;
    else if (state == 2 && clk_freq == 1) t = washing_state_duration * clock_freq_2MHz-1;
    else if (state == 3 && clk_freq == 1) t = rinsing_state_duration * clock_freq_2MHz-1;
    else if (state == 4 && clk_freq == 1) t = spinning_state_duration * clock_freq_2MHz-1;
    else if (state == 5 && clk_freq == 1) t = washing_state_duration * clock_freq_2MHz-1;
    else if (state == 6 && clk_freq == 1) t = rinsing_state_duration * clock_freq_2MHz-1;

    else if (state == 1 && clk_freq == 2) t = filling_water_state_duration * clock_freq_4MHz-1;
    else if (state == 2 && clk_freq == 2) t = washing_state_duration * clock_freq_4MHz-1;
    else if (state == 3 && clk_freq == 2) t = rinsing_state_duration * clock_freq_4MHz-1;
    else if (state == 4 && clk_freq == 2) t = spinning_state_duration * clock_freq_4MHz-1;
    else if (state == 5 && clk_freq == 2) t = washing_state_duration * clock_freq_4MHz-1;
    else if (state == 6 && clk_freq == 2) t = rinsing_state_duration * clock_freq_4MHz-1;

    else if (state == 1 && clk_freq == 3) t = filling_water_state_duration * clock_freq_8MHz-1;
    else if (state == 2 && clk_freq == 3) t = washing_state_duration * clock_freq_8MHz-1;
    else if (state == 3 && clk_freq == 3) t = rinsing_state_duration * clock_freq_8MHz-1;
    else if (state == 4 && clk_freq == 3) t = spinning_state_duration * clock_freq_8MHz-1;
    else if (state == 5 && clk_freq == 3) t = washing_state_duration * clock_freq_8MHz-1;
    else if (state == 6 && clk_freq == 3) t = rinsing_state_duration * clock_freq_8MHz-1;
	 else t=0;

  end

  /*
The following always block is used to provide the duration of the state by counting up 
when start signal is high till reaching the max. value which is t so then click gets high indicating that state has had its duration
*/
  always @(posedge clock) begin

    if (ticker == t)  //if it reaches the desired max value reset it
      ticker <= 0;
    else if (start == 1 && p == 0)  //only start if the input is set high and p (pause is not high)
      ticker <= ticker + 1;

    else if (start == 1 && p == 1)
      ticker <= ticker;  // if paused then keep ticker at its current value
  end

  assign click = ((ticker == t) ? 1'b1 : 1'b0);  //click to be assigned high every t counts which represents the state duration

endmodule
