// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/Governance.sol";
import "../src/GovernanceToken.sol";

contract GovernanceTest is Test {
    GovernanceCore core;
    GovernanceToken token;
    address owner = address(1);
    address user1 = address(2);

    function setUp() public {
        vm.startPrank(owner);
        token = new GovernanceToken();
        address[3] memory signers = [address(10), address(11), address(12)];
        core = new GovernanceCore(address(token), signers);
        token.mint(user1, 100e18);
        vm.stopPrank();
    }

    function testMint() public view {
        assertEq(token.balanceOf(user1), 100e18);
    }

    function testDelegate() public {
        vm.prank(user1);
        token.delegate(user1);
        assertTrue(token.hasDelegated(user1));
    }

    function testRageQuit() public {
        vm.prank(user1);
        token.rageQuit();
        assertEq(token.balanceOf(user1), 0);
    }

    function testFullProposalLifecycle() public {
        // Delegate votes to self
        vm.prank(user1);
        token.delegate(user1);
    
        // Advance one block so the delegation is recognized
        vm.roll(block.number + 1);
        
        // Approve GovernanceCore to spend tokens for voting
        vm.prank(user1);
        token.approve(address(core), 100e18);

        // Create the proposal
        vm.prank(user1);
        core.createProposal("Proposal 1", "0x", GovernanceCore.ProposalType.Routine);
    
        // Advance time to allow voting
        uint40 delay = uint40(core.VOTING_DELAY());
        vm.warp(block.timestamp + delay);
    
        // Vote
        vm.prank(user1);
        core.castVoteQuadratic(0, true, 10e18);
    }
}
