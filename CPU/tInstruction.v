module tInstruction;

wire [31 : 0] instructionData;
reg [15 : 0] addressBus; 
reg readFromInst, clk, reset;

instruction myInstruction(instructionData, addressBus, readFromInst, clk, reset);

initial
begin
    addressBus = 16'h0_0_0_0;
    readFromInst = 0;
    clk = 0; 
    reset = 0;
end

initial
begin
   #2 addressBus = 16'h0_0_0_0; // This will read from location 0 in instr
   #2 readFromInst = 1; // We will be reading to it
   #2 reset = 1;
   #2 clk = 1; // Now We will begin
   #2 clk = 0; 
   #2 addressBus = 16'h0_5_0_0; // This will get address 5
   #2 clk = 1;
end
initial
begin
    $monitor("TheAddress : %h\nread : %h\nclock : %h\nreset : %h\noutputData : %h\n\n", 
        addressBus, readFromInst, clk, reset, instructionData);
end


endmodule
