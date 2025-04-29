// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
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

    function testCastVoteQuadratic() public {
        // Setup: mint, delegate, approve, and create proposal
        vm.startPrank(owner);
        token.mint(user1, 100e18);
        vm.stopPrank();

        vm.prank(user1);
        token.delegate(user1);

        vm.roll(block.number + 1);

        vm.prank(user1);
        token.approve(address(core), 10e18);

        vm.prank(user1);
        core.createProposal("Test Proposal", "0x", GovernanceCore.ProposalType.Routine);

        // Advance time past voting delay
        vm.warp(block.timestamp + core.VOTING_DELAY());

        // Vote with 10 tokens (sqrt ≈ 3.16e9 wei)
        vm.prank(user1);
        core.castVoteQuadratic(0, true, 10e18);

        // Debug logs
        console.log("Proposal created at block", block.number);
        console.log("Block timestamp", block.timestamp);

        // Check proposal data
        (
            ,
            ,
            ,   
            ,
            ,   
            ,
            ,
            ,
            uint256 totalQuadraticVotes,
            uint256 yesVotes,
            uint256 noVotes
        ) = core.proposals(0);

        assertEq(yesVotes, 3162277660); // sqrt(10e18)
        assertEq(noVotes, 0);
        assertEq(totalQuadraticVotes, 3162277660);
    }

    function testFinalizeProposal_Succeeds() public {
        // Setup: mint, delegate, approve, and create proposal
        vm.startPrank(owner);
        token.mint(user1, 100e18);
        vm.stopPrank();

        vm.prank(user1);
        token.delegate(user1);

        vm.roll(block.number + 1);

        vm.prank(user1);
        token.approve(address(core), 10e18);

        vm.prank(user1);
        core.createProposal("Finalization Test", "0x", GovernanceCore.ProposalType.Routine);

        vm.warp(block.timestamp + core.VOTING_DELAY());

        // Vote
        vm.prank(user1);
        core.castVoteQuadratic(0, true, 10e18);

        // Warp past voting period
        vm.warp(block.timestamp + core.VOTING_PERIOD() + 1);

        // Debug logs
        console.log("Vote end expected at", block.timestamp);
        console.log("Current block timestamp", block.timestamp);

        // Finalize
        core.finalizeProposal(0);

        GovernanceCore.ProposalState state = core.getProposalState(0);
        assertEq(uint(state), uint(GovernanceCore.ProposalState.Succeeded));
    }
}
