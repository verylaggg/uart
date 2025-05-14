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

module uart_top #(
    parameter PARITY_EN = 'h0,
    parameter BAUDRATE = 9600
)(
    input        clk,
    input        rstn,
    input        tx_en,
    output [7:0] rx_dfifo,
    input  [7:0] tx_dfifo,
    output       rx_busy,
    output       tx_busy,
    output       rx_parity_err,
    input        rxd,
    output       txd
);

    uart_tx # (
        .PARITY_EN      (PARITY_EN      )
    ) uart_tx_x (
        .clk            (clk            ),
        .rstn           (rstn           ),
        .tx_en          (tx_en          ),
        .tx_br_stb      (tx_br_stb      ),
        .tx_br_en       (tx_br_en       ),
        .din            (tx_dfifo       ),
        .tx_busy        (tx_busy        ),
        .txd            (txd            )
    );

    uart_rx # (
        .PARITY_EN      (PARITY_EN      )
    ) uart_rx_x (
        .clk            (clk            ),
        .rstn           (rstn           ),
        .rx_br_en       (rx_br_en       ),
        .rx_br_stb      (rx_br_stb      ),
        .rxd            (rxd            ),
        .rx_busy        (rx_busy        ),
        .parity_err     (rx_parity_err  ),
        .dout           (rx_dfifo       )
    );

    baudrate_gen # (
        .BAUDRATE   (BAUDRATE   )
    ) baudrate_gen_x (
        .clk        (clk        ),
        .rstn       (rstn       ),
        .rx_br_en   (rx_br_en   ),
        .tx_br_en   (tx_br_en   ),
        .rx_br_stb  (rx_br_stb  ),
        .tx_br_stb  (tx_br_stb  )
    );

endmodule