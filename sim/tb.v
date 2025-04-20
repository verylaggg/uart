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
`define RX tb.uart_top_x.uart_rx_x
module tb();

    reg testport = 0;
    wire rstn, clk, clk_20m , clk_50m , clk_100m;

    wire        txd, rxd;
    wire [7:0]  rx_dfifo;
    wire [7:0]  tx_dfifo = 'h5b;

    clk_rst_model # (
        .period     (100        ) 
    ) clk_rst_m ( 
        .clk        (clk        ), 
        .clk_20m    (clk_20m    ), 
        .clk_50m    (clk_50m    ), 
        .clk_100m   (clk_100m   ), 
        .rstn       (rstn       )
    );

    uart_top # (
        .PARITY_EN  ('h1        )
    ) uart_top_x (
        .clk        (clk        ),
        .rstn       (rstn       ),
        .rx_dfifo   (rx_dfifo   ),
        .tx_dfifo   (tx_dfifo   ),
        .rxd        (txd        ), // loopback test
        .txd        (txd        )
    );

    always @ (*) begin
        release `RX.rxd;
        if (`RX.PARITY_EN && `RX.rxd_cnt == 'h7)
            force `RX.rxd = 'h1;
        if (`RX.parity_err)
            $display ("UART_RX @ %0t ns, found parity error=%0h", $realtime, `RX.parity_err);
    end

    always @ (*) begin
        if (`RX.rx_fsm == 'h3) begin
            if (rx_dfifo == tx_dfifo)
                $display ("UART_RX @ %0t ns, rx_dfifo=tx_dfifo=%0h", $realtime, rx_dfifo);
            else
                $display ("UART_RX @ %0t ns, rx_dfifo=%0h != tx_dfifo=%0h", $realtime, rx_dfifo, tx_dfifo);
        end
    end

    initial begin
        @ (posedge rstn) $display ("rstn end");
        testport = 1;
        $display("sim start");

        wait (`RX.rx_fsm == 'h3);
        #(200*1000*8);
        testport = 0;
        $display("sim end");
        $finish;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end
endmodule

