module washing_machine_states (

    input clock,  // System clock, assume 16 MHz
    input [1:0] clk_freq,  // User input to select required frequency
    input rst_n,  // Active low reset
    input coin_in,  // Input flag which is asserted when a coin is deposited
    input double_wash,  //Input flag which is asserted if the user requires double wash option
    input timer_pause,       //Input flag when it is set to ‘1’ spinning phase is paused until this flag is de-asserted
    output reg wash_done,   //Active high output asserted when spinning phase is done and deasserted when coin_in is set to ‘1’        
    output click_fill,     // This signal goes high after two minutes which is the duration of the filling water state
    output click_wash_1,    // This signal goes high after five minutes which is the duration of the first wash state
    output click_wash_2,    // This signal goes high after five minutes which is the duration of the second wash state
    output click_rinse_1,    // This signal goes high after two minutes which is the duration of the  first rinse state
    output click_rinse_2,  // This signal goes high after two minutes which is the duration of the second rinse state
    output click_spin     // This signal goes high after one minutes which is the duration of the spinning state

);

  reg [2:0] state;  // The current state of the washing machine
  reg [2:0] next_state;  // The next state of the washing machine 

  reg ready_fill = 0;     // This is set high when the next state is filling water and it acts as the start signal for the timer to calculate the duration
  reg ready_wash_1 = 0;   // This is set high when the next state is wash_1 and it acts as the start signal for the timer to calculate the duration
  reg ready_rinse_1 = 0;  // This is set high when the next state is rinse_1 and it acts as the start signal for the timer to calculate the duration
  reg ready_spin = 0;     // This is set high when the next state is spin and it acts as the start signal for the timer to calculate the duration
  reg ready_wash_2 = 0;   // This is set high when the next state is wash_2 and it acts as the start signal for the timer to calculate the duration
  reg ready_rinse_2 = 0;  // This is set high when the next state is rinse_2 and it acts as the start signal for the timer to calculate the duration

  reg done = 0;       // This signal is used to make sure that output wash_done is set low when coin_in is high again so done is set high when wash_done is high
  reg paused = 0;     // This signal is used to check if timer_pause input set high during any state except spin state
  reg new_run = 0;    // This signal is set high if coin_in is low and done signal is high to declare that next time will be a new run and gets wash_done low
  reg no_pause = 0;   // this signal is used with all state timers except the timer of the spin state and it is always zero so no pause happens during these states
  reg spin_pause = 0;    // this signal is used to trigger the pause for the spin state so it is an input to spin state timer


  // Define names for each state
  localparam idle = 3'd0;
  localparam filling_water = 3'd1;
  localparam washing_1 = 3'd2;
  localparam rinsing_1 = 3'd3;
  localparam spinning = 3'd4;
  localparam washing_2 = 3'd5;
  localparam rinsing_2 = 3'd6;
  localparam pause = 3'd7;


  // The following are 6 instances of the timer module which are used to  provide the duration of each state

  timer timer_fill (
      .clock(clock),
      .clk_freq(clk_freq),
      .start(ready_fill),
      .reset_n(rst_n),
      .state(state),
      .p(no_pause),
      .click(click_fill)
  );

  timer wash_state_1 (

      .clock(clock),
      .clk_freq(clk_freq),
      .start(ready_wash_1),
      .reset_n(rst_n),
      .state(state),
      .p(no_pause),
      .click(click_wash_1)

  );

  timer wash_state_2 (

      .clock(clock),
      .clk_freq(clk_freq),
      .start(ready_wash_2),
      .reset_n(rst_n),
      .state(state),
      .p(no_pause),
      .click(click_wash_2)

  );

  timer rinse_state_1 (

      .clock(clock),
      .clk_freq(clk_freq),
      .start(ready_rinse_1),
      .reset_n(rst_n),
      .state(state),
      .p(no_pause),
      .click(click_rinse_1)

  );

  timer rinse_state_2 (

      .clock(clock),
      .clk_freq(clk_freq),
      .start(ready_rinse_2),
      .reset_n(rst_n),
      .state(state),
      .p(no_pause),
      .click(click_rinse_2)

  );

  timer spin_state (

      .clock(clock),
      .clk_freq(clk_freq),
      .start(ready_spin),
      .p(spin_pause),
      .reset_n(rst_n),
      .state(state),
      .click(click_spin)

  );


  always @*

    case (state)
      idle: begin

        if (coin_in == 1 && done == 0) begin
          next_state = filling_water;
          wash_done  = 0;

        end else if (coin_in == 0 && done == 1) begin
          next_state = idle;
          wash_done = 1;
          new_run = 1;
        end else if (coin_in == 1 && new_run == 1) begin
          next_state = filling_water;
          wash_done = 0;
          done = 0;

        end else if (coin_in == 0 && done == 0) begin
          next_state = idle;
          wash_done  = 0;
        end else begin
          next_state = idle;
          wash_done  = 1;
        end
        if (timer_pause == 1) paused = 0;
        else paused = 1;
      end
      //*************************************************************************************//
      filling_water: begin
        new_run=0;
        ready_fill = 1;
        if (click_fill == 1) begin

          next_state = washing_1;
          wash_done  = 0;


        end else begin
          next_state = filling_water;
          wash_done = 0;
          
        end
        if (timer_pause == 1) paused = 0;
        else paused = 1;
      end
      //*****************************************************************************************//
      washing_1: begin
        ready_wash_1 = 1;
        if ( click_wash_1 == 1) begin

          next_state = rinsing_1;
          wash_done  = 0;


        end else begin
          next_state = washing_1;
          wash_done  = 0;
        end
        if (timer_pause == 1) paused = 0;
        else paused = 1;
      end

      //******************************************************************************************//
      rinsing_1: begin
        ready_rinse_1 = 1;
        if (double_wash == 1 && click_rinse_1 == 1) begin
          next_state = washing_2;
          wash_done  = 0;



        end else if (click_rinse_1 == 1) begin
          next_state = spinning;
          wash_done  = 0;


        end else begin
          next_state = rinsing_1;
          wash_done  = 0;
        end

        if (timer_pause == 1) paused = 0;
        else paused = 1;
      end

      //***************************************************************************************//
      washing_2: begin
        ready_wash_2 = 1;
        if ( click_wash_2 == 1) begin

          next_state = rinsing_2;
          wash_done  = 0;

        end else begin
          next_state = washing_2;
          wash_done  = 0;
        end

        if (timer_pause == 1) paused = 0;
        else paused = 1;
      end

      //***************************************************************************************//
      rinsing_2: begin
        ready_rinse_2 = 1;
        if ( click_rinse_2 == 1) begin
          next_state = spinning;
          wash_done  = 0;


        end else begin
          next_state = rinsing_2;
          wash_done  = 0;
        end
        if (timer_pause == 1) paused = 0;
        else paused = 1;
      end
      //***************************************************************************************//
      spinning: begin
        ready_spin = 1;
        if (paused == 1 && timer_pause == 1) begin
          next_state = pause;
          wash_done  = 0;
          spin_pause = 1;
        end else if ( click_spin == 1 && (paused == 0 || paused == 1)) begin
          next_state = idle;
          done = 1;
          ready_fill=0;
        ready_wash_1 = 0;
          ready_rinse_1 = 0;
          ready_spin = 0;
          ready_wash_2 = 0;
          ready_rinse_2 = 0; 
        end else begin
          next_state = spinning;
          wash_done  = 0;
        end

      end
      //************************************************************************************************//
      pause: begin

        if (timer_pause == 1) begin

          next_state = pause;
          wash_done  = 0;
          
        end else begin

          spin_pause = 0;
          next_state = spinning;
          wash_done  = 0;
          paused = 0;
        end
      end

      default: next_state = idle;

    endcase


  always @(posedge clock or negedge rst_n) begin
    if (!rst_n) state <= idle;
    else state <= next_state;
  end

endmodule
