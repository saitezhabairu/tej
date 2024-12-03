# xor_test.py
import cocotb
from cocotb.regression import TestFactory
from cocotb.result import TestFailure

# Define the test function as a coroutine with 'async def'
@cocotb.coroutine
async def xor_gate_test(dut):
    """Test coroutine to check XOR functionality."""
    
    # Apply test vectors (a, b) and check the result
    test_vectors = [
        (0, 0, 0),  # 0 ^ 0 = 0
        (0, 1, 1),  # 0 ^ 1 = 1
        (1, 0, 1),  # 1 ^ 0 = 1
        (1, 1, 0)   # 1 ^ 1 = 0
    ]
    
    for a, b, expected_y in test_vectors:
        dut.a <= a
        dut.b <= b
        await cocotb.start(dut._wait_for_simulation())  # Wait for the simulation to settle

        # Check output
        if dut.y != expected_y:
            raise TestFailure(f"Test failed for inputs {a}, {b}. Expected {expected_y}, got {dut.y}")

    print("All test cases passed!")

# Factory to generate the tests
factory = TestFactory(xor_gate_test)

# Set the simulation options
factory.add_option("-sv",["-SV"])  # Use SystemVerilog if needed

# Generate and run the testbench
factory.generate_tests()
