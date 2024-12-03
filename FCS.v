
/*
// Module: FCS.v
// Description: Implement the Frame Check Sequence (FCS) Operation using verilog code 
// Owner : Mohamed Ayman Elsayed 
// Date : November 2022
*/

module FCS 
#(  parameter   GEN_WIDTH   = 17 ,                      // Standard generator width
                Rem_WIDTH   = GEN_WIDTH - 1             // Remainder width
)

(

    // ------------------------ input & output ports -----------------------------

    input   wire                                    CLK,                // System clock            
    input   wire                                    RST,                // Reset Signal
    input   wire        [ GEN_WIDTH-1 : 0 ]         Stand_Gen,          // Standard Generator bits
    input   wire                                    Input_Data,         // Serial Input Data Field
    input   wire                                    Cnt_done,           // The Counter Finish
    input   wire                                    Enable,             // Enable for FCS operation
    output  reg         [ Rem_WIDTH-1 : 0 ]         FCS                 // FCS Result           

);

    // --------------------------- internal signals --------------------------------

    reg                 [ Rem_WIDTH-1 : 0 ]         FCS_value;
    wire                                            feedback;
    wire                                            Xor_Result1;
    wire                                            Xor_Result2;

    // --------------------------- assign signals --------------------------------

    assign feedback     = FCS[15] ^ Input_Data ;
    assign Xor_Result1  = feedback ^ FCS [4] ;
    assign Xor_Result2  = feedback ^ FCS [11] ;

    // --------------------------- FCS Operation --------------------------------

    always @( posedge CLK or negedge RST )
        begin
            if ( !RST )
                begin
                    FCS <= 'd0;                  
                end
            else  
                begin
                    FCS <= FCS_value;
                end
        end

    always  @(*)
        begin
            if ( Enable )
                begin
                    if ( !Cnt_done )
                        begin
                            FCS_value   = { FCS [ 14 : 12 ] , Xor_Result2 , FCS [ 10 : 5 ] , Xor_Result1 , FCS [ 3 : 0 ] , feedback } ;
                        end
                    else
                        begin
                            FCS_value   = FCS ;  
                        end
                end
            else
                begin
                    FCS_value   = 'd0 ; 
                end
        end


endmodule