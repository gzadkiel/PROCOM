module comm_sys #(
    parameter NB_SAMPLES  = 1, //! Bits totales de las muestras de entrada
    parameter NBF_SAMPLES = 0, //! Bits frac de las muestras de entrada
    parameter NB_COEFFS   = 11, //! Bits totales de los coef del filtro
    parameter NBF_COEFFS  = 10, //! Bits frac de los coef del filtro
    parameter NB_OUTPUT   = 8, //! Bits totales de la salida
    parameter NBF_OUTPUT  = 7, //! Bits frac de la salida
    parameter N_COEFFS    = 6, //! Cantidad de coeficientes de cada fase del filtro
    parameter NB_BITS     = 9, //! Bits de la seed de las PRBS
    parameter NB_SW       = 4, //! Cantidad de switches de entrada
    parameter NB_OLEDS    = 4  //! Cantidad de LEDs de salida
) (
    input                     clock,
    input                     i_reset,
    input  [NB_SW    - 1 : 0] i_sw,
    output [NB_OLEDS - 1 : 0] o_ledout
    // Debugging outputs:
    // output signed [NB_OUTPUT - 1 : 0] o_sampleI_deb,
    // output signed [NB_OUTPUT - 1 : 0] o_sampleQ_deb,
    // output        [1             : 0] o_counter_deb,      
    // output                            o_prbs_enable_deb,
    // output                            o_ber_enable_deb,
    // output                            o_rctx_enable_deb,  
    // output                            o_prbsi_deb,
    // output                            o_prbsq_deb
    // output        [9  - 1        : 0] o_beraccumi_deb      ,
    // output        [9  - 1        : 0] o_beraccumq_deb      ,      
    // output        [9  - 1        : 0] o_errorcounti_deb    ,
    // output        [9  - 1        : 0] o_errorcountq_deb    ,
    // output        [511 - 1       : 0] o_prbsshifti_deb     ,
    // output        [511 - 1       : 0] o_prbsshiftq_deb     ,
    // output        [9  - 1        : 0] o_min_beri_deb       ,
    // output        [9  - 1        : 0] o_min_berq_deb       ,
    // output        [4             : 0] o_lat_posi_deb       ,
    // output        [4             : 0] o_lat_posq_deb       ,  
    // output                            o_decoded_samplei_deb,
    // output                            o_decoded_sampleq_deb 
);

// Phase 0: 0.         0.         0.         0.9921875  0.         0.       
// Phase 1: 0.0078125 -0.0546875  0.265625   0.890625  -0.125      0.0234375
// Phase 2: 0.015625  -0.1171875  0.6015625  0.6015625 -0.1171875  0.015625
// Phase 3: 0.0234375 -0.125      0.890625   0.265625  -0.0546875  0.0078125

localparam phase_0 = 48'b000000000000000000000000011111110000000000000000;
localparam phase_1 = 48'b000000011111100100100010011100101111000000000011;
localparam phase_2 = 48'b000000101111000101001101010011011111000100000010;
localparam phase_3 = 48'b000000111111000001110010001000101111100100000001;

reg [1 : 0] counter;     //! Contador para generar los enable en freq clock/4 
reg         prbs_enable; //! Enable para generar un nuevo bit con la PRBS
reg         ber_enable;  //! Enable para tomar muestra y compararla con la PRBS
reg         rctx_enable; //! Enable para tomar una muestra nueva de la PRBS

reg signed [(NB_COEFFS*N_COEFFS) - 1 : 0]  w_coeffs;
wire                                       w_prbsI_out;
wire                                       w_prbsQ_out;
wire signed [NB_OUTPUT            - 1 : 0] w_rctxI_out;
wire signed [NB_OUTPUT            - 1 : 0] w_rctxQ_out;
wire                                       w_ber0i;
wire                                       w_ber0q;
 
always @(posedge clock) begin
    if (i_reset) begin
        counter     <= 2'b00;
        prbs_enable <= 1'b0;
        ber_enable  <= 1'b0;
        rctx_enable <= 1'b0;
    end
    else begin
        counter <= counter + 1;
        if (counter == 2'b10) begin
            prbs_enable <= 1'b1;
            ber_enable  <= 1'b1;
            rctx_enable <= 1'b1;
        end
        else begin
            prbs_enable <= 1'b0;
            ber_enable  <= 1'b0;
            rctx_enable <= 1'b0;
        end
    end
end

always @(*) begin
    case (counter)
        2'b00 : w_coeffs = phase_0;
        2'b01 : w_coeffs = phase_1;
        2'b10 : w_coeffs = phase_2;
        2'b11 : w_coeffs = phase_3;
    endcase
end

PRBS9 //! Modulo para generar la PRBSI y PRBSQ
    #(
        .NB_BITS (NB_BITS),
        .NB_OUT  (1)
    )
    u_PRBS9
    (
        .clock     (clock),        
        .i_reset   (i_reset),        
        .i_enable  (i_sw[0]),
        .i_enable2 (prbs_enable),       
        .o_PRBS9I  (w_prbsI_out),         
        .o_PRBS9Q  (w_prbsQ_out)
    );

