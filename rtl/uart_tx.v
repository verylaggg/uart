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
* Description : uart tx module
* 
******************************************************************************/

module uart_tx # (
    parameter PARITY_EN = 'h0
)(
    input           clk,
    input           rstn,
    input           tx_en,
    input           tx_br_stb,
    input  [7:0]    din,
    output          tx_br_en,
    output          tx_busy,
    output reg      txd
);
    localparam  IDLE    = 0,
                START   = 1,
                DATA    = 2,
                STOP    = 3,
                PARITY  = 4;

    reg [2:0]   tx_fsm, tx_fsm_n;
    reg [7:0]   txd_cnt, txd_cnt_n;
    reg         txd_n;
    reg         tx_br_en_n, tx_br_en;

    wire        txd_end = txd_cnt == 'h7;
    wire        tx_busy = tx_fsm != IDLE;

    always @ (*) begin
        tx_fsm_n = tx_fsm;
        txd_cnt_n = txd_cnt;

        case (tx_fsm)
        IDLE: begin
            txd_n = 'h1;
            if (tx_br_en)
                tx_fsm_n = START;
        end
        START: begin
            txd_n = 'h0;
            tx_fsm_n = DATA;
        end
        DATA:begin
            txd_n = din[txd_cnt];
            txd_cnt_n = txd_end ? 'h0 : txd_cnt + 'h1;
            tx_fsm_n = txd_end ? (PARITY_EN ? PARITY : STOP) : DATA;
        end
        STOP:begin
            txd_n = 'h1;
            tx_fsm_n = IDLE;
        end
        PARITY:begin
            txd_n = ^din; // even partiy
            tx_fsm_n = STOP;
        end
        endcase
    end

    always @ (posedge clk or negedge rstn) begin
        if (!rstn || tx_fsm == STOP && tx_br_stb)
            tx_br_en <= 'h0;
        else if (tx_en)
            tx_br_en <= 'h1;
        else
            tx_br_en <= tx_br_en;
    end

    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            tx_fsm  <= IDLE;
            txd     <= 'h1;
            txd_cnt <= 'h0;
        end else begin
            txd     <= txd_n;
            if (tx_br_stb) begin
                tx_fsm <= tx_fsm_n;
                txd_cnt <= txd_cnt_n;
            end
        end
    end

endmodule