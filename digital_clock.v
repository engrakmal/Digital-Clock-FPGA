module digital_clock(clock, reset, display);
input clock, reset;
output [41:0] display;
// DISPLAY
//        	H	  H	  M	 M	 S    S
//	[41:35][34:28]	[27:21][20:14]	[13:7][6:0]

reg [7:0] bcd_hr, bcd_min, bcd_sec;
reg [5:0] temp_count_min, temp_count_sec;
reg [4:0] temp_count_hr;
reg [41:0] temp_display;

reg [26:0] i;
		
always @(posedge clock)
	begin
		if(~reset)
			begin
				temp_count_sec = 0;
				temp_count_min = 0;
				temp_count_hr = 0;
				i = 0;
			end
		else
			if(i < 50000000)
				i = i + 1;
			else
			begin
			i = 0;
				if(temp_count_sec < 59)
					temp_count_sec = temp_count_sec + 1;
				else
					begin
						temp_count_sec = 0;
							if (temp_count_min < 59)
								temp_count_min = temp_count_min + 1;
							else
								begin
									temp_count_min = 0;
										if (temp_count_hr < 23)
											temp_count_hr = temp_count_hr + 1;
										else
											begin
												temp_count_hr = 0;
											end
								end
					end
			end
				// sec
				binary_to_bcd_min_sec(bcd_sec, temp_count_sec);
				bcd_to_7segment(temp_display[6:0], bcd_sec[3:0]);
				bcd_to_7segment(temp_display[13:7], bcd_sec[7:4]);
				// min
				binary_to_bcd_min_sec(bcd_min, temp_count_min);
				bcd_to_7segment(temp_display[20:14], bcd_min[3:0]);
				bcd_to_7segment(temp_display[27:21], bcd_min[7:4]);
				// hr
				binary_to_bcd_hr(bcd_hr, temp_count_hr);
				bcd_to_7segment(temp_display[34:28], bcd_hr[3:0]);
				bcd_to_7segment(temp_display[41:35], bcd_hr[7:4]);
		
	end

assign display = temp_display;
	
///////////////////////////////
// task binary_to_bcd_min_sec
///////////////////////////////
task binary_to_bcd_min_sec;
output [7:0] out_bcd;
input [5:0] in_binary;

reg [7:0] temp_out_bcd;
reg [3:0] i;   

// Double Dabble algorithm
begin
temp_out_bcd = 0; //initialize bcd to zero.
for (i = 0; i < 6; i = i+1) //run for 6 iterations	
	begin
		temp_out_bcd = {temp_out_bcd[6:0],in_binary[5-i]}; //concatenation
		//if a hex digit of 'bcd' is more than 4, add 3 to it.  
		if(i < 5 && temp_out_bcd[3:0] > 4) 
			temp_out_bcd[3:0] = temp_out_bcd[3:0] + 3;
		if(i < 5 && temp_out_bcd[7:4] > 4)
			temp_out_bcd[7:4] = temp_out_bcd[7:4] + 3;
	end
	out_bcd = temp_out_bcd;
end  

endtask

//////////////////////////
// task binary_to_bcd_hr
//////////////////////////
task binary_to_bcd_hr;
output [7:0] out_bcd;
input [4:0] in_binary;

reg [7:0] temp_out_bcd;
reg [3:0] i;   

// Double Dabble algorithm
begin
temp_out_bcd = 0; //initialize bcd to zero.
for (i = 0; i < 5; i = i+1) //run for 5 iterations	
	begin
		temp_out_bcd = {temp_out_bcd[6:0],in_binary[4-i]}; //concatenation
		//if a hex digit of 'bcd' is more than 4, add 3 to it.  
		if(i < 4 && temp_out_bcd[3:0] > 4) 
			temp_out_bcd[3:0] = temp_out_bcd[3:0] + 3;
		if(i < 4 && temp_out_bcd[7:4] > 4)
			temp_out_bcd[7:4] = temp_out_bcd[7:4] + 3;
	end
	out_bcd = temp_out_bcd;
end 

endtask

////////////////////////
// task bcd_to_7segment
////////////////////////
task bcd_to_7segment;
output [6:0] hex_code;
input [3:0] bcd_time;

//reg [6:0] hex_code;
   
  // Purpose: Creates a case statement for all possible input binary numbers.
  // Drives hex_code appropriately for each input combination.
begin
	hex_code = 7'b0000000;
	case (bcd_time)
		4'b0000 : hex_code = 7'b1000000;
		4'b0001 : hex_code = 7'b1111001;
		4'b0010 : hex_code = 7'b0100100;
		4'b0011 : hex_code = 7'b0110000;
		4'b0100 : hex_code = 7'b0011001;          
		4'b0101 : hex_code = 7'b0010010;
		4'b0110 : hex_code = 7'b0000011;
		4'b0111 : hex_code = 7'b1111000;
		4'b1000 : hex_code = 7'b0000000;
		4'b1001 : hex_code = 7'b0011000;
		default : hex_code = 7'b1000000;
	endcase
end

endtask

endmodule