// wrapper.v
`timescale 1ns / 1ps

module wrapper(
    input wire a,
    input wire b,
    output wire y
);

    // Instantiate the XOR gate
    xor_gate xor1 (
        .a(a),
        .b(b),
        .y(y)
    );

endmodule
