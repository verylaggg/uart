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
* Description : uart rx module
* 
******************************************************************************/

module uart_rx # (
    parameter PARITY_EN = 'h0
)(
    input               clk,
    input               rstn,
    input               rx_br_stb,
    input               rxd,
    output reg          rx_br_en,
    output              parity_err,
    output              rx_busy,
    output reg [7:0]    dout
);
    localparam  IDLE    = 0,
                START   = 1,
                DATA    = 2,
                STOP    = 3,
                PARITY  = 4;

    reg [2:0]   rx_fsm, rx_fsm_n;
    reg [7:0]   rxd_cnt, rxd_cnt_n, dout_n;
    reg         rx_br_en_d1, parity_err, parity_err_n;

    wire br_en_rp = rx_br_en && !rx_br_en_d1;
    wire rxd_end = rxd_cnt == 'h7;
    wire rx_busy = rx_fsm != IDLE;

    always @ (*) begin
        rx_fsm_n = rx_fsm;
        rxd_cnt_n = rxd_cnt;
        rx_br_en = 'h0;
        dout_n = dout;
        parity_err_n = parity_err;

        case (rx_fsm)
        IDLE: begin
            if (!rxd) begin
                rx_br_en = 'h1;
                rx_fsm_n = START;
                dout_n = 'h0;
            end
        end
        START: begin
            rx_br_en = 'h1;
            rx_fsm_n = DATA;
            parity_err_n = 'h0;
        end
        DATA: begin
            rx_br_en = 'h1;
            rxd_cnt_n = rxd_end ? 'h0 : rxd_cnt + 'h1;
            rx_fsm_n = rxd_end ? (PARITY_EN ? PARITY : STOP) : DATA;
            dout_n = {rxd, dout[7:1]};
        end
        STOP: begin
            rx_br_en = 'h1;
            rx_fsm_n = IDLE;
        end
        PARITY: begin
            rx_br_en = 'h1;
            parity_err_n = ^dout ^ rxd;
            rx_fsm_n = STOP;
        end
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rx_fsm   <= IDLE;
            rxd_cnt  <= 'h0;
            rx_br_en_d1 <= 'h0;
            dout     <= 'h0;
            parity_err <= 'h0;
        end else begin
            rx_br_en_d1 <= rx_br_en;
            parity_err <= parity_err_n;
            if (rx_br_stb || br_en_rp) begin
                dout     <= dout_n;
                rx_fsm  <= rx_fsm_n;
                rxd_cnt <= rxd_cnt_n;
            end
        end
    end

endmodule