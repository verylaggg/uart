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

module uart_rx (
    input  clk,
    input  rstn,
    input  br_stb,
    input  rxd,
    output reg br_en,
    output reg [7:0] dout
);
    localparam  IDLE    = 0,
                START   = 1,
                DATA    = 2,
                STOP    = 3;

    reg [1:0]   rx_fsm, rx_fsm_n;
    reg [7:0]   rxd_cnt, rxd_cnt_n, dout_n;
    reg         br_en_d1;

    wire br_en_rp = br_en && !br_en_d1;
    wire rxd_end = rxd_cnt == 'h7;

    always @ (*) begin
        rx_fsm_n = rx_fsm;
        rxd_cnt_n = rxd_cnt;
        br_en = 'h0;
        dout_n = 'h0;

        case (rx_fsm)
        IDLE: begin
            if (!rxd) begin
                br_en = 'h1;
                rx_fsm_n = START;
            end
        end
        START: begin
            br_en = 'h1;
            rx_fsm_n = DATA;
        end
        DATA: begin
            br_en = 'h1;
            rxd_cnt_n = rxd_end ? 'h0 : rxd_cnt + 'h1;
            rx_fsm_n = rxd_end ? STOP : DATA;
            dout_n = {rxd, dout[7:1]};
        end
        STOP: begin
            br_en = 'h1;
            rx_fsm_n = IDLE;
        end
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rx_fsm   <= IDLE;
            rxd_cnt  <= 'h0;
            br_en_d1 <= 'h0;
            dout     <= 'h0;
        end else begin
            br_en_d1 <= br_en;
            if (br_stb || br_en_rp) begin
                dout     <= dout_n;
                rx_fsm  <= rx_fsm_n;
                rxd_cnt <= rxd_cnt_n;
            end
        end
    end

endmodule