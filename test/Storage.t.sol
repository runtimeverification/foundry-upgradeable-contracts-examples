// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";


contract Token {
    address immutable owner;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    string name;

    constructor(string memory _name) {
        owner = msg.sender;
        name = _name;
    }

    function mint(address user, uint256 amount) external {
        require(msg.sender == owner, "Only owner is allowed to mint");
        balanceOf[user] += amount;
    }
}


contract StorageTest is Test {
    address Alice = makeAddr("Alice");

    function testLoadBalance() public {
        Token t = new Token("Hi");
        t.mint(Alice, 5 ether);

        // Compute the slot at which Alice's balance is stored in the Token contract
        bytes32 aliceBalanceSlot = keccak256(
            abi.encodePacked(uint256(uint160(Alice)), uint256(1))
        );

        // Now load Alice's balance
        uint256 aliceBalance = uint256(vm.load(address(t), aliceBalanceSlot));

        // Make sure that the loaded balance matches Alice's real balance
        assertEq(aliceBalance, t.balanceOf(Alice));
    }
}
