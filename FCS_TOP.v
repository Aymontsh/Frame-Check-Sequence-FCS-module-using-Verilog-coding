
/*
// Module: FCS_TOP.v
// Description: Implement top module for FCS arch using verilog code 
// Owner : Mohamed Ayman Elsayed 
// Date : November 2022
*/

module FCS_TOP 
#(  parameter   GEN_WIDTH   = 17 ,                      // Standard generator width
                Rem_WIDTH   = GEN_WIDTH - 1,            // Remainder width
                Max_IN_WIDTH   = 1024 ,                 // Max Input data Width
                Min_IN_WIDTH   = 64                     // Min Input data Width              
 )

( 

    // ------------------------ input & output ports -----------------------------

    input       wire                                        CLK,                // System Clk 
    input       wire                                        RST,                // Reset Signal
    input       wire                                        Valid_Data,         // Valid Signal
    input       wire    [ $clog2 (Max_IN_WIDTH)-1 : 0 ]     Data_Size,          // Size of input data
    input       wire                                        Input_Data,         // Serial Input Data Field
    output      wire                                        OUT,                // Output Serial Data
    output      wire                                        Done,               // The shifted operation is done
    output      wire                                        Valid_OUT,          // Valid signal for output Data
    output      wire                                        Busy                // Busy signal
    
                                      
);

    parameter   Stand_Gen    = 17'b10001000000100001;                            // Standard Generator bits

    // ---------------------------- internal signals ------------------------------

    wire                                            Cnt_done;                       // The Counter Finish
    wire                                            Cnt_En;                         // Counter Enable
    wire                                            Enable;                         // Enable for FCS operation
    wire    [       Rem_WIDTH-1       : 0 ]         FCS;                            // FCS Result   
    wire                                            Shift_enable;
    wire                                            Shift_done;                   

    // ----------------------------- assign signals ------------------------------

    assign Done       = Shift_done;

    // --------------------------- FSM Instantation -------------------------------

    SYS_CTRL #( .Max_IN_WIDTH ( Max_IN_WIDTH ) , .Min_IN_WIDTH ( Min_IN_WIDTH ) ) SYS_CTRL_I0 (

        .CLK ( CLK ),
        .RST ( RST ),
        .Valid_Data ( Valid_Data ),
        .Cnt_done ( Cnt_done ),
        .Data_Size ( Data_Size ),
        .Shift_done ( Shift_done ),
        .Shift_enable ( Shift_enable ),
        .Cnt_En ( Cnt_En ),
        .Enable ( Enable ),
        .Busy ( Busy )
    );

    // --------------------------- Counter Instantation -------------------------------

    Counter #( .IN_WIDTH ( Max_IN_WIDTH ) ) Counter_I0 (

        .CLK ( CLK ),
        .RST ( RST ),    
        .Data_Size ( Data_Size ),
        .Cnt_En ( Cnt_En ),
        .Cnt_done ( Cnt_done )

    );

    // --------------------------- FCS Instantation -------------------------------

    FCS #( .GEN_WIDTH ( GEN_WIDTH ) , .Rem_WIDTH ( Rem_WIDTH ) )  FCS_I0 (

        .CLK ( CLK ),
        .RST ( RST ),
        .Stand_Gen ( Stand_Gen ),
        .Input_Data ( Input_Data ),
        .Cnt_done ( Cnt_done ),
        .Enable ( Enable ),
        .FCS ( FCS )
    );

    // --------------------- Shift Register Instantation -----------------------------

    Shift_Register #( .GEN_WIDTH ( GEN_WIDTH ) , .Rem_WIDTH (Rem_WIDTH) )  SR_I0 (

        .FCS_result ( FCS ),
        .CLK ( CLK ),
        .RST ( RST ),
        .Valid_Out ( Valid_OUT ),
        .Shift_enable ( Shift_enable ),
        .Shift_done ( Shift_done ),
        .Ser_Data ( OUT )
    );

endmodule
