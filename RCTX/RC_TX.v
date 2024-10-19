module RC_TX #(
    parameter NB_SAMPLES  = 1, //! Bits totales de las muestras de entrada
    parameter NBF_SAMPLES = 0, //! Bits frac de las muestras de entrada
    parameter NB_COEFFS   = 8, //! Bits totales de los coef del filtro
    parameter NBF_COEFFS  = 7, //! Bits frac de los coef del filtro
    parameter NB_OUTPUT   = 8, //! Bits totales de la salida
    parameter NBF_OUTPUT  = 7, //! Bits frac de la salida
    parameter N_COEFFS    = 6  //! Numero de coeficientes del filtro
) (
    input                                         clock,     //! Reloj del sistema
    input                                         i_reset,   //! Reset del sistema
    input                                         i_enable,  //! Enable del sistema [i_SW[0]]
    input                                         i_enable2, //! Enable del control
    input          [NB_SAMPLES           - 1 : 0] i_sample,  //! Entrada de las muestras
    input          [(N_COEFFS*NB_COEFFS) - 1 : 0] i_coeffs,  //! Vector de los coeficientes, todos juntos
    output  signed [NB_OUTPUT            - 1 : 0] o_sample   //! Salida de muestras filtradas
);

// Localparam
localparam NB_ADDER  = NB_COEFFS + 3;                                           //! Numero de bits N_PROD = N_COEFFS, sumo 6 productos, osea que agrego log2(6) = 3 bits
localparam NBF_ADDER = NBF_COEFFS;                                              //! Numero de bits frac es igual al de los coeffs
localparam NBI_TRUNC = (NB_ADDER - NBF_ADDER) - ((NB_OUTPUT - NBF_OUTPUT) - 1); //! Bits enteros para truncar a la salida al analizar el signo

// Signals
reg         [N_COEFFS  - 1 : 0] r_shiftreg;                  //! Shiftreg para guardar las muestras de entrada (salida de la PRBS)
wire signed [NB_COEFFS - 1 : 0] w_coeffs [N_COEFFS - 1 : 0]; //! Almaceno los coefficientes
reg  signed [NB_COEFFS - 1 : 0] w_prod   [N_COEFFS - 1 : 0]; //! Almaceno los resultados de los productos
reg  signed [NB_ADDER  - 1 : 0] adder_coeffs;                //! Valor de la muestra de salida

integer ptrAdd;

generate 
    genvar pointer;
    for (pointer = 0 ; pointer < N_COEFFS ; pointer = pointer + 1) begin:coeff_Assign
        assign w_coeffs[pointer] = i_coeffs[(pointer + 1)*NB_COEFFS - 1 -: NB_COEFFS]; 
        end
endgenerate

always @(posedge clock) begin
    if (i_reset) begin
        r_shiftreg <= {N_COEFFS{1'b0}};
    end
    else if (i_enable & i_enable2) begin
        r_shiftreg               <= r_shiftreg >> 1;
        r_shiftreg[N_COEFFS - 1] <= i_sample;
    end
    else begin
        r_shiftreg <= r_shiftreg;
    end
end

always @(*) begin
    case (r_shiftreg[5])
        1'b0 : w_prod[0] = -w_coeffs[0];
        1'b1 : w_prod[0] = w_coeffs[0];
    endcase
    case (r_shiftreg[4]) 
        1'b0 : w_prod[1] = -w_coeffs[1]; 
        1'b1 : w_prod[1] = w_coeffs[1];  
    endcase
    case (r_shiftreg[3])
        1'b0 : w_prod[2] = -w_coeffs[2];
        1'b1 : w_prod[2] = w_coeffs[2];   
    endcase
    case (r_shiftreg[2])
        1'b0 : w_prod[3] = -w_coeffs[3];
        1'b1 : w_prod[3] = w_coeffs[3];   
    endcase
    case (r_shiftreg[1])
        1'b0 : w_prod[4] = -w_coeffs[4];
        1'b1 : w_prod[4] = w_coeffs[4];   
    endcase
    case (r_shiftreg[0])
        1'b0 : w_prod[5] = -w_coeffs[5];
        1'b1 : w_prod[5] = w_coeffs[5]; 
    endcase

    adder_coeffs = 0;
    for (ptrAdd = 0 ; ptrAdd < N_COEFFS ; ptrAdd = ptrAdd + 1) begin
        adder_coeffs = adder_coeffs + w_prod[ptrAdd]; //! Arbol de suma concatenado
    end
end

assign o_sample = (~|adder_coeffs[(NB_ADDER - 1) -: NBI_TRUNC] || &adder_coeffs[(NB_ADDER - 1) -: NBI_TRUNC]) ? 
                adder_coeffs[NB_ADDER - NBI_TRUNC -: NB_OUTPUT] : (adder_coeffs[NB_ADDER - 1]) ? 
                {1'b1,{NB_OUTPUT - 1{1'b0}}} : {1'b0,{NB_OUTPUT - 1{1'b1}}};

endmodule