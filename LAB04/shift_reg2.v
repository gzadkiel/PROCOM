module shift_reg2 #(
    parameter NB_SHIFT = 4
) (
    input                       clock,
    input                       i_reset,
    input                       i_SW,
    input                       i_valid,
    output  [NB_SHIFT - 1 : 0]  o_register2
);

reg [NB_SHIFT - 1 : 0]  shiftreg;

always @(posedge clock or negedge i_reset) begin
    if (!i_reset) begin
        shiftreg <= 4'b1001;
    end
    else if (i_valid) begin
        if(i_SW == 1'b1) begin
//            shiftreg[NB_SHIFT - 2] <= shiftreg[NB_SHIFT - 1];
//            shiftreg[NB_SHIFT - 3] <= shiftreg[0];
//            shiftreg[NB_SHIFT - 1] <= ~(shiftreg[NB_SHIFT - 2] ^ shiftreg[NB_SHIFT-3]);
//            shiftreg[0]            <= ~(shiftreg[0] ^ shiftreg[NB_SHIFT-3]);
            shiftreg[2] <= shiftreg[3];
            shiftreg[1] <= shiftreg[0];
            shiftreg[3] <= ~(shiftreg[2] ^ shiftreg[3]);
            shiftreg[0] <= ~(shiftreg[0] ^ shiftreg[1]);
        end
        else if (i_SW == 1'b0) begin
//            shiftreg[NB_SHIFT - 1] <= shiftreg[NB_SHIFT - 2];
//            shiftreg[0]            <= shiftreg[NB_SHIFT - 3];
//            shiftreg[NB_SHIFT - 2] <= ~(shiftreg[NB_SHIFT - 2] ^ shiftreg[NB_SHIFT-3]);
//            shiftreg[NB_SHIFT - 3] <= ~(shiftreg[NB_SHIFT] ^ shiftreg[NB_SHIFT-3]);
            shiftreg[3] <= shiftreg[2];
            shiftreg[0] <= shiftreg[1];
            shiftreg[2] <= ~(shiftreg[2] ^ shiftreg[3]);
            shiftreg[1] <= ~(shiftreg[1] ^ shiftreg[0]);
        end
    end
    else begin
        shiftreg <= shiftreg;
    end       
end

assign o_register2 = shiftreg;
    
endmodule