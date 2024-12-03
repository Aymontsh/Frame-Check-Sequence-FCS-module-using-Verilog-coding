
/*
// Module: FCS_TOP_tb.v
// Description: Implement a testbench for FSC top module using verilog code 
// Owner : Mohamed Ayman Elsayed 
// Date : November 2022
*/

`timescale 1ns/1ps

module FCS_TOP_tb ();

// ------------------------ parameters & integers -------------------------

parameter   GEN_WIDTH_tb        = 17 ;
parameter   Rem_WIDTH_tb        = GEN_WIDTH_tb - 1 ;
parameter   Max_IN_WIDTH_tb     = 1024 ;
parameter   Min_IN_WIDTH_tb     = 64 ;
integer     i;

// ------------------------ internal signals -------------------------

reg     [ Min_IN_WIDTH_tb-1 : 0 ]       DATA;
reg     [ Rem_WIDTH_tb-1    : 0 ]       Expected_OUT;

// ---------------------------- DUT Signals ------------------------------

reg                                             CLK_tb;
reg                                             RST_tb;
reg                                             Valid_Data_tb;
reg     [ $clog2 (Max_IN_WIDTH_tb)-1 : 0 ]      Data_Size_tb;
reg                                             Input_Data_tb;
wire                                            OUT_tb;
wire                                            Done_tb;
wire                                            Valid_OUT_tb; 
wire                                            Busy_tb;                                  

// -------------- Initial block ------------------

initial

    begin

        initialize ();

        reset ();

        Operation ();

        Test ();

        #700

        $stop;
        
    end

// ----------------------- Intialize operation ---------------------------

task initialize ();
    begin
        CLK_tb          = 'b0;
        RST_tb          = 'b0;
        Valid_Data_tb   = 'b0;
        Data_Size_tb    = 'b0;        
        Input_Data_tb   = 'b0;
    end
endtask

// ------------------------- Reset operation ----------------------------

task reset ();
    begin
        @( negedge CLK_tb )
        RST_tb        = 'b1;
    end
endtask

// -------------------------- FCS operation ----------------------------

task Operation ();
    begin

        DATA            = 'b00000000_00000000_00000000_00000000_00000000_01000000_00000000_01010110;
        Expected_OUT    = 'b0010011110011110;
        Data_Size_tb    = 'd64;

        @(posedge CLK_tb);
        Input_Data_tb = DATA [Data_Size_tb - 1];
        Valid_Data_tb = 'b1;

        @(posedge CLK_tb);
        Input_Data_tb = DATA [Data_Size_tb - 2];
        Valid_Data_tb = 'b0;

        for ( i = 2 ; i < Data_Size_tb ; i = i + 1 )
            begin
                @(posedge CLK_tb);
                Input_Data_tb = DATA [ Data_Size_tb - 1 - i ];
            end
        
    end
endtask

task Test ();
    begin
        @( posedge Valid_OUT_tb )
        
        for ( i = 0 ; i < Rem_WIDTH_tb ; i = i + 1 )
            begin
                @(posedge CLK_tb);
                if ( OUT_tb == Expected_OUT [i] )
                    begin
                        $display ( "OUT [%0d] IS Correct",i);
                    end
                else
                    begin
                        $display ( "OUT [%0d] IS Wrong", i);
                    end
            end
    end
endtask

// --------------------------- Clock generator ---------------------------------

initial 
    begin
        forever #15.625 CLK_tb = ~ CLK_tb;
    end

// --------------------------- Instantation --------------------------------------

FCS_TOP #( .GEN_WIDTH ( GEN_WIDTH_tb ), .Rem_WIDTH ( Rem_WIDTH_tb ), .Max_IN_WIDTH ( Max_IN_WIDTH_tb ), .Min_IN_WIDTH ( Min_IN_WIDTH_tb )  ) FCS_TOP_I0 (

    .CLK ( CLK_tb ),
    .RST ( RST_tb ),
    .Valid_Data ( Valid_Data_tb ),
    .Data_Size ( Data_Size_tb ),
    .Input_Data ( Input_Data_tb ),
    .OUT ( OUT_tb ),
    .Done ( Done_tb ),
    .Valid_OUT ( Valid_OUT_tb ),
    .Busy ( Busy_tb )
);

endmodule