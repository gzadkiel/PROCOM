
module comm_sys_PRBSRCTX_tb;

  // Parameters
  localparam  NB_SAMPLES = 1;
  localparam  NBF_SAMPLES = 0;
  localparam  NB_COEFFS = 8;
  localparam  NBF_COEFFS = 7;
  localparam  NB_OUTPUT = 8;
  localparam  NBF_OUTPUT = 7;
  localparam  N_COEFFS = 6;
  localparam  NB_BITS = 9;

  //Ports
  reg clock;
  reg i_reset;
  reg i_sw;
  wire signed [NB_OUTPUT - 1 : 0] o_sampleI;
  wire signed [NB_OUTPUT - 1 : 0] o_sampleQ;


  comm_sys_PRBSRCTX # (
    .NB_SAMPLES(NB_SAMPLES),
    .NBF_SAMPLES(NBF_SAMPLES),
    .NB_COEFFS(NB_COEFFS),
    .NBF_COEFFS(NBF_COEFFS),
    .NB_OUTPUT(NB_OUTPUT),
    .NBF_OUTPUT(NBF_OUTPUT),
    .N_COEFFS(N_COEFFS),
    .NB_BITS(NB_BITS)
  )
  comm_sys_PRBSRCTX_inst (
    .clock(clock),
    .i_reset(i_reset),
    .i_sw(i_sw),
    .o_sampleI(o_sampleI),
    .o_sampleQ(o_sampleQ)
  );

always #5  clock = ~clock;

initial begin
    clock     = 1'b0;
    i_reset   = 1'b1;
    i_sw   = 1'b0;
    
    #100 i_reset   = 1'b0;
    #100 i_sw       = 1'b1;
    
    #5000 $finish;
end

endmodule