RC_TX //! Modulo RCTX_I
    #(
        .NB_SAMPLES  (NB_SAMPLES),
        .NBF_SAMPLES (NBF_SAMPLES), 
        .NB_COEFFS   (NB_COEFFS),
        .NBF_COEFFS  (NBF_COEFFS), 
        .NB_OUTPUT   (NB_OUTPUT), 
        .NBF_OUTPUT  (NBF_OUTPUT), 
        .N_COEFFS    (N_COEFFS)
    )
    u_RC_TXI
    (
        .clock     (clock),
        .i_reset   (i_reset),
        .i_enable  (i_sw[0]),
        .i_enable2 (rctx_enable),
        .i_sample  (w_prbsI_out),
        .i_coeffs  (w_coeffs),
        .o_sample  (w_rctxI_out)
    );

RC_TX //! Modulo RCTX_Q
    #(
        .NB_SAMPLES  (NB_SAMPLES),
        .NBF_SAMPLES (NBF_SAMPLES), 
        .NB_COEFFS   (NB_COEFFS),
        .NBF_COEFFS  (NBF_COEFFS), 
        .NB_OUTPUT   (NB_OUTPUT), 
        .NBF_OUTPUT  (NBF_OUTPUT), 
        .N_COEFFS    (N_COEFFS)
    )
    u_RC_TXQ
    (
        .clock     (clock),
        .i_reset   (i_reset),
        .i_enable  (i_sw[0]),
        .i_enable2 (rctx_enable),
        .i_sample  (w_prbsQ_out),
        .i_coeffs  (w_coeffs),
        .o_sample  (w_rctxQ_out)
    );

BER_v2 //! Modulo BER_I 
    #(
        .NB_INPUT  (NB_OUTPUT),
        .NBF_INPUT (NBF_OUTPUT),
        .N_PHASES  (4),
        .NB_SEL    (2),
        .NB_COUNT  (9),
        .N_PRBSMAX (511)
    )
  u_BER_I 
    (
        .clock           (clock),
        .i_reset         (i_reset),
        .i_enable        (i_sw[1]),
        .i_PRBS_in       (w_prbsI_out),
        .i_latreg_enable (ber_enable),
        .i_phase_sel     (i_sw[3:2]),
        .i_sample        (w_rctxI_out),
        .o_ledout        (w_ber0i)
        //Debug
        // .o_beraccum_deb       (o_beraccumi_deb      ),
        // .o_errorcount_deb     (o_errorcounti_deb    ),
        // .o_prbsshift_deb      (o_prbsshifti_deb     ),
        // .o_min_ber_deb        (o_min_beri_deb       ),
        // .o_lat_pos_deb        (o_lat_posi_deb       ),
        // .o_decoded_sample_deb (o_decoded_samplei_deb) 
    );

BER_v2 //! Modulo BER_Q
    #(
        .NB_INPUT  (NB_OUTPUT),
        .NBF_INPUT (NBF_OUTPUT),
        .N_PHASES  (4),
        .NB_SEL    (2),
        .NB_COUNT  (9),
        .N_PRBSMAX (511)
    )
  u_BER_Q 
    (
        .clock           (clock),
        .i_reset         (i_reset),
        .i_enable        (i_sw[1]),
        .i_PRBS_in       (w_prbsQ_out),
        .i_latreg_enable (ber_enable),
        .i_phase_sel     (i_sw[3:2]),
        .i_sample        (w_rctxQ_out),
        .o_ledout        (w_ber0q)
        //Debug
        // .o_beraccum_deb       (o_beraccumq_deb      ),
        // .o_errorcount_deb     (o_errorcountq_deb    ),
        // .o_prbsshift_deb      (o_prbsshiftq_deb     ),
        // .o_min_ber_deb        (o_min_berq_deb       ),
        // .o_lat_pos_deb        (o_lat_posq_deb       ),
        // .o_decoded_sample_deb (o_decoded_sampleq_deb) 
    );

assign o_ledout[0] = (i_reset == 1'b1) ? 1'b1 : 1'b0;
assign o_ledout[1] = (i_sw[0] == 1'b1) ? 1'b1 : 1'b0;
assign o_ledout[2] = (i_sw[1] == 1'b1) ? 1'b1 : 1'b0;
assign o_ledout[3] = (w_ber0i == 1'b1 & w_ber0q == 1'b1) ? 1'b1 : 1'b0;

// Debugging
// assign o_sampleI_deb     = w_rctxI_out; 
// assign o_sampleQ_deb     = w_rctxQ_out;
// assign o_counter_deb     = counter;      
// assign o_prbs_enable_deb = prbs_enable;
// assign o_ber_enable_deb  = ber_enable;
// assign o_rctx_enable_deb = rctx_enable;  
// assign o_prbsi_deb       = w_prbsI_out;
// assign o_prbsq_deb       = w_prbsQ_out;

endmodule