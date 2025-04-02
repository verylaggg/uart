/******************************************************************************
* |----------------------------------------------------------------------------|
* |                      Copyright (C) 2024-2025 VeryLag.                      |
* |                                                                            |
* | THIS SOURCE CODE IS FOR PERSONAL DEVELOPEMENT; OPEN FOR ALL USES BY ANYONE.|
* |                                                                            |
* |   Feel free to modify and use this code, but attribution is appreciated.   |
* |                                                                            |
* |----------------------------------------------------------------------------|
*
* Author : VeryLag (verylag0401@gmail.com)
* 
* Creat : 2025/04/02
* 
* Description : testbench
* 
******************************************************************************/
`timescale 1ns/1ns
module tb();

    reg testport = 0;
    wire rstn, clk, clk_20m , clk_50m , clk_100m;

    wire        txd, rxd;
    wire [7:0]  rx_dfifo;
    wire [7:0]  tx_dfifo = 'h5a;

    clk_rst_model # (
        .period     (100        ) 
    ) clk_rst_m ( 
        .clk        (clk        ), 
        .clk_20m    (clk_20m    ), 
        .clk_50m    (clk_50m    ), 
        .clk_100m   (clk_100m   ), 
        .rstn       (rstn       )
    );

    uart_top uart_top_x (
        .clk        (clk        ),
        .rstn       (rstn       ),
        .rx_dfifo   (rx_dfifo   ),
        .tx_dfifo   (tx_dfifo   ),
        .rxd        (txd        ), // loopback
        .txd        (txd        )
    );

    initial begin
        @ (posedge rstn) $display ("rstn end");
        testport = 1;
        $display("sim start");

        wait (rx_dfifo == tx_dfifo);
        #(150*1000*8);
        testport = 0;
        $display("sim end");
        $finish;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
endmodule

