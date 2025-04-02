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

module baudrate_gen (
    input  clk,
    input  rstn,
    input  rx_br_en,
    output rx_br_stb,
    output tx_br_stb
);
// 1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200 bps
//   /8   /4    /2    *1    *2     *4     *6     *12
// 9600 bps ~= 104167 ns/bits
// 10Mhz = 100ns 
// = 1041.67 ea ~= 1042 ea
    localparam  BR_THR = 1042;

// TX Baudrate Calculation
    reg [10:0]  tx_br_cnt, tx_br_cnt_n;
    reg tx_br_stb;

    always @ (*) begin
        tx_br_cnt_n = tx_br_cnt + 1;
        tx_br_stb = 1'b0;
        
        if (tx_br_cnt == BR_THR) begin
            tx_br_cnt_n = 'h0;
            tx_br_stb = 1'b1;
        end
    end

    always @ (posedge clk or negedge rstn) begin
        if (!rstn)
            tx_br_cnt <= 'h0;
        else
            tx_br_cnt <= tx_br_cnt_n;
    end

// RX Baudrate Calculation
    reg [10:0]   rx_br_cnt,  rx_br_cnt_n;
    reg  rx_br_stb;

    always @ (*) begin
         rx_br_cnt_n =  rx_br_cnt + 1;
         rx_br_stb = 1'b0;
        
        if ( rx_br_cnt == BR_THR) begin
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