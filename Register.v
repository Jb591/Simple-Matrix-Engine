module register(outputDataBus, inputDataBus, addressBus, writeToReg, readFromReg, reset, clk);

// ill use this module if i do any extra credit; 
input [15 : 0] addressBus;
reg [255 : 0] outputRegister;
input writeToReg, readFromReg, reset, clk;
reg [255 : 0] myRegMem;
reg driveTheBus;

// Enable Modules :
// Enable Instruction -> 4'h0
// Enable Memory -> 4'h1
// Enable ALU -> 4'h2
// Enable EXE -> 4'h3
// Enable Register -> 4'h4
parameter instructionEnable = 4'h0; 
parameter memoryEnable = 4'h1; 
parameter ALUEnable = 4'h2; 
parameter EXEEnable = 4'h3; 
parameter registerEnable = 4'h4;

inout [255 : 0] outputDataBus;
input [255 : 0] inputDataBus;

always @ (negedge reset)
begin
  myRegMem [0] = 256'd0;
  outputRegister = 255'd0;
  driveTheBus = 0;
end

// Using our 16 bit address bus [15 : 0]
// Last 4 bits will be used to state what module were in [15 : 12]
// Next 4 bits of adressBus will be used for the location in InstrROM [11 : 8]
// Next 4 bits will be used for the address in Memory [7 : 4]
// last 4 bits will be used for the address in Register [3 : 0]

always @ (posedge clk)
begin
  if (addressBus[15 : 12] == registerEnable)
  begin
    if (readFromReg)
    begin
      outputRegister = myRegMem;
      driveTheBus = 1;
    end
    if (writeToReg)
    begin
      myRegMem = inputDataBus;
      driveTheBus = 0;
    end
  end
end

assign outputDataBus = driveTheBus ? outputRegister : 256'dz;

endmodule
