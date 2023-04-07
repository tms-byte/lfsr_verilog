module ha(a,b,s,c);
    input a,b;
    output s,c;

    assign s = a ^ c;
    assign c = a & b;
endmodule

module ha_tb;
    reg a,b;
    wire s,c;

    ha ha_i(a,b,s,c);

    initial begin
        $dumpfile("ha.vcd");
        $dumpvars(0,s,c,a,b);
        $monitor("%t: a = %b, b = %b, s = %b, c= %b",$time,a,b,s,c);
    end

    initial begin
        a = 1'b0; b=1'b1;
        #10 a=1'b1;
        #10 b=1'b0;
        #10 a =1'b0;
        #10 $finish;
    end
endmodule