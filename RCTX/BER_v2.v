module BER_v2 #(
    parameter NB_INPUT  = 8,  //! Bits de la muestra de entrada (salida del filtro) 
    parameter NBF_INPUT = 7,  //! Bits frac de la muestra de entrada (salida del filtro)
    parameter N_PHASES  = 4,  //! Cantidad de fases de muestreo
    parameter NB_SEL    = 2,  //! Bits del selector para eligir la fase de muestreo
    parameter NB_COUNT  = 9,  //! Bits del contador para contar 511 muestras
    parameter N_PRBSMAX = 511 //! Maxima latencia posible del sistema
) (
    input                            clock,           //! Clock del sistema  
    input                            i_reset,         //! Reset del sistema
    input                            i_enable,        //! Enable del receptor
    input                            i_PRBS_in,       //! Muestra de entrada de ref de la PRBS
    input                            i_latreg_enable, //! Enable para recibir una muestra de la PRBS
    input         [NB_SEL   - 1 : 0] i_phase_sel,     //! Selector de fase de muestreo
    input  signed [NB_INPUT - 1 : 0] i_sample,        //! Muestra de entrada 
    output                           o_ledout         //! LED de salida para BER = 0               
);

// Localparam
localparam phase_pos0 = 0;
localparam phase_pos1 = 1;
localparam phase_pos2 = 2;
localparam phase_pos3 = 3;

// Signals
reg signed [NB_INPUT  - 1 : 0] r_shiftreg [N_PHASES - 1 : 0]; //! Buffer de salida del filtro para downsampling
reg        [NB_COUNT  - 1 : 0] r_beraccum;                    //! Contador de 511 muestras recibidas
reg        [NB_COUNT  - 1 : 0] r_errorcount;                  //! Contador de errores
reg        [NB_COUNT  - 1 : 0] r_min_ber;                     //! Registro para guardar el umbral del minimo de errores
reg        [N_PRBSMAX - 1 : 0] r_prbsshift;                   //! Shiftreg con PRBS para encontrar latencia del sistema
// reg        [4             : 0] r_lat_pos;                     //! Registro para guardar la posicion de latencia del sistema
reg                            w_decoded_sample;              //! Muestra que se recibe decodificada

integer lat_pos;
integer phase_pos;
integer ptrSr;

always @(posedge clock) begin:downsamBuffer //! Shiftregister para las muestras de salida del filtro
    if(i_reset) begin
        for (ptrSr = 0 ; ptrSr < (N_PHASES) ; ptrSr = ptrSr + 1) begin
            r_shiftreg[ptrSr] <= {NB_INPUT{1'b0}}; 
        end
    end
    else if (i_enable) begin
        for (ptrSr = 0 ; ptrSr < (N_PHASES - 1) ; ptrSr = ptrSr + 1) begin
            r_shiftreg[ptrSr + 1] <= r_shiftreg[ptrSr]; 
        end
        r_shiftreg[0] <= i_sample; 
    end
    else begin
        for (ptrSr = 0 ; ptrSr < (N_PHASES) ; ptrSr = ptrSr + 1) begin
            r_shiftreg[ptrSr] <= r_shiftreg[ptrSr];
        end
    end
end

always @(posedge clock) begin:PRBSlatReg //! Shiftregister para los bits de referencia de la PRBS
    if (i_reset) begin
        r_prbsshift <= {N_PRBSMAX{1'b0}};
    end
    else if (i_enable & i_latreg_enable) begin
        r_prbsshift    <= r_prbsshift << 1;
        r_prbsshift[0] <= i_PRBS_in;
    end
    else begin
        r_prbsshift <= r_prbsshift;
    end
end

always @(*) begin:phaseSelect //! Selector de fase de muestreo 
    case (i_phase_sel)
        2'b00 : phase_pos = phase_pos0;
        2'b01 : phase_pos = phase_pos1;
        2'b10 : phase_pos = phase_pos2;
        2'b11 : phase_pos = phase_pos3;
    endcase
end

// antes no usaba clock
always @(posedge clock) begin:sampleDecode //! Decoder para convertir la muestra recibida en 0/1
    if (i_reset) begin
        w_decoded_sample <= 1'b0;
    end
    else if (i_enable & i_latreg_enable) begin
        if (r_shiftreg[3] > 0) begin
            w_decoded_sample <= 1'b1;
        end
        else begin
            w_decoded_sample <= 1'b0;
        end
    end
end

always @(posedge clock) begin:latFinder //! Contador de errores y buscador de latencia del sistema
    if (i_reset) begin
        r_beraccum   <= {NB_COUNT{1'b0}};
        r_errorcount <= {NB_COUNT{1'b0}};
        lat_pos      <= 0;
        r_min_ber    <= 9'b001100100;
    end
    if (i_enable & i_latreg_enable) begin
        r_beraccum   <= r_beraccum   + 1'b1;
        r_errorcount <= r_errorcount + (w_decoded_sample ^ r_prbsshift[lat_pos]);
        if (r_beraccum == 511) begin
            r_beraccum   <= {NB_COUNT{1'b0}};
            r_errorcount <= {NB_COUNT{1'b0}};
            if (r_errorcount > r_min_ber) begin
                lat_pos      <= lat_pos + 1;
                r_min_ber    <= r_min_ber;
            end
            else begin
                lat_pos   <= lat_pos;
                r_min_ber <= r_errorcount;
            end
        end 
    end
end

assign o_ledout = (r_errorcount == {NB_COUNT{1'b0}}) ?  1'b1 : 1'b0;
    
endmodule