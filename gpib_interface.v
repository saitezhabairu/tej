/*
 * GPIB Protocol Design with Addressing and Enhanced Error Handling
 * 
 * Language: Verilog 2001
 */

`timescale 1ns / 1ns

module gpib_interface #
(
    parameter DATA_WIDTH = 8,    // Data width for GPIB (typically 8 bits)
    parameter ADDR_WIDTH = 5     // Address width for GPIB addressing
)
(
    input  wire                  clk,                // Clock signal
    input  wire                  rst,                // Reset signal

    // GPIB signals
    inout  wire [DATA_WIDTH-1:0] gpib_data,          // Data bus (bidirectional)
    input  wire                  atn,                // Attention line
    input  wire                  eoi,                // End or Identify
    input  wire                  ifc,                // Interface Clear
    input  wire                  ren,                // Remote Enable
    input  wire                  srq,                // Service Request
    input  wire                  ndac,               // Not Data Accepted
    input  wire                  dav,                // Data Valid
    input  wire                  nrfd,               // Not Ready for Data
    input  wire [ADDR_WIDTH-1:0] device_address,      // Device address input
    input  wire [ADDR_WIDTH-1:0] address,             // Address of the bus command
    output wire                  listener,           // Listener active
    output wire                  talker,             // Talker active
    output wire                  controller,         // Controller active
    output wire                  error               // Error flag
);

// Internal signals
reg [DATA_WIDTH-1:0] data_reg;
reg [ADDR_WIDTH-1:0] current_address;
reg listener_enable;
reg talker_enable;
reg controller_enable;
reg error_flag;

// Reset logic to clear values on reset signal
always @(posedge rst) begin
    listener_enable <= 1'b0;
    talker_enable <= 1'b0;
    controller_enable <= 1'b0;
    error_flag <= 1'b0;
    current_address <= {ADDR_WIDTH{1'b0}};
    data_reg <= {DATA_WIDTH{1'b0}};
end

// Main logic for handling the GPIB protocol, device role selection, and error checking
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset logic handled already in separate block
    end else begin
        current_address <= device_address;  // Update the device address

        // Error flag reset
        error_flag <= 1'b0;

        // Logic for device role selection based on control signals
        if (!atn && !ifc && (current_address == address)) begin
            listener_enable <= 1'b1;
            talker_enable <= 1'b0;
            controller_enable <= 1'b0;
        end else if (!ifc && srq && (current_address == address)) begin
            talker_enable <= 1'b1;
            listener_enable <= 1'b0;
            controller_enable <= 1'b0;
        end else if (!ifc && !ren) begin
            controller_enable <= 1'b1;
            listener_enable <= 1'b0;
            talker_enable <= 1'b0;
        end else begin
            listener_enable <= 1'b0;
            talker_enable <= 1'b0;
            controller_enable <= 1'b0;
        end

        // Handle errors (e.g., bus contention, invalid data)
        if (nrfd || ndac || (dav && listener_enable && !gpib_data)) begin
            error_flag <= 1'b1;  // Set error if there's bus contention or invalid data
        end
    end
end

// Output assignments
assign listener = listener_enable;
assign talker = talker_enable;
assign controller = controller_enable;
assign error = error_flag;

// Example bidirectional data handling for gpib_data
assign gpib_data = (listener_enable) ? {DATA_WIDTH{1'bz}} :   // Tri-state when listening
                   (!listener_enable && dav) ? data_reg : {DATA_WIDTH{1'bz}};  // Drive data when not in listener mode

// Display signals when listener mode is active
always @(posedge clk) begin
    if (listener_enable && dav) begin
        $display("At time %0t: listener=%b, dav=%b, gpib_data=%h", $time, listener_enable, dav, gpib_data);
    end
end

// Display DAV and listener status
always @(posedge clk) begin
    if (dav) $display("Time %0t: DAV asserted, gpib_data=%h", $time, gpib_data);
    if (listener_enable) $display("Time %0t: Listener enabled", $time);
end

endmodule
