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

    localparam PARITY_ERR_TEST = 'h0;
    localparam PARITY_EN = 'h0;
    localparam BAUDRATE = 9600;

    integer     testport = 'h0;
    reg  [7:0]  tx_dfifo = 'h5b;
    reg         tx_en = 'h0;

    wire        rstn, clk, clk_20m , clk_50m , clk_100m;
    wire        txd, rxd, rx_busy, tx_busy;
    wire [7:0]  rx_dfifo;

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
        .PARITY_EN     (PARITY_EN    ),
        .BAUDRATE      (BAUDRATE     )
    ) uart_top_x (
        .clk           (clk          ),
        .rstn          (rstn         ),
        .tx_en         (tx_en        ),
        .rx_dfifo      (rx_dfifo     ),
        .tx_dfifo      (tx_dfifo     ),
        .rx_busy       (rx_busy      ),
        .tx_busy       (tx_busy      ),
        .rx_parity_err (rx_parity_err),
        .rxd           (txd          ), // loopback test
        .txd           (txd          )
    );

    always @ (*) begin
        if (PARITY_ERR_TEST && PARITY_EN) begin
            release `RX.rxd;
            if (`RX.rxd_cnt == 'h7)
                force `RX.rxd = 'h1;
        end
        if (rx_parity_err)
            $display ("UART_RX @ %0t ns, found parity error=%0h", $realtime, rx_parity_err);
    end

    initial begin
        @ (posedge rstn) $display ("rstn end");
        testport = 'h1;
        $display("sim start");

        testport = 'h2;
        #333;
        ENA_TX('h5c);

        testport = 'h3;
        #333;
        ENA_TX('hde);

        testport = 'h88;
        #333
        $display("sim end");
        $finish;
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end

    task ENA_TX;
        input [7:0] din;
    begin
        tx_en = 'h1;
        tx_dfifo = din;
        wait (rx_busy);
        tx_en = 'h0;
        wait (!rx_busy);
        if (rx_dfifo == tx_dfifo)
            $display ("UART_RX @ %0t ns, rx_dfifo = tx_dfifo = %0h", $realtime, rx_dfifo);
        else
            $display ("UART_RX @ %0t ns, rx_dfifo = %0h != tx_dfifo = %0h", $realtime, rx_dfifo, tx_dfifo);
    end
    endtask
endmodule

