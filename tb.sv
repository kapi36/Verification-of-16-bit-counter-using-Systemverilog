class transaction;
  randc bit [15:0] loadin;
  bit [15:0] y;
endclass
 
class generator;
transaction t;
mailbox mbx;
event done;
integer i;
 
function new(mailbox mbx);
this.mbx = mbx;
endfunction
 
task run();
t = new();
t.randomize();
mbx.put(t);
$display("[GEN]: Data send to driver");
@(done);
endtask
endclass
 
interface counter_intf();
logic clk,rst, up, load;
  logic [15:0] loadin;
  logic [15:0] y;
endinterface
 
class driver;
mailbox mbx;
transaction t;
event done;
 
virtual counter_intf vif;
 
function new(mailbox mbx);
this.mbx = mbx;
endfunction
 
 
task run();
t= new();
forever begin
mbx.get(t);
vif.loadin = t.loadin;
$display("[DRV] : Trigger Interface");
->done; 
@(posedge vif.clk);
end
endtask
 
 
endclass
 
class monitor;
virtual counter_intf vif;
mailbox mbx;
transaction t;
 
function new(mailbox mbx);
this.mbx = mbx;
endfunction
 
task run();
t = new();
forever begin
t.loadin = vif.loadin;
t.y = vif.y;
mbx.put(t);
  $display("[MON] : Data send to Scoreboard %0d",t.y);
@(posedge vif.clk);
end
endtask
endclass   
 
class scoreboard;
mailbox mbx;
transaction t;
 
function new(mailbox mbx);
this.mbx = mbx;
endfunction
 
task run();
t = new();
forever begin
mbx.get(t);
  $display("[SCO]:Data Rcvd %0d", t.y); 
end
endtask
endclass  
 
class environment;
generator gen;
driver drv;
monitor mon;
scoreboard sco;
 
virtual counter_intf vif;
 
mailbox gdmbx;
mailbox msmbx;
 
event gddone;
 
function new(mailbox gdmbx, mailbox msmbx);
this.gdmbx = gdmbx;
this.msmbx = msmbx;
 
gen = new(gdmbx);
drv = new(gdmbx);
 
mon = new(msmbx);
sco = new(msmbx);
endfunction
 
task run();
gen.done = gddone;
drv.done = gddone;
 
drv.vif = vif;
mon.vif = vif;
 
fork 
gen.run();
drv.run();
mon.run();
sco.run();
join_any
 
endtask
 
endclass
 
module tb();
 
environment env;
 
mailbox gdmbx;
mailbox msmbx;
 
counter_intf vif();
 
counter dut ( vif.clk, vif.rst, vif.up, vif.load,  vif.loadin, vif.y );
 
always #5 vif.clk = ~vif.clk;
 
initial begin
vif.clk = 0;
vif.rst = 1;
vif.up = 0;
vif.load = 0;
#20;
vif.load = 1;
#50;
vif.load =0;
#10;
vif.rst = 0;
#100;
vif.up = 1;
#100;
vif.up =0;
end
 
initial begin
gdmbx = new();
msmbx = new();
env = new(gdmbx, msmbx);
env.vif = vif;
env.run();
#500;
$finish;
end
 
  initial begin 
    $dumpvars; 
    $dumpfile("dump.vcd"); 
  end
endmodule
