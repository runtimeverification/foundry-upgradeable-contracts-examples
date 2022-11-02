// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// Declare a global instance of Vm so we can use it's functions outside of Test contracts
Vm constant VM = Vm(address(uint160(uint256(keccak256('hevm cheat code')))));


contract Counter {
    uint256 number;

    function get() external view returns(uint256) {
        return number;
    }

    function add(uint256 n) external {
        require(n <= 5, "Max increment is 5");
        number += n;
    }
}


contract DelegateCounter {
    uint256 number;

    function get() external view returns(uint256) {
        return number;
    }

    function delegateAdd(Counter c, uint256 n) external {
        bytes memory callData = abi.encodeWithSignature("add(uint256)", n);

        // Run test with `forge test -vvv` to see the output of this log messages
        console.log("Call data: ", VM.toString(callData));

        (bool ok,) = address(c).delegatecall(callData);
        if(!ok) revert("Delegate call failed");
    }

    // Same as get(), but implemented using delegatecall like delegateAdd()
    function delegateGet(Counter c) external returns(uint256) {
        bytes memory callData = abi.encodeWithSignature("get()");
        (bool ok, bytes memory retVal) = address(c).delegatecall(callData);

        if(!ok) revert("Delegate call failed");

        return abi.decode(retVal, (uint256));
    }

    // Same as delegateGet(), but return the value using assembly to save call to abi.decode()
    function delegateGetBetter(Counter c) external returns(uint256) {
        bytes memory callData = abi.encodeWithSignature("get()");
        (bool ok, bytes memory retVal) = address(c).delegatecall(callData);

        if(!ok) revert("Delegate call failed");

        assembly {
            let data := add(retVal, 32)
            let size := mload(retVal)

            // The `return` instruction expects two arguments that describe the region in memory
            // that contains the return data:
            // - The address in memory that stores the beginning of the return data.
            // - The size of the return data in bytes.
            //
            // `retVal` refers to a byte array in memory. The first slot (32 bytes) contains the
            // number of elements, and the following slots contain the elements themselves.
            return(data, size)
        }
    }
}


contract DelegateCallTest is Test {
    function testDelegate() public {
        Counter c = new Counter();
        DelegateCounter d = new DelegateCounter();

        // Sanity check: both counters should start at zero
        assertEq(c.get(), 0);
        assertEq(d.get(), 0);

        d.delegateAdd(c, 4);

        // Check that `d` has been updated
        assertEq(c.get(), 0);
        assertEq(d.get(), 4);

        // Check that delegateGet() and delegateGetBetter() return the correct value
        assertEq(d.delegateGet(c), d.get());
        assertEq(d.delegateGetBetter(c), d.get());
    }
}
