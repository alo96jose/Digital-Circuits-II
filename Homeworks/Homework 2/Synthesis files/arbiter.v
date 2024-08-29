module arbiter (
clock, 
reset, 
req_0,
req_1, 
gnt_0,
gnt_1
);

input clock, reset, req_0, req_1;
output gnt_0, gnt_1;

reg gnt_0, gnt_1;
wire clock, reset, req_0, req_1;

always @(posedge clock)
if (reset) begin
 gnt_0 <= 0;
 gnt_1 <= 0;
end else if (req_0) begin
  gnt_0 <= 1;
  gnt_1 <= 0;
end else if (req_1) begin
  gnt_0 <= 0;
  gnt_1 <= 1;
end

endmodule