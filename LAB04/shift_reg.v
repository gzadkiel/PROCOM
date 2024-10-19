module shift_reg #(
    parameter NB_SHIFT      = 4
) (
    input                           clock,
    input                           i_reset,
    input                           i_SW,
    input                           i_valid,
    output  [NB_SHIFT - 1 : 0]      o_register
);


// Variables
reg [NB_SHIFT - 1 : 0]  shiftreg;

always @(posedge clock or negedge i_reset) begin
    if (!i_reset) begin
        shiftreg <= {{NB_SHIFT-1{1'b0}},1'b1};
    end 
    else if (i_valid) begin
        if (i_SW == 1'b1) begin 
            shiftreg    <= shiftreg << 1;
            shiftreg[0] <= shiftreg[NB_SHIFT-1];
        end
        else if (i_SW == 1'b0) begin
            shiftreg                <= shiftreg >> 1;
            shiftreg[NB_SHIFT-1]    <= shiftreg[0];
        end
    end
    else begin
        shiftreg <= shiftreg;
    end
end

assign o_register = shiftreg;

endmodule