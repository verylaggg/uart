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

module uart_tx (
    input  clk,
    input  rstn,
    input  br_stb,
    input  [7:0] din,
    output reg txd
);
    localparam  IDLE    = 0,
                START   = 1,
                DATA    = 2,
                STOP    = 3;

    reg [1:0]   tx_fsm, tx_fsm_n;
    reg [7:0]   txd_cnt, txd_cnt_n;
    reg         txd_n;

    wire        txd_end = txd_cnt == 'h7;

    always @ (*) begin
        tx_fsm_n = tx_fsm;
        txd_cnt_n = txd_cnt;
        
        case (tx_fsm)
        IDLE: begin
            txd_n = 'h1;
            tx_fsm_n = START;
        end
        START: begin
            txd_n = 'h0;
            tx_fsm_n = DATA;
        end
        DATA:begin
            txd_n = din[txd_cnt];
            txd_cnt_n = (txd_end) ? 'h0 : txd_cnt + 'h1;
            tx_fsm_n = (txd_end) ? STOP : DATA;
        end
        STOP:begin
            txd_n = 'h1;
            tx_fsm_n = IDLE;
        end
        endcase
    end

    always @ (posedge clk or negedge rstn) begin
        if (!rstn) begin
            tx_fsm  <= IDLE;
            txd     <= 'h1;
            txd_cnt <= 'h0;
        end else begin
            txd     <= txd_n;
            if (br_stb) begin
                tx_fsm <= tx_fsm_n;
                txd_cnt <= txd_cnt_n;
            end
        end
    end

endmodule