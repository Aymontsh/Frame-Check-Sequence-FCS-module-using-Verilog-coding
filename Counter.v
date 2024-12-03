
/*
// Module: Counter.v
// Description: Implement Counter module using verilog code 
// Owner : Mohamed Ayman Elsayed 
// Date : November 2022
*/

module Counter 
#( parameter IN_WIDTH   = 1024 )            // Max Input data Width

(
    // ------------------------ input & output ports -----------------------------

    input       wire                                        CLK,                // System Clk 
    input       wire                                        RST,                // Reset Signal
    input       wire        [ $clog2 (IN_WIDTH)-1 : 0 ]     Data_Size,          // Size of input data from 64 to 1024 bits                              
    input       wire                                        Cnt_En,             // Counter Enable
    output      wire                                        Cnt_done            // The Counter Finish


);

    // --------------------------- internal signals --------------------------------

    reg         [ $clog2 (IN_WIDTH)-1 : 0 ]         Counter;         
    reg         [ $clog2 (IN_WIDTH)-1 : 0 ]         Counter_value;

    // --------------------------- assign signals ---------------------------------- 

    assign Cnt_done = ( Counter == Data_Size-1 ) ? 1'b1 : 1'b0 ;

    // ------------------------- Counter Operation --------------------------------- 

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
            if ( Cnt_En )
                begin
                    Counter_value <= Counter + 1 ;  
                end
            else 
                begin
                   Counter_value <= 'd0; 
                end
        end

endmodule