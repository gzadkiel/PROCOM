module PRBS9 #(
    parameter   NB_BITS = 9, //! Cantidad de bits de la seed
    parameter   NB_OUT  = 1  //! Bits a la salida para representar 0 y 1
) (
    input                   clock,     //! Reloj del sistema
    input                   i_reset,   //! Reset del sistema
    input                   i_enable,  //! Entrada de enable i_sw[0]
    input                   i_enable2, //! Entrada de enable del control
    output [NB_OUT - 1 : 0] o_PRBS9I,  //! Salida de la PRBS en fase (PRBS9I)
    output [NB_OUT - 1 : 0] o_PRBS9Q   //! Salida de la PRBS en cuadratura (PRBS9Q)
);

reg [NB_BITS - 1 : 0] PRBSI; //! Seed de la PRBS en fase
reg [NB_BITS - 1 : 0] PRBSQ; //! Seed de la PRBS en cuadratura

always @(posedge clock) begin
    if (i_reset) begin
        PRBSI <= 9'h1AA;
        PRBSQ <= 9'h1FE;
    end
    else if (i_enable & i_enable2) begin
        PRBSI    <= PRBSI >> 1;
        PRBSQ    <= PRBSQ >> 1; 
        PRBSI[8] <= PRBSI[5] ^ PRBSI[0];
        PRBSQ[8] <= PRBSQ[5] ^ PRBSQ[0];
    end
    else begin
        PRBSI    <= PRBSI;
        PRBSQ    <= PRBSQ;
    end
end

assign o_PRBS9I = PRBSI[0];
assign o_PRBS9Q = PRBSQ[0];

// Si tengo i_out_enable (25MHz) genero una muestra a la salida, sino pongo alta impedancia:
// Si el bit de la PRBS es 1, entonces se codifica al 1, sale 2'b01
// Si el bit de la PRBS es 0, entonces se codifica al -1, sale 2'b11
// assign o_PRBS9I = (i_out_enable == 1'b1) ? ((PRBSI[8] == 1'b1) ? 2'b01 : 2'b11) : 2'bzz;
// assign o_PRBS9Q = (i_out_enable == 1'b1) ? ((PRBSI[8] == 1'b1) ? 2'b01 : 2'b11) : 2'bzz;
    
endmodule
