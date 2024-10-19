module counter_comp #(
    parameter NB_SW         = 4,
    parameter NB_COUNTER    = 32
) (
    output                  o_valid,    //! Output to enable shiftreg/flash
    input [NB_SW - 2 : 0]   i_sw,       //! Counter limit selector
    input                   i_reset,    //! System reset
    input                   clock       //! System clock
);

// Parametros
//localparam R0 = (2**(NB_COUNTER-10))-1;
localparam R0 = 'd10;       //! Counter limit for switch[2:1] = 2'b00
localparam R1 = 'd50;       //! Counter limit for switch[2:1] = 2'b01
localparam R2 = 'd100;      //! Counter limit for switch[2:1] = 2'b10
localparam R3 = 'd500;      //! Counter limit for switch[2:1] = 2'b11

// Variables
reg [NB_COUNTER - 1 : 0]    counter;
reg                         valid;
reg [NB_COUNTER - 1 : 0]    limit_ref;

always @(*) begin        
    case (i_sw[2:1])
        2'b00: limit_ref = R0;
        2'b01: limit_ref = R1;
        2'b10: limit_ref = R2;
        2'b11: limit_ref = R3;
    endcase
end

always @(posedge clock or negedge i_reset) begin
    if(!i_reset) begin
        counter <= {NB_COUNTER{1'b0}};
        valid   <= 1'b0;
    end
    else if (i_sw[0]) begin
        if(counter < limit_ref) begin
            counter <= counter + {{NB_COUNTER-1{1'b0}},{1'b1}};
            valid   <= 1'b0;
        end
        else begin
            counter <= {NB_COUNTER{1'b0}};
            valid   <= 1'b1;
        end
    end
    else begin
        counter <= counter;
        valid   <= valid;
    end

end

assign o_valid = valid;
// assign o_count = counter; //// ADDED BORRAR
    
endmodule