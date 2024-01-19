// Design code 
module counter (
input clk, rst, up, load,
  input [15:0] loadin,
  output reg [15:0] y
);
 
always@(posedge clk)
begin
if(rst == 1'b1)
y <= 16'h0000;
else if (load == 1'b1)
y <= loadin;
else begin
if(up == 1'b1)
 y <= y + 1;
 else
 y <= y - 1;
 end
end
endmodule

