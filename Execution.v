module execution (addressBus, instructionData, executionData, clock, reset);

output [15 : 0] addressBus;
input [31 : 0] instructionData; 
output [3 : 0] executionData;
input clock, reset;
reg [3 : 0] nextState, stateReg; // I will use this to match the exeData so ALU knows Whats up
reg driveTheBus, driveTheExe, driveTheAddress;
reg index; // This how ill know which instruction im in;

reg [15 : 0]address;
reg [255 : 0] outputBus;
reg [31 : 0] instrData; 
reg [3 : 0] exeData;

//   myInstrROM[0] = 32'h00_02_00_01; 
//   myInstrROM[1] = 32'h01_03_00_02;
//   myInstrROM[2] = 32'h02_04_02_00;
//   myInstrROM[3] = 32'h03_05_05_00;
//   myInstrROM[4] = 32'h04_06_03_05;
//   myInstrROM[5] = 32'h05_00_00_00; 

// ALU States 
// parameter startState = 4'h1; // wait until told what to do
// parameter commandRecieved = 4'h0; // it recieved a command // did not use but it worked to my advantage that i didnt use it
// parameter getSource1 = 4'h2; // wait for next command
// parameter getSource2 = 4'h3; // wait for next command
// parameter executeMath = 4'h4; // wait until ALU is done Meaning we need a signal bit
// parameter sendDone = 4'hf; // get next instruction, sike, tell EXE done
// parameter moveResult = 4'h5; // Move result to dataBus

// Here is what im having trouble in. I want to communicate ALU with EXE but to do that i either add an input output EXE or use inout
// When it comes to the testBenches, i cannot use inout, so i dont think ill be able to make all of them communicate 
// With eachother. Rn i noticed im only talking to Memory, and in memory i have no communication with ALU or EXE its basically independent

// EXE State Machine
parameter readInstruction = 0; // Alligned with command Recieved in 
parameter decodeInstruction = 1; // 
parameter moveSource1 = 2; // alligned with getSource 1
parameter moveSource2 = 3; // alligned with get source 2
parameter executeMath = 4; // alligned with execute math 
parameter moveDestination = 5; // alligned with moveResult in ALU

always @ (negedge reset)
begin
    if (reset = 0)
    begin
        stateReg = readInstruction;
        address = 16'd0;
        outputBus = 256'd0;
        instrData = 32'd0; 
        exeData = 4'd0;
        index = 0; 
    end

    else 
    begin
        stateReg = nextState; 
    end
end


parameter instructionEnable = 4'h0; 
parameter memoryEnable = 4'h1; 
parameter ALUEnable = 4'h2; 
parameter EXEEnable = 4'h3; 
parameter RegisterEnable = 4'h4;

always @ (stateReg)
begin
    case (stateReg)
        readInstruction:
            address[15 : 12] = instructionEnable; // We want to get the data from enable
            address[11 : 8] = index; // Talking to Instruction
            address[7 : 4] = 4'd0;
            address[3 : 0] = 4'd0; // Not Talking to Register 
            driveTheAddress = 1;
            nextState = decodeInstruction; 
        decodeInstruction:
            instrData = instructionData;
            driveTheExe = 1;
            nextState = moveSource1;
        moveSource1:
            address[15 : 12] = memoryEnable; // We are going to talk to memory 
            address[11 : 8] = 4'd0; // Not Talking to Instruction
            address[7 : 4] = instrData[15 : 8]; // Source 1 location 
            address[3 : 0] = 4'd0; // Not Talking to Register 
            nextState = moveSource2;
            driveTheExe = 1;
            driveTheAddress = 1;
        moveSource2:
            address[15 : 12] = memoryEnable; // We are going to talk to memory 
            address[11 : 8] = 4'd0; // Not Talking to Instruction
            address[7 : 4] = instrData[7 : 0]; // Source 2 location 
            address[3 : 0] = 4'd0; // Not Talking to Register 
            nextState = moveDestination;
            driveTheAddress = 1;
        moveDestination:
            address[15 : 2] memoryEnable; // we are going to talk to memory 
            address[11 : 8] = 4'd0; // Not Talking to Instruction
            address[7 : 4] = instrData[23 : 16]; // Dest Location in Memory
            address[3 : 0] = 4'd0; // Not Talking to Register 
            nextState = readInstruction;
            driveTheAddress = 1;
            driveTheExe = 1;
    endcase
    index = index + 1; // increment where we're reading from instr
end

assign addressBus = (driveTheAddress) ? address : 32'bz;
assign executionData = (driveTheExe) ? stateReg : 4'bz;

endmodule