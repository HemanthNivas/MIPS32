`timescale 1ns / 1ps
module datapath_32(input clk,rst,output [31:0]wb,output [31:0]outer,output [31:0]mwb,output [31:0]addr_out,output [31:0]rs_out,alu_in,data);
wire [31:0]addr_in,sign_out2,sign_o;
wire wr,rd,w,alusrc,alu_zero,mem_reg,branch,hlt;
wire [1:0]signer,reg_dst,jump,label;
wire [4:0]reg_in;
wire [31:0] aluout,data_in,data_out,rd_out,sign_out,hlouts,writeback;
wire [5:0]alu_con;
wire [5:0]ALUop;
wire [31:0]sign_out3,shbr,adbr,brout,sout_jump,jumpout,h_out,wb2;
wire [25:0]sign_jump;
wire [27:0]s_jump;
wire bout,hiw,low;
wire hlsel,hlwr,hldb;
pc program_counter(jumpout,addr_out,clk,rst,hlt);
adder add(addr_out,addr_in);
instr_memory ins(addr_out,data,clk,rst);
mux5 muxy(data[20:16],data[15:11],data[25:21],reg_in,reg_dst);
mux32_3 muxaddr(wb,addr_in,hlouts,mwb,label);
register_bank ragis(w,clk,data[25:21],data[20:16],reg_in,rst,mwb,rs_out,rd_out);
sign_ex ji(data[15:0],sign_out);
shift_2b tbit(sign_out,shbr);
sign_ex_2 su(data[9:5],sign_out2);
sign_exld ldse(data[20:0],sign_out3);
mux32_3 muxsign(sign_out,sign_out2,sign_out3,sign_o,signer);
mux32 muxalu(rd_out,sign_o,alu_in,alusrc);
mux32 muxbr(addr_in,adbr,brout,bout);
adderbr bitlu(addr_in,shbr,adbr);
and a1(bout,branch,alu_zero);
concat cons(s_jump,addr_in[31:28],sout_jump);
shift_jump tjump(data[25:0],s_jump);
hreg hi(wb,h_out,clk,hlt);
mux32 muii(wb,h_out,outer,hlt);
//mux32 jumpy(brout,sout_jump,jumpout,jump);
mux32_3 jump_mux(brout,sout_jump,rs_out,jumpout,jump);
ALU_control aluc(data[5:0],ALUop,alu_con,clk);
ALU alum(rs_out,alu_in,aluout,alu_con,alu_zero,wb2);
data_mem dmem(rst,clk,wr,rd,aluout,rd_out,data_out);
mux32 muxdata(aluout,data_out,wb,mem_reg);
control_path cp(clk,data[31:26],branch,reg_dst,hlt,jump,rd,mem_reg,signer,ALUop,wr,alusrc,w,label,hlsel,hlwr,hldb);
hilo hregs(clk,rst,hlsel,hlwr,hldb,hlouts,wb,wb2);

endmodule
///////////hreg///////
module hreg(input [31:0]ins,output reg [31:0]outs,input clk,hlt);
always@(negedge clk)
if(hlt) outs<=outs;
else begin
outs<=ins;
end
endmodule
////////////////PC///////////////
module pc(input [31:0]addr_in,output reg [31:0]addr_out,input clk,rst,hlt);
always@(posedge clk) 
if(hlt) addr_out<=addr_out;
else begin 
 if(rst) addr_out<=0;
else addr_out<=addr_in;
end
endmodule
//////////////Addr//////////////
module adder(input [31:0]addr,output [31:0]addr_o);
assign addr_o=addr+4;
endmodule
///////////Addr_br//////////////
module adderbr(input [31:0]adrs,input [31:0]br,output [31:0]adout);
assign adout=adrs+br;
endmodule
////////////instruction memory///////////
module instr_memory(input [31:0]a,output [31:0]data,input clk,input rst);
    reg [7:0]mem[255:0];
    wire [7:0]da;
    wire [7:0]da1;
    wire [7:0]da2;
    wire [7:0]da3;
    always@(*) begin
    if(rst==1) begin
    mem[0]=8'b00000000;mem[1]=8'b11100010;mem[2]=8'b00000000;mem[3]=8'b00000001;///R $1 $2 $3 ADD
//    mem[4]=8'b10001100;mem[5]=8'b11100000;mem[6]=8'b00000000;mem[7]=8'b00000000;///R $3 $2 $0 MUL
//    mem[8]=8'b11111100;mem[9]=8'b00000000;mem[32'ha]=8'b00000000;mem[32'hb]=8'b00000000;///R $0 $1 $2 DIV
    mem[32'hc]=8'b11100000;mem[32'hd]=8'b01000111;mem[32'he]=8'b00000000;mem[32'hf]=8'b00000010;///IMM $1 $2 SUBI
    mem[32'h10]=8'b10001100;mem[32'h11]=8'b01100000;mem[32'h12]=8'b00000000;mem[32'h13]=8'b00000000;///R2 $2 $3 NOT
    mem[32'h14]=8'b00000000;mem[32'h15]=8'b01100100;mem[32'h16]=8'b00000000;mem[32'h17]=8'b00000000;///sh $1 1 
    mem[32'h18]=8'b10010000;mem[32'h19]=8'b10000000;mem[32'h1a]=8'b00000000;mem[32'h1b]=8'b00000000; ///LDIMM $3 12 
    mem[32'h1c]=8'b00000000;mem[32'h1d]=8'b10000110;mem[32'h1e]=8'b00000000;mem[32'h1f]=8'b00000001;  ////hlt
    
    end
    end
//     for(i=0;i<4;i++) begin
    assign da=mem[a];
    assign da1=mem[a+1];
    assign da2=mem[a+2];
    assign da3=mem[a+3];
    assign data={da,da1,da2,da3};
endmodule

///////////sign_ex_2//////
module sign_ex_2(input [4:0]ins,output [31:0]outs);
assign outs={26'b0,ins};
endmodule
////////////concat///////////
module concat(input [27:0]ins,input [3:0]d,output [31:0]outs);
assign outs={d,ins};
endmodule
//////////////data memory///////////
module data_mem(input rst,input clk,input wr,input rd,input [31:0]addr,input [31:0]data,output [31:0]data_out);
reg [31:0]mem[255:0];
always@(posedge clk)
begin
if(rst) begin
mem[0]<=0;
mem[1]<=1;
mem[2]<=2;
mem[3]<=3;
mem[4]<=4;
mem[5]<=5;
mem[6]<=6;
mem[7]<=7;
mem[8]<=8;
mem[9]<=9;
end
else begin
if(wr==1) mem[addr]<=data;
//else if(rd==1) data_out<=mem[addr];
end
end
assign data_out=(rd==1)?mem[addr]:0;
endmodule
//////////mux////////////
module mux32(input [31:0]a,input [31:0]b,output [31:0]outs,input sel);
assign outs=sel?b:a;
endmodule
///////////mux32_3///////////
module mux32_3(input [31:0]a,b,c,output reg [31:0]outs,input [1:0]sel);
always@(*)
begin
case(sel)
0:outs=a;
1:outs=b;
2:outs=c;
endcase
end
endmodule
//////////mux5/////////////
module mux5(input [4:0]a,input [4:0]b,input [4:0]c,output reg [4:0]outs,input [1:0]sel);
always@(*)
begin
case(sel)
0:outs=a;
1:outs=b;
2:outs=c;
endcase
end
endmodule
///////////ALU///////////////////
module ALU(input [31:0]a,b,output reg [31:0]outs,input [5:0]sel,output reg aluzero,output reg [31:0]wb2);
always@(*)
begin
case(sel)
6'b000001:begin outs=a+b;aluzero=0; end  //add
6'b000010:begin outs=a-b;aluzero=0; end  //sub
6'b000011:begin outs=a&b;aluzero=0;       end ///and
6'b000100:begin outs=a|b;aluzero=0; end//or
6'b000101:begin outs=a^b;aluzero=0; end//xor
6'b000110:begin outs=~a;aluzero=0; end//not
6'b010000:begin aluzero=(a==b)?1:0; outs=0; end//branch
6'b010001:begin aluzero=(a!=b)?1:0; outs=0; end //branch neq
6'b010010:begin aluzero=(a>b)?1:0; outs=0;end //branch greater than
6'b010011:begin aluzero=(a>=b)?1:0; outs=0; end //branch greaterequal
6'b010100:begin aluzero=(a<b)?1:0; outs=0; end //branch less than
6'b010101:begin aluzero=(a<=b)?1:0; outs=0; end //branch lessequal
6'b000111:begin aluzero=0;outs=outs; end//hlt
6'b001000:begin aluzero=0; outs=a<<b;end//leftshift
6'b001001:begin aluzero=0; outs=a*b;end//mul
6'b001010:begin aluzero=0;outs=a/b;end//div
6'b001011:begin aluzero=0; outs=a>>b; end//right shift
6'b001111:begin aluzero=0; outs=b+0; end //loadIMM  MOV
6'b111000:begin aluzero=0; {outs,wb2}=a*b; end  //mul 64b
6'b111001:begin aluzero=0; outs=a%b; wb2=a/b; end //div 64b
6'b110000:begin aluzero=0; outs=(a<b)?1:0;end   //set less than
6'b011001:begin aluzero=0; outs=b<<16;end  //load upper imm
default:begin outs=0; aluzero=0; end//zerostate
endcase
//if(outs==0) aluzero=1;
//else aluzero=0;
end
endmodule
///////////////ALU CONTROL//////////////////
module ALU_control(input [5:0]func,input [5:0]ALUop,output reg [5:0]outs,input clk);
wire [11:0]alu;
assign alu={ALUop,func};
always@(*)
begin
    casex(alu) 
    12'b000000000001:outs=6'b000001;   ///add
    12'b000000000010:outs=6'b000010;   ///sub
    12'b000000000011:outs=6'b000011;   ///and
    12'b000000000100:outs=6'b000100;   ///or
    12'b000000000101:outs=6'b000101;   ///xor
    12'b000000000110:outs=6'b000110;   ///not
    12'b000000001000:outs=6'b001000;   ///leftshift
    12'b000000001001:outs=6'b001001;   ///mul
    12'b000000001010:outs=6'b001010;   ///div
    12'b000000001011:outs=6'b001011;   ///rightshift
    12'b000001xxxxxx:outs=6'b000001;   //addI
    12'b000010xxxxxx:outs=6'b000010;   ///subI
    12'b000011xxxxxx:outs=6'b000011;   ///andI
    12'b000100xxxxxx:outs=6'b000100;   ///orI
    12'b000111xxxxxx:outs=6'b000111;   ///xorI
    12'b001111xxxxxx:outs=6'b001111;   //loadIMM
    12'b010000xxxxxx:outs=6'b010000;   //branch eq
    12'b010001xxxxxx:outs=6'b010001;   //branch neq
    12'b010010xxxxxx:outs=6'b010010;   //branch greater than
    12'b010011xxxxxx:outs=6'b010011;   //branch greaterequal
    12'b010100xxxxxx:outs=6'b010100;   //branch less than
    12'b010101xxxxxx:outs=6'b010101;   //branch lessequal
    12'b111000000001:outs=6'b111000;   // MUL 64B
    12'b111000000010:outs=6'b111001;   ///DIV 64b
    12'b000000110000:outs=6'b110000;    //setlessthan
    12'b101111xxxxxx:outs=6'b110000;    //setlessthan imm
    12'b011001xxxxxx:outs=6'b011001;    //load upper immediate
//    12'b001100xxxxxx:outs=6'b001100;   //load next address

    endcase
end
endmodule
////////////////sign Extender//////////////
module sign_ex(input [15:0]ex,output[31:0]ou);
assign ou={16'b0000000000000000,ex};
endmodule
//////////////sign extender///////////////
module sign_exld(input [20:0]ins,output [31:0]outs);
assign outs={11'b00000000000,ins};
endmodule
///////////shift_2bit////////////////////
module shift_2b(input [31:0]ins,output [31:0]outs);
assign outs=ins<<2;
endmodule
///////////////////shift_jump///////////
module shift_jump(input [25:0]ins,output [27:0]outs);
assign outs=ins<<2;
endmodule
/////////////hilo registers//////////////////
module hilo(input clk,input rst,input sel,input wr,double,output [31:0]outs,input [31:0]writeback,wb2);
reg [31:0]hi;
reg [31:0]lo;
always@(posedge clk)
begin
if(rst) begin
hi<=32'h32; lo<=32'h16;
end
else begin
if(double) begin
hi<=writeback;
lo<=wb2;
end
else begin
if(sel)begin
if(wr) hi<=writeback;
else hi<=hi;
end 
else begin
if(wr) lo<=writeback;
else lo<=lo;
end
end
end
end
assign outs=sel?hi:lo;
endmodule
///////////////register bank/////////////////
module register_bank(input w,input clk,input [4:0]rs1,input [4:0]rt,input [4:0]rd,input rst,input [31:0]wb,output [31:0]rsout,output [31:0]rdout);
reg [31:0]mem[31:0];
reg [31:0]hi;
reg [31:0]lo;
always@(posedge clk)
begin
if(rst)begin
mem[0]<=1;
mem[1]<=2;
mem[2]<=32'hffff_ffff;
mem[3]<=4;
mem[4]<=5;
mem[5]<=6;
mem[6]<=7;
mem[7]<=32'h22222222;
//hi<=0;
//lo<=0;
end
else begin
if(w==1) begin
mem[rd]<=wb;
end
//else if(hiw) begin
//hi<=wb;
//end
//else if(low) lo<=wb;
end
end
assign rsout=mem[rs1];
assign rdout=mem[rt];
endmodule
///////////////COntroll Path///////////////
module control_path(input clk,input [5:0]opcode,output reg branch,output reg [1:0]regdest,output reg hlt,output reg [1:0]jump,output reg memrd,memreg,output reg [1:0]signer,output reg [5:0]ALUop,output reg memwr,ALUsrc,regwrite,output reg [1:0]label,output reg hlsel,hlwr,hldb);
always@(*) begin
case(opcode)
6'b000000:begin   ///Rtype
regdest<=1;
signer<=0;
jump<=0;
branch<=0;
ALUsrc<=0;
ALUop<=6'b000000;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;
label<=0;
//hldb<=1;
//hiw<=0;
//low<=0;
end
6'b111000:begin   ///multiplication 64b and division
regdest<=1;
signer<=0;
jump<=0;
branch<=0;
ALUsrc<=0;
ALUop<=6'b111000;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;
label<=0;
//hlwr<=1;
hldb<=1;
end
6'b000001:begin   ///rtype 2
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=0;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;
label<=0;
//hiw<=0;
//low<=0;
end
6'b000010:begin   ///shiftbit
regdest<=1;
branch<=0;
jump<=0;
signer<=1;
ALUsrc<=1;
ALUop<=0;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;
label<=0;
//hiw<=0;
//low<=0;
end
6'b000011:begin    ///immediate ADD
regdest<=0;
branch<=0;
signer<=0;
jump<=0;
ALUsrc<=1;
ALUop<=1;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b000100:begin   ///immediate SUB
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=1;
ALUop<=2;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b000101:begin   ///immediate AND
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=1;
ALUop<=3;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b000110: begin   ///immediate or
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=1;
ALUop<=4;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b000111: begin  //immediate xor
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=1;
ALUop<=5;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b101111:begin  ///set less than immediate
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=1;
ALUop<=6'b101111;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;
label<=0;
end
6'b001000:begin   ///Load word lw
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=1;
ALUop<=1;
memreg<=1;
regwrite<=1;
memrd<=1;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b001001:begin   ///store word
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=1;
ALUop<=1;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=1;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b001010:begin   ///load immediate 
regdest<=2;
branch<=0;
jump<=0;
signer<=2;
ALUsrc<=1;
ALUop<=6'b001111;  ///6'h0f
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b011001: begin  //load upper imm
regdest<=2;
branch<=0;
jump<=0;
signer<=2;
ALUsrc<=1;
ALUop<=6'b011001;  ///6'h0f
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
end
6'b001100: begin  //load next address
regdest<=2;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b001100;  ///6'h0f
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=1;
end
6'b001011:begin  ///MOV
regdest<=2;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b001111;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b010000:begin   ///branch eq
regdest<=0;
branch<=1;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b010000;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b010001:begin   ///branch neq
regdest<=0;
branch<=1;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b010001;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b010010: begin   //branch greaterthan
regdest<=0;
branch<=1;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b010010;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b010011:begin   //branch greaterequal
regdest<=0;
branch<=1;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b010011;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b010100: begin  //branch less than
regdest<=0;
branch<=1;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b010100;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b010101:begin  //branch lessequal
regdest<=0;
branch<=1;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b010101;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b100000:begin   ///jump
regdest<=0;
branch<=0;
jump<=1;
signer<=0;
ALUsrc<=0;
ALUop<=0;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hiw<=0;
//low<=0;
end
6'b100001:begin    ///jump reg
regdest<=0;
branch<=0;
jump<=2;
signer<=0;
ALUsrc<=0;
ALUop<=0;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
end
6'b100011:begin  ///movfrom hi
regdest<=2;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b100011;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=2;
hlsel<=1;  hlwr<=0;
hldb<=0;
//hiw<=0;
//low<=0;
end
6'b100100:begin   ///movfrom lo
regdest<=2;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b100011;
memreg<=0;
regwrite<=1;
memrd<=0;
memwr<=0;
hlt<=0;label<=2;
hlsel<=0;  hlwr<=0;
hldb<=0;
end
6'b111111: begin   ///hlt
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=0;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=1;label<=0;
//hiw<=0;
//low<=0;
end
default: begin
regdest<=0;
branch<=0;
jump<=0;
signer<=0;
ALUsrc<=0;
ALUop<=6'b0;
memreg<=0;
regwrite<=0;
memrd<=0;
memwr<=0;
hlt<=0;label<=0;
//hlsel=x;
//hlwr<=x
//hiw<=0;
//low<=0;
end
endcase
end
endmodule