// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";


// The logic contract
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


// The proxy
contract FaultyProxy {
    address public implementation;

    function upgradeTo(address newImpl) external {
        implementation = newImpl;
    }

    fallback() external payable {
        (bool ok, bytes memory returnData) = implementation.delegatecall(msg.data);

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


contract FaultyProxyTest is Test {
    // For this test to pass it must revert
    function testFailFaultyProxy() public {
        // (1) Create logic contract
        Counter logic = new Counter();

        // (2) Create proxy and tell it which logic contract to use
        FaultyProxy proxy = new FaultyProxy();
        proxy.upgradeTo(address(logic));

        // (3) To be able to call functions from the logic contract, we need to
        //     cast the proxy to the right type
        Counter proxied = Counter(address(proxy));

        // (4) Now we treat the proxy as if it were the logic contract
        proxied.add(2);

        // (5) Did it work? Spoiler: no!
        //     The reason is that the previous call `proxied.add(2)` changed FaultyProxy.implementation
        //     in such a way that it now contains the address of an empty account. Note that using
        //     delegatecall on an empty account actually succeeds and is not what is causing the
        //     revert. The real problem is that `proxied.get()` expects a uint256 to be returned,
        //     but empty accounts do not return anything. Thus, trying and failing to decode the
        //     return value is what actually causes this call to revert.
        console.log("counter =", proxied.get()); // Reverts!
    }
}
