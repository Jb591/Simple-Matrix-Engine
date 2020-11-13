module tMemory;

reg [255 : 0] inputBus;
reg [15 : 0] addressBus; 
wire [255 : 0] dataBus;
reg reset, clk, writeToMem, readFromMem;

memory myMemory(dataBus, inputBus, addressBus, writeToMem, readFromMem, clk, reset);

initial
begin
  addressBus = 16'h0_0_0_0;
  inputBus = 256'h0;
  writeToMem = 0; 
  readFromMem = 0;
  reset = 1;
  clk = 0;
end

initial
begin
  reset = 0; // reset the values;  
  
  #2 addressBus = 16'h1_0_0_0; // Enable Mem and read from location 0;
  #2 readFromMem = 1; // Were going to read the data and enable the bus
  #2 clk = 1; // begin

  #2 clk = 0;
  #2 reset = 1; 
  #2 reset = 0;
  #2 readFromMem = 0;
  #2 writeToMem = 1;
  #2 addressBus = 16'h1_0_2_0; // We are going to write to MemLocation 2
  #2 inputBus = 256'h0017_002d_0043_0016_0007_0006_0004_0001_0012_0038_000d_000c_0003_0005_0007_0009;
  #2 clk = 1; // begin
  #2 writeToMem = 0;
  
  #2 clk = 0;
  #2 readFromMem = 0;
  #2 writeToMem = 1;
  #2 addressBus = 16'h1_0_3_0; // We are going to write to MemLocation 3 without resetting
  #2 inputBus = 256'h0004_000c_0004_0022_0007_0006_000b_0009_0009_0002_0008_000d_0002_000f_0010_0003;
  #2 clk = 1; // begin
end

initial
begin
  $monitor ("dataBus : %h\ninputData : %h\naddressBus : %h\nwriteToMem : %d\nReadFromMem : %d\nclock : %d\nreset : %d\n\n",
  dataBus, inputBus, addressBus, writeToMem, readFromMem, clk, reset);
end


endmodule
