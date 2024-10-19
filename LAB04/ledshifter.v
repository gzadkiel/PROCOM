module ledshifter #(
    parameter NB_SWI        = 4,
    parameter NB_COUNTER    = 32,
    parameter NB_LEDS       = 4,
    parameter NB_BUTTON     = 4, 
    parameter NB_SEL        = 2
) (
    input                       clock
//    input                       i_reset,
//    input  [NB_SWI    - 1 : 0]  i_sw,               // Input for switches - i_sw[0] to enable counter - i_sw[2:1] to choose limit_ref of counter - i_sw[3] to choose right of left shift
//    input  [NB_BUTTON - 1 : 0]  i_button,           // Input for button press - i_button[0] to switch operation mode between flash and shiftreg - i_button[3:1] to choose LEDs color
//    output [NB_BUTTON - 1 : 0]  o_leds,             // Output for LEDS when each button is pressed
//    output [NB_LEDS   - 1 : 0]  o_led_r,            // Output for RED RGB LED
//    output [NB_LEDS   - 1 : 0]  o_led_g,            // Output for GREEN RGB LED
//    output [NB_LEDS   - 1 : 0]  o_led_b             // Output for BLUE RGB LED

);

// ADDED TO INCLUDE VIO AND ILA
wire                       i_reset;
wire  [NB_SWI    - 1 : 0]  i_sw;               // Input for switches - i_sw[0] to enable counter - i_sw[2:1] to choose limit_ref of counter - i_sw[3] to choose right of left shift
wire  [NB_BUTTON - 1 : 0]  i_button;           // Input for button press - i_button[0] to switch operation mode between flash and shiftreg - i_button[3:1] to choose LEDs color
wire [NB_BUTTON - 1 : 0]  o_leds;             // Output for LEDS when each button is pressed
wire [NB_LEDS   - 1 : 0]  o_led_r;            // Output for RED RGB LED
wire [NB_LEDS   - 1 : 0]  o_led_g;            // Output for GREEN RGB LED
wire [NB_LEDS   - 1 : 0]  o_led_b;            // Output for BLUE RGB LED
// 

wire                        connect_count2shift;        // Connect valid output from counter to shift and flash
wire [NB_LEDS   - 1 : 0]    connect_leds_shift;         // Connect output of shiftreg module to MUX
wire [NB_LEDS   - 1 : 0]    connect_leds_flash;         // Connect output of flash module to MUX
wire [NB_LEDS   - 1 : 0]    connect_leds_shift2;        // Connect output of shift2 module to MUX
reg  [NB_LEDS   - 1 : 0]    output_leds;                // Connect MUX output to LEDs
reg  [NB_BUTTON - 1 : 0]    butt_leds;                  // LEDs for each button 
reg  [NB_LEDS   - 1 : 0]    button_d;                   // Save state from buttons (to register button press)
reg  [NB_SEL    - 1 : 0]    mode;                       // Select operation mode (SR or FLASH or SHIFT2)
reg                         led_red;                    // Flag to choose LED color (RED)
reg                         led_gre;                    // Flag to choose LED color (GREEN)
reg                         led_blu;                    // Flag to choose LED color (BLUE)

// Instantiate modules
counter_comp 
    #(
        .NB_SW      (NB_SWI),
        .NB_COUNTER (NB_COUNTER)
    )
    u_counter_comp
    (
        .clock   (clock),
        .i_reset (i_reset),
        .i_sw    (i_sw[NB_SWI-2:0]),
        .o_valid (connect_count2shift)
    );
shift_reg
    #(
        .NB_SHIFT   (NB_LEDS)
    )
    u_shift_reg
    (
        .clock      (clock),
        .i_reset    (i_reset), 
        .i_SW       (i_sw[NB_SWI-1]),
        .i_valid    (connect_count2shift),
        .o_register (connect_leds_shift)
    );
flash
    #(
        .NB_FLASH   (NB_LEDS)
    )
    u_flash
    (
        .clock      (clock),
        .i_reset    (i_reset),
        .i_valid    (connect_count2shift),
        .o_flash    (connect_leds_flash)
    );
shift_reg2
    #(
        .NB_SHIFT   (NB_LEDS)
    )
    u_shift_reg2
    (
        .clock          (clock),
        .i_reset        (i_reset),
        .i_SW           (i_sw[NB_SWI-1]),
        .i_valid        (connect_count2shift),
        .o_register2    (connect_leds_shift2)
    );

