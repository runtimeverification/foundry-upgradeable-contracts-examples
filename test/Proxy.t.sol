// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";


// The logic contract
contract Counter {
    bool isInitialized;
    uint256 number;

    function initialize(uint256 start) external {
        require(!isInitialized, "Already initialized");
        number = start;
        isInitialized = true;
    }

    function get() external view returns(uint256) {
        return number;
    }

    function add(uint256 n) external {
        require(n <= 5, "Max increment is 5");
        number += n;
    }
}


// Second version of the logic contract, allowing the counter to be increased by up to 10 steps at a time
contract CounterV2 {
    bool isInitialized;
    uint256 number;

    function initialize(uint256 start) external {
        require(!isInitialized, "Already initialized");
        number = start;
        isInitialized = true;
    }

    function get() external view returns(uint256) {
        return number;
    }

    function add(uint256 n) external {
        require(n <= 10, "Max increment is 5");
        number += n;
    }
}


contract Proxy {
    bytes32 constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    function upgradeTo(address newImpl) external {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImpl)
        }
    }

    function implementation() public view returns(address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    fallback() external payable {
        (bool ok, bytes memory returnData) = implementation().delegatecall(msg.data);

        if(!ok)
            revert("Calling logic contract failed");

        // Forward the return value
        assembly {
            let data := add(returnData, 32)
            let size := mload(returnData)
            return(data, size)
        }
    }
}


contract ProxyTest is Test {
    function testProxy() public {
        // (1) Create logic contract
        Counter logic = new Counter();

        // (2) Create proxy and tell it which logic contract to use
        Proxy proxy = new Proxy();
        proxy.upgradeTo(address(logic));

        // (3) To be able to call functions from the logic contract, we need to
        //     cast the proxy to the right type
        Counter proxied = Counter(address(proxy));
        proxied.initialize(23);

        assertEq(proxied.get(), 23);

        // (4) Now we treat the proxy as if it were the logic contract
        proxied.add(2); // Works as expected
        assertEq(proxied.get(), 25);

        vm.expectRevert();
        proxied.add(7); // Fails as expected

        // (5) Upgrade to a new logic contract
        proxy.upgradeTo(address(new CounterV2()));

        // (6) Now adding a value larger than 5 actually works!
        proxied.add(7);
        assertEq(proxied.get(), 32);
    }
}
