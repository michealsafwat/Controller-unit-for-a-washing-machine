  // For clock division a 4-bit counter is used with 16 MHz input clock
  // and each bit frequency divides the previous by 2 
  // so with that we can generate and extract the required frequency to work with

module clock_divider (

    input            clk,       // System Clock which is assumed to be 16 MHz
    input      [1:0] clk_freq,  // User input to select required frequency
    output reg       new_clk    // output clock after division 1MHZ or 2MHz or 4MHz or 8MHz
);


  reg [3:0] count = 4'b0;

  always @(posedge clk) begin

    count = count + 1;  // count up 

    case (clk_freq)
      2'b00:
            new_clk = count[3];           // clk_freq = 00 then divide the 16 MHz by 16 selecting the fourth bit producing 1 MHz
      2'b01:
            new_clk = count[2];          // clk_freq = 00 then divide the 16 MHz by 8 selecting the fourth bit producing 2 MHz
      2'b10:
            new_clk = count[1];         // clk_freq = 00 then divide the 16 MHz by 4 selecting the fourth bit producing 4 MHz
      2'b11:
            new_clk = count[0];         // clk_freq = 00 then divide the 16 MHz by 2 selecting the fourth bit producing 8 MHz

      default: new_clk = clk;
    endcase

  end

endmodule
