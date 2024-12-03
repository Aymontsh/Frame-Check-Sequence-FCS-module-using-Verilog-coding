
/*
// Module: Shift_Register.v
// Description: Implement Shift Register module using verilog code 
// Owner : Mohamed Ayman Elsayed 
// Date : November 2022
*/

module Shift_Register 
#(  parameter   GEN_WIDTH   = 17 ,                      // Standard generator width
                Rem_WIDTH   = GEN_WIDTH - 1             // Remainder width            
 )

(

    // ------------------------ input & output ports -----------------------------

    input       wire        [ Rem_WIDTH-1 : 0 ]         FCS_result,     // FCS result 
    input       wire                                    CLK,            // System Clk
    input       wire                                    RST,            // Reset Signal
    input       wire                                    Shift_enable,   // Enable for Shift operation
    output      reg                                     Valid_Out,      // Valid for output Data
    output      reg                                     Shift_done,     // Shift operation Done
    output      reg                                     Ser_Data        // output serial data 
);

    // ---------------------------- internal signals ------------------------------

    reg             [ $clog2 (Rem_WIDTH) : 0 ]          Counter;
    reg             [ $clog2 (Rem_WIDTH) : 0 ]          Counter_value;
    reg             [ Rem_WIDTH-1 : 0 ]                 shift_registers;
    wire                                                NEW_DATA;          
    wire                                                Shift_done_value;             

    // ---------------------------- assign signals ----------------------------------

    assign  Shift_done_value    = ( Counter  == Rem_WIDTH ) ? 1'b1 : 1'b0 ;
    assign  NEW_DATA            = ( Shift_enable == 1'b1 && Counter  == 5'd0 ) ? 1'b1 : 1'b0 ;
    assign  Valid_Out_value     = ( NEW_DATA == 1'b1 )    ? 1'b1 : 1'b0 ;
    
    // ---------------------------------- Counter ------------------------------------

    always @ ( posedge CLK or negedge RST )
        begin
            if ( !RST )
                begin
                    Counter <= 'd0;                  
                end
            else
                begin
                    Counter <= Counter_value;
                end
        end

    always @(*)
        begin
            if ( Shift_enable )
                begin
                    Counter_value <= Counter + 1 ;  
                end
            else 
                begin
                   Counter_value <= 'd0; 
                end
        end
    
    // ----------------------------- Shift Operation ------------------------------------

    always @( posedge CLK or negedge RST )
        begin
            if ( !RST )
                begin
                    Valid_Out <= 'd0;
                end
            else
                begin
                    Valid_Out <= Valid_Out_value;
                end 
        end

    always @( posedge CLK or negedge RST )
        begin
            if ( !RST )
                begin
                    Shift_done <= 'd0;
                end
            else
                begin
                    Shift_done <= Shift_done_value;
                end 
        end    

    always @( posedge CLK or negedge RST )
        begin
            if ( !RST )
                begin
                    Ser_Data  <= 'd0;
                    shift_registers <= 'd0;
                end
            else if ( NEW_DATA )
                begin
                    shift_registers <= FCS_result;
                    Ser_Data <= FCS_result [0];
                end
            else if ( Shift_enable && !Shift_done )
                begin
                    { shift_registers [ Rem_WIDTH-1 : 1 ] , Ser_Data } <= { 1'b0 , shift_registers [ Rem_WIDTH-1 : 1 ] };
                end
            else 
                begin
                    Ser_Data        <= 'd0;
                    shift_registers <= 'd0;                    
                end
        end

endmodule 