// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GovernanceToken.sol"; // adjust path if needed

contract GovernanceTokenTest is Test {
    GovernanceToken token;

    function setUp() public {
        token = new GovernanceToken();
    }
}



function testMint() public {
    address user = address(1);
    token.mint(user, 1000);
    assertEq(token.balanceOf(user), 1000);
}

