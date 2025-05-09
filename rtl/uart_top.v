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
* Description : uart top module
*    2-wire uart interface w/ txd, rxd
* 
******************************************************************************/
/*
TODO: more baudrate option (19200, 115200...)
*/

module uart_top #(
    parameter PARITY_EN = 'h0
)(
    input  clk,
    input  rstn,
    output [7:0] rx_dfifo,
    input  [7:0] tx_dfifo,
    input  rxd,
    output txd
);
    wire        br_stb;
    wire [7:0]  din = 8'h5a;

    uart_tx # (
        .PARITY_EN(PARITY_EN)
    ) uart_tx_x (
        .clk    (clk        ),
        .rstn   (rstn       ),
        .br_stb (tx_br_stb  ),
        .din    (tx_dfifo   ),
        .txd    (txd        )
    );

    uart_rx # (
        .PARITY_EN(PARITY_EN)
    ) uart_rx_x (
        .clk    (clk        ),
        .rstn   (rstn       ),
        .br_en  (rx_br_en   ),
        .br_stb (rx_br_stb  ),
        .rxd    (rxd        ),
        .dout   (rx_dfifo   )
    );

    baudrate_gen baudrate_gen_x (
        .clk        (clk        ),
        .rstn       (rstn       ),
        .rx_br_en   (rx_br_en   ),
        .rx_br_stb  (rx_br_stb  ),
        .tx_br_stb  (tx_br_stb  )
    );

endmodule