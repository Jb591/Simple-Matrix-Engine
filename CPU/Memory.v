module memory (outputDataBus, inputDataBus, addressBus, writeToMem, readFromMem, clk, reset);

// Will be recieving output data from our ALU
input wire [15 : 0] addressBus;
input wire [255 : 0] inputDataBus;

reg [255 : 0] outputRegister;
reg driveTheBus;

// chip enable will state when Memory is ready to start
// readWrite will specify if we read read or write to mem module
// clk will be used for synchronization
input wire writeToMem, readFromMem, clk, reset;

// Our Source 1 and our Source 2
inout [255 : 0] outputDataBus;

// Our RAM Memory, will be storing our indexes and our results
reg [255 : 0] myMem [7 : 0]; // i will only use 6 bits long but ill make it 8 bits long because power of 2

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
parameter RegisterEnable = 4'h4;

// Filling our memory matrxi with 0 and 1 bring the initial 2 matrix from the project slides
always @ (negedge reset)
begin
  myMem[0] = 255'h0004_000c_0004_0022_0007_0006_000b_0009_0009_0002_0008_000d_0002_000f_0010_0003;
  myMem[1] = 255'h0017_002d_001f_0016_0007_0006_0004_0001_0012_000c_000d_000c_000d_0005_0007_0013;
  myMem[2] = 255'd0;
  myMem[3] = 255'd0;
  myMem[4] = 255'd0;
  myMem[5] = 255'd0; 
  myMem[6] = 255'd0;
  myMem[7] = 255'd0;
  outputRegister = 256'd0;
  driveTheBus = 0;
end

// Using our 16 bit address bus [15 : 0]
// Last 4 bits will be used to state what module were in [15 : 12]
// Next 4 bits of adressBus will be used for the location in InstrROM [11 : 8]
// Next 4 bits will be used for the address in Memory [7 : 4]
// last 4 bits will be used for the address in Register [3 : 0]

always @ (posedge clk)
begin
  if (addressBus[15 : 12] == memoryEnable)
  begin
    if (readFromMem) // Reading From Meme
    begin
      outputRegister = myMem[addressBus[7 : 4]]; // Meaning that we are going to return the value in the array into the outputData
      driveTheBus = 1; // Tell to send the output
    end
    if (writeToMem) // Writting to Meme
    begin
      myMem[addressBus[7 : 4]] = inputDataBus; // Storing The input Value into the Memory Location in the address assigned by EXE
      driveTheBus = 0; // Were not gonna talk to the bus
    end
  end
end

assign outputDataBus = (driveTheBus) ? outputRegister : 256'dz;

endmodule
