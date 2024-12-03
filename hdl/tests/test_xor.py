# test_xor.py
import cocotb
from cocotb.regression import TestFactory
from cocotb.regression import TestFactory
from cocotb.result import TestFailure


@cocotb.coroutine
def test_xor(dut):
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


# Create the test factory
factory = TestFactory(xor_gate_test)

# Set the simulation options (use your simulator's specific options here)
factory.add_option("-sv")  # Use SystemVerilog if needed

# Generate the testbench
factory.generate_tests()
