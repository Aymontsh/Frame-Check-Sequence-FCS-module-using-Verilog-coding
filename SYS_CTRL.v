
/*
// Module: SYS_CTRL.v
// Description: Implement Finite State machine to control FCS operation using verilog code 
// Owner : Mohamed Ayman Elsayed 
// Date : November 2022
*/

module SYS_CTRL 
#( parameter Max_IN_WIDTH   = 1024 ,            // Max Input data Width
             Min_IN_WIDTH   = 64                // Min Input data Width
 )            

(

    // ------------------------ input & output ports -----------------------------

    input       wire                                        CLK,                // System Clk 
    input       wire                                        RST,                // Reset Signal 
    input       wire                                        Valid_Data,         // Valid Signal               
    input       wire                                        Cnt_done,           // The Counter Finish
    input       wire    [ $clog2 (Max_IN_WIDTH)-1 : 0 ]     Data_Size,          // Size of input data 
    input       wire                                        Shift_done,         // Shift operation Done
    output      reg                                         Shift_enable,       // Enable for Shift operation
    output      reg                                         Cnt_En,             // Counter Enable   
    output      reg                                         Enable,             // Enable for FCS operation
    output      reg                                         Busy                // Busy signal 
    

);

    // --------------------------- internal signals -------------------------------- 

    reg       [1:0]     current_state , next_state;
    wire                Size_condition;                
    reg                 Busy_value;

    // --------------------------- assign signals ---------------------------------- 

    assign Size_condition  = ( ( Data_Size >= Min_IN_WIDTH ) && ( Data_Size <= Max_IN_WIDTH ) ) ? 1'b1 : 1'b0 ;

    // --------------------------  State Encoding ----------------------------------

    localparam  IDLE            = 2'b00,                     // Waitng the releasing of Valid signal 
                FCS_Operation   = 2'b01,                     // FCS operation
                Shift           = 2'b10;                     // Shift Operation   

    // ---------------------- Registered the Busy signal -----------------------------

    always @( posedge CLK or negedge RST )
        begin
            if ( !RST )
                begin
                    Busy <= 'd0;
                end
            else
                begin
                    Busy <= Busy_value;
                end
        end

    // ------------------------- State Transition -------------------------------

    always @ ( posedge CLK or negedge RST )

        begin
            if (!RST)
                begin
                    current_state <= IDLE;
                end
            else
                begin
                    current_state <= next_state;
                end
        end        

    // ------------------------ Next state logic ------------------------------

    always @(*)

        begin

            // initial values 
            
            next_state  = IDLE ;

            case ( current_state )

                IDLE    :   begin

                                if ( Valid_Data && Size_condition )
                                    begin
                                        next_state  = FCS_Operation ;
                                    end
                                else
                                    begin
                                        next_state  = IDLE ;
                                    end
                            end  

             FCS_Operation  :   begin

                                if ( Cnt_done )

                                    begin
                                        next_state  = Shift ;
                                    end
                                else
                                    begin
                                        next_state  = FCS_Operation ;
                                    end                                
                            end

                Shift   :   begin

                                if ( Shift_done )

                                    begin
                                       next_state  = IDLE ; 
                                    end
                                else
                                    begin
                                        next_state  = Shift ;
                                    end
                            end

                default :   begin
                                next_state  = IDLE ;
                            end

            endcase
        end
    
    // -------------------------- Output logic --------------------------------
    
    always @(*)

        begin
            
            // initial values
            
            Cnt_En       = 'b0;
            Enable       = 'b0;
            Shift_enable = 'b0;
            Busy_value   = 'b0;

            case ( current_state )

                IDLE    :   begin
                                Cnt_En       = 'b0;
                                Enable       = 'b0;
                                Shift_enable = 'b0;

                                if ( Valid_Data && Size_condition )
                                    begin
                                        Busy_value   = 'b1;
                                    end
                                else
                                    begin
                                        Busy_value   = 'b0;
                                    end
                                
                            end  

              FCS_Operation :   begin
                                Cnt_En       = 'b1;
                                Enable       = 'b1;
                                Shift_enable = 'b0;   
                                Busy_value   = 'b1;                          
                            end

                Shift   :   begin
                                Cnt_En       = 'b0;
                                Enable       = 'b0;
                                Shift_enable = 'b1; 
                                
                                if ( Shift_done )
                                    begin
                                       Busy_value   = 'b0; 
                                    end
                                else
                                    begin
                                        Busy_value   = 'b1;
                                    end   
                            end

                default :   begin
                                Cnt_En       = 'b0;
                                Enable       = 'b0;
                                Shift_enable = 'b0;
                                Busy_value   = 'b0;
                            end
            endcase
        
        end
        
endmodule

