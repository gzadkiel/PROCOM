module flash #(
    parameter NB_FLASH      = 4
    ) 
    (
    input                       clock,          //! System clock
    input                       i_reset,        //! System reset 
    input                       i_valid,        //! Enable signal
    output [NB_FLASH - 1 : 0]   o_flash         //! LED output
    );
    
// Variables
reg [NB_FLASH - 1 : 0]  flash;                  //! 

always @(posedge clock or negedge i_reset) begin :Behaviour
    if (!i_reset) begin
        flash <= {NB_FLASH{1'b1}};
    end
    else begin
        if (i_valid) begin
            flash <= ~flash;
        end
    end
end

assign o_flash = flash;

endmodule