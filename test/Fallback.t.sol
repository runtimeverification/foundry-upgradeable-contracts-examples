// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";


interface Ifc {
    function hello() external;
    function bye() external;
}


contract C {
    event Log(string msg);

    function hello() external {
        emit Log("hello");
    }

    fallback() external {
        emit Log("fallback");
    }
}


contract FallbackTest is Test {
    event Log(string msg);

    function testFallback() public {
        Ifc ifc = Ifc(address(new C()));

        // Check that `ifc.hello()` emits a Log("hello") event
        vm.expectEmit(false, false, false, true); emit Log("hello");
        ifc.hello();

        // Check that `ifc.bye()` emits a Log("fallback") event
        vm.expectEmit(false, false, false, true); emit Log("fallback");
        ifc.bye();
    }
}
