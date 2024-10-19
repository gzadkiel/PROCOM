module comm_sys_tb;

// Parameters
localparam NB_SAMPLES  = 1;  
localparam NBF_SAMPLES = 0;
localparam NB_COEFFS   = 11;  
localparam NBF_COEFFS  = 10;  
localparam NB_OUTPUT   = 8;  
localparam NBF_OUTPUT  = 7;  
localparam N_COEFFS    = 6;  
localparam NB_BITS     = 9;  
localparam NB_SW       = 4;
localparam NB_OLEDS    = 4;
//Ports
reg                     clock;
reg                     i_reset;
reg  [NB_SW    - 1 : 0] i_sw;
wire [NB_OLEDS - 1 : 0] o_ledout;

// Debug
//wire signed [NB_OUTPUT - 1 : 0] o_sampleI_deb;
//wire signed [NB_OUTPUT - 1 : 0] o_sampleQ_deb;
//wire        [1             : 0] o_counter_deb;     
//wire                            o_prbs_enable_deb;
//wire                            o_ber_enable_deb;
//wire                            o_rctx_enable_deb;  
//wire                            o_prbsi_deb;
//wire                            o_prbsq_deb;
// wire [9  - 1        : 0] o_beraccumi_deb      ;
// wire [9  - 1        : 0] o_beraccumq_deb      ;
// wire [9  - 1        : 0] o_errorcounti_deb    ;
// wire [9  - 1        : 0] o_errorcountq_deb    ;
// wire [511 - 1       : 0] o_prbsshifti_deb     ;
// wire [511 - 1       : 0] o_prbsshiftq_deb     ;
// wire [9  - 1        : 0] o_min_beri_deb       ;
// wire [9  - 1        : 0] o_min_berq_deb       ;
// wire [4             : 0] o_lat_posi_deb       ;
// wire [4             : 0] o_lat_posq_deb       ;
// wire                     o_decoded_samplei_deb;
// wire                     o_decoded_sampleq_deb;
                       

comm_sys # (
  .NB_SAMPLES(NB_SAMPLES),
  .NBF_SAMPLES(NBF_SAMPLES),
  .NB_COEFFS(NB_COEFFS),
  .NBF_COEFFS(NBF_COEFFS),
  .NB_OUTPUT(NB_OUTPUT),
  .NBF_OUTPUT(NBF_OUTPUT),
  .N_COEFFS(N_COEFFS),
  .NB_BITS(NB_BITS),
  .NB_SW(NB_SW),
  .NB_OLEDS(NB_OLEDS)
)
comm_sys_inst (
  .clock(clock),
  .i_reset(i_reset),
  .i_sw(i_sw),
  .o_ledout(o_ledout)
  // DEBUG
//  .o_sampleI_deb(o_sampleI_deb),
//  .o_sampleQ_deb(o_sampleQ_deb), 
//  .o_counter_deb(o_counter_deb),      
//  .o_prbs_enable_deb(o_prbs_enable_deb),
//  .o_ber_enable_deb(o_ber_enable_deb),
//  .o_rctx_enable_deb(o_rctx_enable_deb),  
//  .o_prbsi_deb(o_prbsi_deb),
//  .o_prbsq_deb(o_prbsq_deb)
  // .o_beraccumi_deb      (o_beraccumi_deb ),
  // .o_beraccumq_deb      (o_beraccumq_deb ),
  // .o_errorcounti_deb    (o_errorcounti_deb ),
  // .o_errorcountq_deb    (o_errorcountq_deb ),
  // .o_prbsshifti_deb     (o_prbsshifti_deb ),
  // .o_prbsshiftq_deb     (o_prbsshiftq_deb ),
  // .o_min_beri_deb       (o_min_beri_deb ),
  // .o_min_berq_deb       (o_min_berq_deb ),
  // .o_lat_posi_deb       (o_lat_posi_deb ),
  // .o_lat_posq_deb       (o_lat_posq_deb ),
  // .o_decoded_samplei_deb(o_decoded_samplei_deb ),
  // .o_decoded_sampleq_deb(o_decoded_sampleq_deb )
);

always #5  clock = ~clock;

initial begin
    clock     = 1'b0;
    i_reset   = 1'b1;
    i_sw[0]   = 1'b0;
    i_sw[1]   = 1'b0;
    i_sw[3:2] = 2'b00;

    #100 i_reset   = 1'b0;
    #100 i_sw[0]   = 1'b1;
    #50  i_sw[1]   = 1'b1;
    #50  i_sw[3:2] = 2'b01;
    
    #500000 $finish;
end

endmodule