// Register button press on 'delayed' button_d
    always @(posedge clock or negedge i_reset) begin
        if (!i_reset) begin
            button_d <= {NB_LEDS{1'b0}};
        end
        else begin
            button_d <= i_button; 
        end
    end

// Change LEDs color
    always @(posedge clock or negedge i_reset) begin
        if (!i_reset) begin
            // On reset, turn of all button LEDs and default to red color
            butt_leds[NB_LEDS - 1 : 0]  <= {NB_LEDS{1'b0}};
            led_red                     <= 1'b1;
            led_gre                     <= 1'b0;
            led_blu                     <= 1'b0;
            mode                        <= 2'b00;
        end
        else begin
            if (button_d[0] != i_button[0] && i_button[0] == 1'b1)  begin
                // button0 pressed
                butt_leds[0]    <= (butt_leds[0]==1'b0) ? 1'b1 : 1'b0;
                mode            <= mode + {{NB_SEL-1{1'b0}},{1'b1}};
                //mode[0]         <= mode[0] ^ (mode[0] & mode[1]);
                //mode[1]         <= mode[1] ^ (mode[0] & mode[1]);
            end
            else if (button_d[1] != i_button[1] && i_button[1] == 1'b1) begin
                // button1 pressed
                butt_leds[1]    <= (butt_leds[1]==1'b0) ? 1'b1 : 1'b1;
                butt_leds[2]    <= (butt_leds[2]==1'b1) ? 1'b0 : 1'b0;
                butt_leds[3]    <= (butt_leds[3]==1'b1) ? 1'b0 : 1'b0;
                led_red         <= (led_red == 1'b1) ? 1'b1 : 1'b1;
                led_gre         <= (led_gre == 1'b1) ? 1'b0 : 1'b0;
                led_blu         <= (led_blu == 1'b1) ? 1'b0 : 1'b0;
            end
            else if (button_d[2] != i_button[2] && i_button[2] == 1'b1) begin
                // button2 pressed
                butt_leds[1]    <= (butt_leds[1]==1'b1) ? 1'b0 : 1'b0;
                butt_leds[2]    <= (butt_leds[2]==1'b0) ? 1'b1 : 1'b1;
                butt_leds[3]    <= (butt_leds[3]==1'b1) ? 1'b0 : 1'b0;
                led_red         <= (led_red == 1'b1) ? 1'b0 : 1'b0;
                led_gre         <= (led_gre == 1'b1) ? 1'b1 : 1'b1;
                led_blu         <= (led_blu == 1'b1) ? 1'b0 : 1'b0;
            end
            else if (button_d[3] != i_button[3] && i_button[3] == 1'b1) begin
                // button3 pressed
                butt_leds[1]    <= (butt_leds[1]==1'b1) ? 1'b0 : 1'b0;
                butt_leds[2]    <= (butt_leds[2]==1'b1) ? 1'b0 : 1'b0;
                butt_leds[3]    <= (butt_leds[3]==1'b0) ? 1'b1 : 1'b1;
                led_red         <= (led_red == 1'b1) ? 1'b0 : 1'b0;
                led_gre         <= (led_gre == 1'b1) ? 1'b0 : 1'b0;
                led_blu         <= (led_blu == 1'b1) ? 1'b1 : 1'b1;
            end
            if (mode == 2'b11) begin // reset selection variable
                mode <= 2'b00;
            end
        end
    end
    
    always @(*) begin
        case (mode)
            2'b00 : output_leds = connect_leds_shift;
            2'b01 : output_leds = connect_leds_flash;
            2'b10 : output_leds = connect_leds_shift2;
        endcase
    end
    
    assign o_leds = butt_leds; 
    
    assign o_led_r = (led_red == 1'b1) ? output_leds : {NB_LEDS{1'b0}};
    assign o_led_g = (led_gre == 1'b1) ? output_leds : {NB_LEDS{1'b0}};
    assign o_led_b = (led_blu == 1'b1) ? output_leds : {NB_LEDS{1'b0}};
    
// VIO and ILA:

VIO
    u_VIO
    (
        .clk_0           (clock),
        .probe_in0_0     (o_leds),
        .probe_in1_0     (o_led_r),
        .probe_in2_0     (o_led_g),
        .probe_in3_0     (o_led_b),
        .probe_out0_0    (i_reset),
        .probe_out1_0    (i_sw),
        .probe_out2_0    (i_button)
    );

ILA
    u_ILA
    (
        .clk_0       (clock),
        .probe0_0    (o_leds),
        .probe1_0    (o_led_r),
        .probe2_0    (o_led_g),
        .probe3_0    (o_led_b)
    );
    
endmodule