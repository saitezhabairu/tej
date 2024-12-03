// xor_gate.v
module xor_gate(
    input wire a,     // Input A
    input wire b,     // Input B
    output wire y     // Output Y
);
    // XOR gate logic
    assign y = a ^ b;
endmodule
