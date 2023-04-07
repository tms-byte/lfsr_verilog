module LFSR #(parameter N = 32)(clk,seed,rst_n,out);
    input rst_n,clk;
    input [N-1:0] seed;
    output [N-1:0] out;

    reg [N-1:0] r;

    // tap seaqunce is [32,3,2,0]

    always @(posedge clk) begin
        if (rst_n) begin
            r <= seed;
        end else begin
            //r <= (r<<1) | (r[31]^r[2]^r[1]^1'b1);
            r <= (r<<1) | (r[7]^r[5]^r[4]^r[3]^1'b1);
        end
    end
    assign out = r;
endmodule

module comparator #(parameter N=8) (input [N-1:0] t, input [N-1:0] rnd, output ber);
    wire [N:0] tmp;
    wire [N:0] rnd_c;
    wire [N:0] rnd_ext;
    wire [N:0] t_ext;

    // 符号拡張 必ず0
    assign rnd_ext={1'b0,rnd};
    assign rnd_c = ~rnd_ext+1'b1;
    // 符号拡張　必ず0
    assign t_ext = {1'b0,t};
    assign tmp = t_ext + rnd_c;
    // 最上位ビットが比較の情報
    assign ber = ~tmp[N];
endmodule

`timescale 1ps/1ps

module LFSR_tb;
    parameter M=8;
    reg clk;
    reg [M-1:0] seed;
    reg rst_n;
    wire [M-1:0] out;

    reg [M-1:0] target;
    wire ber_out;

    LFSR #(.N(M)) LFSR(clk,seed,rst_n,out);
    comparator #(.N(M)) comparator(target,out,ber_out);

    parameter P_CLOCK_FREQ = 1000.0 / 50.0;//50MHz

    integer fd;

    initial begin
        $dumpfile("lfsr.vcd");
        //dumpvars にtopmodule のインスタンス名を載せないと波形の中身は見れない。
        $dumpvars(0,LFSR,comparator);
        $monitor("%t: clk = %b, seed = %b, rst_n = %b, out= %b",$time,clk,seed,rst_n,out);
        fd = $fopen("output_data.txt","w");
        $display(fd,"%b",clk);

        clk <= 1'b0;
        rst_n <=1;
        seed <=1;
        target <= 85;
        #2
        rst_n<=0;
        #509
        $finish;
        $fclose(fd);
    end
    //always #(P_CLOCK_FREQ/2) begin
    always #1 begin
        clk <= ~clk;
        $fwrite(fd,"%b\n",ber_out);
    end
endmodule