`timescale 1ns/100ps

module tb_ledshifter();

parameter NB_LEDS       = 4; 
parameter NB_COUNTER    = 32;   
parameter NB_SW         = 4;   
parameter NB_BUTTON     = 4;
parameter NB_SEL        = 2;

wire [NB_LEDS   - 1 : 0]    o_led_r;        // RGB Leds - RED
wire [NB_LEDS   - 1 : 0]    o_led_b;        // RGB Leds - BLUE
wire [NB_LEDS   - 1 : 0]    o_led_g;        // RGB Leds - GREEN
wire [NB_LEDS   - 1 : 0]    o_leds;
reg  [NB_BUTTON - 1 : 0]    i_button;
reg  [NB_SW     - 1 : 0]    i_sw;           
reg                         i_reset;        // Reset
reg                         clock;          // System clock

initial begin: stimulus
    i_sw[0]             = 1'b0;                         // Arranca sin contar, counter disabled
    clock               = 1'b0;
    i_reset             = 1'b0;             
    //i_sw[2 : 1]         = 2'b10;                        // Inicio con el selector de limit_ref en 10
    i_sw[2 : 1]         = 2'b00;                        // Inicio con el selector de limit_ref en 00
    i_sw[3]             = 1'b0;                         // Inicialmente hace shift hacia la der
    i_button [NB_BUTTON - 1 : 0] = {NB_BUTTON{1'b0}};   // Los botones inician en 0, cuando presiono hace el posedge     

    #100 i_reset        = 1'b1;                         // Levanto el reset
    #100 i_sw[0]        = 1'b1;                         // Enable counter module
    
    //#500 i_button[0]    = ~i_button[0];                 // Switch LED operation
    //#50 i_button[0]     = ~i_button[0];                 // Switch LED operation
    
                                                        // Prendo LEDS VERDE
    //#500 i_button[2]    = ~i_button[2];                 // Switch LED color
    //#50 i_button[2]     = ~i_button[2];                 // Switch LED color
                                                        // Prendo LEDS AZUL
    //#500 i_button[3]    = ~i_button[3];                 // Switch LED color
    //#50 i_button[3]     = ~i_button[3];                 // Switch LED color
                                                        // Prendo LEDS ROJO
    #500 i_button[1]    = ~i_button[1];                 // Switch LED color
    #50 i_button[1]     = ~i_button[1];                 // Switch LED color
                                                        // Presiono de nuevo para ROJO (no dede cambiar nada)
    #500 i_button[1]    = ~i_button[1];                 // Switch LED color
    #50 i_button[1]     = ~i_button[1];                 // Switch LED color
    #500 i_button[2]    = ~i_button[2];                 // Switch LED color
    #50 i_button[2]     = ~i_button[2];                 // Switch LED color
    #1500 i_button[3]   = ~i_button[3];                 // Switch LED color
    #50 i_button[3]     = ~i_button[3];                 // Switch LED color
    
    #500 i_sw[2 : 1]    = 2'b01;                        // Cambio el selector de limit_ref osea los shifts deberian tardar mas tiempo
    #5000 i_sw[3]       = 1'b1;                         // Cambio el shift hacia la izquierda
    
    #5000 i_button[0]   = ~i_button[0];                 // Cambio modo de operacion a flash
    #50 i_button[0]     = ~i_button[0];     
    #500 i_sw[2 : 1]    = 2'b00;                        // Cambio el selector de limit_ref osea los shifts deberian tardar menos
    #5000 i_button[0]   = ~i_button[0];                 // Cambio modo de operacion a shift2
    #50 i_button[0]     = ~i_button[0];  
    #5000 i_button[0]   = ~i_button[0];                 // Cambio modo de operacion a shiftreg
    #50 i_button[0]     = ~i_button[0];  
    #1000 i_button[0]   = ~i_button[0];                 // Cambio modo de operacion a flash de nuevo y cierro
    #50 i_button[0]     = ~i_button[0];
    
    
    #2500 $finish;
end

always #5 clock = ~clock;

ledshifter
    #(
        .NB_SWI         (NB_SW),
        .NB_COUNTER     (NB_COUNTER),
        .NB_LEDS        (NB_LEDS),
        .NB_BUTTON      (NB_BUTTON),
        .NB_SEL         (NB_SEL) 
    )
    u_ledshifter
    (
        .clock      (clock),
        .i_reset    (i_reset),
        .i_sw       (i_sw),
        .i_button   (i_button),
        .o_led_r    (o_led_r),
        .o_led_g    (o_led_g),
        .o_led_b    (o_led_b),
        .o_leds     (o_leds)
    );

endmodule