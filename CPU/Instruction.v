module instruction (instructionData, addressBus, readFromInst, clk, reset);
// my instruction set
// add        = 8'h00;
// sub        = 8'h01;
// transpose  = 8'h02;
// scale      = 8'h03;
// multiply   = 8'h04;
// stop       = 8'h05;

input wire readFromInst, clk, reset;
reg [31 : 0] outputRegister;
output [31 : 0] instructionData;
reg [31 : 0] myInstrROM [5 : 0]; // 32 x 6 matrix 
// Instruction Logic
// [31 : 24] -> opcode 
// [23 : 16] -> Destination
// [15 : 8]  -> Scr1
// [7 : 0]   -> Scr2

// adress is 16 bits [15 : 11] will represent the module the rest in a submodule
input [15 : 0] addressBus; 
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
parameter RegisterEnable = 4'h4;

// opcode   destination   source1   source2 each is 8bits wide, maybe ill change the sources to be 256
// 00_02_00_01 -> Add the first matrix to the second matrix and store the result in memory
// 01_03_02_00 -> Subtract the first matrix from the result in step 1 and store the result somewhere else in memory. 
// 02_04_02_00 -> Transpose the result from step 1 store in memory
// 03_05_04_07 -> Scale the result in step 3 store in a register
// 04_06_05_03 -> Multiply the result from step 4 by the result in step 3, store in memory. 
// 05_00_00_00 -> stops

// opcode   destination    source 1   source 2
always @ (negedge reset) // When reset = 0
begin
  myInstrROM[0] = 32'h00_02_00_01; 
  myInstrROM[1] = 32'h01_03_00_02;
  myInstrROM[2] = 32'h02_04_02_00;
  myInstrROM[3] = 32'h03_05_05_06; // Immeadeate = 6;
  myInstrROM[4] = 32'h04_06_03_05;
  myInstrROM[5] = 32'h05_00_00_00; 
  outputRegister = 32'd0;
  driveTheBus = 0;
end

// Using our 16 bit address bus [15 : 0]
// Last 4 bits will be used to state what module were in [15 : 12]
// Next 4 bits of adressBus will be used for the location in InstrROM [11 : 8]
// Next 4 bits will be used for the address in Memory [7 : 4]
// last 4 bits will be used for the address in Register [3 : 0]

always @ (posedge clk)
begin 
  if (addressBus[15:12] == instructionEnable)
  begin 
    if (readFromInst)
    begin
      // transfer the data from memory into our instructionData
      outputRegister = myInstrROM[addressBus[11 : 8]];
      driveTheBus = 1;
    end // end of reading From instr
  end // end of enable
  // First is to know when we instruction is being talked to, we will check the first 4 bits in address Bus
end

// So about this i can see it rn, what if we havent written anything 
assign instructionData = (driveTheBus) ? outputRegister : 256'dz;

endmodule
