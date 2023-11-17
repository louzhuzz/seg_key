module key_debounce
(
	input clk,  //Frequency cannot be too high
	
	input btn0,reset,
	output  o_key,
	output reg [6:0] seg,
	output reg [7:0] cat
);
reg r_key_buf1, r_key_buf2,select;

wire r_key;
reg pause;
reg [6:0] delay_s;
reg [3:0] bin;
reg [3:0] cnt1,cnt2;
initial select <= 0;
initial pause <= 0;
initial delay_s <= 7'b0000000;
assign o_key = r_key;

always@(negedge clk)
begin
	r_key_buf2 <= r_key_buf1;
	r_key_buf1 <= btn0;
end

assign r_key = clk & r_key_buf1 & (~r_key_buf2); //debounce

always@(posedge r_key)
begin
	if(r_key)
		begin
			pause = ~pause;
		end
end


always@(posedge clk ,posedge reset)
begin
	if(reset == 1'b1)
	begin
		cnt1 <= 0; cnt2 <= 0;delay_s <= 0;
	end
	else if(pause == 1)
		begin
			cnt1 <= cnt1;cnt2 <= cnt2;delay_s <= delay_s;
		end
	else
	begin
        delay_s <= delay_s + 1'b1;
        if(delay_s == 7'b1100100)
        begin
            if(cnt1 == 4'b1001) // check if 19
            begin
                cnt1 <= 0;
                if (cnt2 == 0)
                    cnt2 <= cnt2 + 1;
                else
                    cnt2 <= 0;
            end
            else
            begin
                cnt1 <= cnt1 + 1;
            end
            delay_s <= 0;
        end
	end
end

//assign	cnt1 = cnt%10;
//assign	cnt2 = cnt/10;

always@(posedge clk, posedge reset)
begin
	if(reset == 1'b1)
	begin
		cat <= 8'b1111_1111;
		bin <= 0;
	end
	else
	begin
		select <=~select;
		if (select == 0)
		begin
			cat <= 8'b1111_1110;
			bin <= cnt1;
		end
		else
		begin
			cat <= 8'b1111_1101;
			bin <= cnt2;
		end
	end
end

always@(bin)
begin
	case(bin)
		4'd0:
			seg = 7'b1111110;
		4'd1:
			seg = 7'b0110000;
		4'd2:
			seg = 7'b1101101;
		4'd3:
			seg = 7'b1111001;
		4'd4:
			seg = 7'b0110011;
		4'd5:
			seg = 7'b1011011;
		4'd6:
			seg = 7'b1011111;
		4'd7:
			seg = 7'b1110000;
		4'd8:
			seg = 7'b1111111;
		4'd9:
			seg = 7'b1111011;
		default:
			seg = 7'b0000000;
	endcase
end

endmodule