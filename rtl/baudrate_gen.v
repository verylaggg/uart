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
* Description : Baudrate generator
* 
******************************************************************************/

module baudrate_gen # (
    parameter   BAUDRATE = 9600
)(
    input       clk,
    input       rstn,
    input       rx_br_en,
    input       tx_br_en,
    output reg  rx_br_stb,
    output reg  tx_br_stb
);
// ex: 9600 bps ~= 104167 ns/bits
// 10Mhz = 100ns
// = 1041.67 cyc ~= 1042 cyc
    localparam  BR_THR_SEL =
        BAUDRATE == 1200  ? BR_THR_1200  :
        BAUDRATE == 2400  ? BR_THR_2400  :
        BAUDRATE == 4800  ? BR_THR_4800  :
        BAUDRATE == 9600  ? BR_THR_9600  :
        BAUDRATE == 19200 ? BR_THR_19200 :
        BAUDRATE == 38400 ? BR_THR_38400 :
        BAUDRATE == 57600 ? BR_THR_57600 : BR_THR_115200 ;

    localparam  BR_THR_1200    = 'd8333     ,
                BR_THR_2400    = 'd4167     ,
                BR_THR_4800    = 'd2083     ,
                BR_THR_9600    = 'd1042     ,
                BR_THR_19200   = 'd521      ,
                BR_THR_38400   = 'd260      ,
                BR_THR_57600   = 'd174      ,
                BR_THR_115200  = 'd87       ;

// TX Baudrate Calculation
    reg [10:0]  tx_br_cnt, tx_br_cnt_n;

    always @ (*) begin
        tx_br_cnt_n = tx_br_cnt + 1;
        tx_br_stb = 1'b0;

        if (tx_br_cnt == BR_THR_SEL) begin
            tx_br_cnt_n = 'h0;
            tx_br_stb = 1'b1;
        end
    end

    always @ (posedge clk or negedge rstn) begin
        if (!rstn || !tx_br_en)
            tx_br_cnt <= 'h0;
        else
            tx_br_cnt <= tx_br_cnt_n;
    end

// RX Baudrate Calculation
    reg [10:0]   rx_br_cnt,  rx_br_cnt_n;

    always @ (*) begin
         rx_br_cnt_n =  rx_br_cnt + 1;
         rx_br_stb = 1'b0;

        if (rx_br_cnt == BR_THR_SEL) begin
             rx_br_cnt_n = 'h0;
             rx_br_stb = 1'b1;
        end
    end

    always @ (posedge clk or negedge rstn) begin
        if (!rstn || !rx_br_en)
             rx_br_cnt <= 'h0;
        else
             rx_br_cnt <=  rx_br_cnt_n;
    end

endmodule
