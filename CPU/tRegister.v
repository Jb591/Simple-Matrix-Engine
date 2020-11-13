module tRegister;

reg clk, reset, writeToReg, readFromReg;
wire [255 : 0] outputDataBus;
reg [15 : 0] addressBus;
reg [255 : 0] inputDataBus;

register myRegister(outputDataBus, inputDataBus, addressBus, writeToReg, readFromReg, reset, clk);

initial
begin
  addressBus = 16'h0_0_0_0;
  readFromReg = 0;
  writeToReg = 0;
  clk = 0; 
  reset = 0;
end


initial
begin
  reset = 0; // reset the values;  
  
  #2 clk = 0;
  #2 reset = 1; 
  readFromReg = 0;
  writeToReg = 1;
  #2 addressBus = 16'h4_0_0_0; // We are going to write to RegLocation 0
  #2 inputDataBus = 256'h0017_002d_0043_0016_0007_0006_0004_0001_0012_0038_000d_000c_0003_0005_0007_0009;
  #2 clk = 1; // begin
  #2 writeToReg = 0;

  #2 addressBus = 16'h4_0_0_0; // Enable Reg and read from location 0;
  writeToReg = 0;
  readFromReg = 1; // Were going to read the data and enable the bus
  #2 clk = 1; // begin
  
  #2 clk = 0;
  readFromReg = 0;
  writeToReg = 1;
  #2 addressBus = 16'h4_0_0_0; // We are going to write to RegLocation 3 without reseting
  #2 inputDataBus = 256'h0004_000c_0004_0022_0007_0006_000b_0009_0009_0002_0008_000d_0002_000f_0010_0003;
  #2 clk = 1; // begin

  #2 clk = 0; 
  readFromReg = 1;
  writeToReg = 0;
  #2 addressBus = 16'h4_0_0_0;
  #2 clk = 1;
end

initial
begin
  $monitor ("outputDataBus : %h\ninputData : %h\naddressBus : %h\nwriteToMem : %d\nReadFromMem : %d\nclock : %d\nreset : %d\n\n",
  outputDataBus, inputDataBus, addressBus, writeToReg, readFromReg, clk, reset);
end


endmodule
