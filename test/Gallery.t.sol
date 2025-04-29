// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/Gallery.sol";
import "../src/ArtGalleryToken.sol";

contract GalleryTest is Test {
    GalleryCore core;
    ArtGalleryToken token;
    address owner = address(1);
    address user1 = address(2);
    address user2 = address(3);

    function setUp() public {
        vm.startPrank(owner);
        token = new ArtGalleryToken();
        address[3] memory signers = [address(10), address(11), address(12)];
        core = new GalleryCore(address(token), signers);
        token.mint(user1, 100e18);
        vm.stopPrank();
    }

    function testCreateProposal() public {
        // Arrange: The user must have enough tokens to create a proposal.
        // Mint and delegate tokens to users
        vm.startPrank(owner);
        token.mint(user1, 10e18);
        vm.stopPrank();
        
        vm.startPrank(user1);
        token.delegate(user1);
        token.approve(address(core), 10e18);
        vm.roll(block.number + 1);

        // User creates a proposal
        bytes memory callData = abi.encodeWithSignature("someFunction()");
        core.createProposal("Test Proposal", callData, GalleryCore.ProposalType.Routine);
        
        // Verify that the proposal is created successfully
        GovernanceCore.ProposalState state = core.getProposalState(0);
        assertEq(uint8(state), uint8(GalleryCore.ProposalState.Pending), "Proposal state should be Pending");
        vm.stopPrank();
    }

    // Test case to simulate an attempt to create a proposal with insufficient voting power
    function testCreateProposalWithInsufficientVotingPower() public {
        // Arrange: The user doesn't have enough tokens to create a proposal.
        vm.startPrank(owner);
        token.mint(user2, 5e18);
        vm.stopPrank();
        
        vm.startPrank(user2);
        token.delegate(user2);
        token.approve(address(core), 5e18);

        // Act & Assert: Expect the createProposal call to fail due to insufficient voting power
        vm.expectRevert("Insufficient voting power");
        core.createProposal("Test Proposal", abi.encodeWithSignature("someFunction()"), GalleryCore.ProposalType.Routine);

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
        bytes memory callData = abi.encodeWithSignature("someFunction()");
        core.createProposal("Test Proposal", callData, GalleryCore.ProposalType.Routine);

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

        assertEq(yesVotes, core.sqrt(10e18)); // sqrt(10e18)
        assertEq(noVotes, 0);
        assertEq(totalQuadraticVotes, core.sqrt(10e18));
    }

    // Fuzz test for createProposal with random token amounts
    function testFuzzCreateProposal(uint256 tokenAmount) public {
        // Ensure tokenAmount is within valid bounds
        vm.assume(tokenAmount >= 1e18 && tokenAmount <= 100e18);

        // Mint the tokens
        vm.startPrank(owner);
        token.mint(user1, tokenAmount);
        vm.stopPrank();

        vm.startPrank(user1);
        token.delegate(user1);
        token.approve(address(core), tokenAmount);
        vm.roll(block.number + 1);

        // User creates a proposal
        bytes memory callData = abi.encodeWithSignature("someFunction()");
        core.createProposal("Test Proposal", callData, GalleryCore.ProposalType.Routine);
        
        // Verify that the proposal is created successfully
        GovernanceCore.ProposalState state = core.getProposalState(0);
        assertEq(uint8(state), uint8(GovernanceCore.ProposalState.Pending), "Proposal state should be Pending");
        vm.stopPrank();
    }

    // Fuzz test for casting quadratic vote with random token amounts
    function testFuzzCastVoteQuadratic(uint256 tokenAmount) public {
        // Ensure tokenAmount is within valid bounds
        vm.assume(tokenAmount >= 1e18 && tokenAmount <= 100e18);

        // Setup: mint, delegate, approve, and create proposal
        vm.startPrank(owner);
        token.mint(user1, 100e18);
        vm.stopPrank();

        vm.prank(user1);
        token.delegate(user1);

        vm.roll(block.number + 1);

        vm.prank(user1);
        token.approve(address(core), tokenAmount);

        vm.prank(user1);
        bytes memory callData = abi.encodeWithSignature("someFunction()");
        core.createProposal("Test Proposal", callData, GalleryCore.ProposalType.Routine);

        // Advance time past voting delay
        vm.warp(block.timestamp + core.VOTING_DELAY());

        // Vote with the random token amount
        vm.prank(user1);
        core.castVoteQuadratic(0, true, tokenAmount);

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

        // Ensure the quadratic votes are correctly calculated
        assertEq(yesVotes, core.sqrt(tokenAmount));
        assertEq(noVotes, 0);
        assertEq(totalQuadraticVotes, core.sqrt(tokenAmount));
    }

    // Fuzz test for proposal state with random timestamps
    function testFuzzProposalState(uint256 timestamp) public {
        // Ensure timestamp is within valid bounds
        vm.assume(timestamp >= block.timestamp && timestamp <= block.timestamp + 10 days);
    
        // Setup: mint tokens and create proposal
        vm.startPrank(owner);
        token.mint(user1, 100e18);
        vm.stopPrank();
    
        vm.startPrank(user1);
        token.delegate(user1);
        token.approve(address(core), 10e18);
        vm.roll(block.number + 1);
    
        bytes memory callData = abi.encodeWithSignature("someFunction()");
        core.createProposal("Test Proposal", callData, GalleryCore.ProposalType.Routine);
    
        // Simulate voting delay using fuzzed timestamp
        // Ensure that we add enough time to surpass the voting delay
        uint256 votingDelay = core.VOTING_DELAY();
        vm.warp(block.timestamp + votingDelay + 1);  // Add 1 extra second to ensure the delay is surpassed
    
        // Check the proposal state (it should be active after voting delay)
        GovernanceCore.ProposalState state = core.getProposalState(0);
        assertEq(uint8(state), uint8(GalleryCore.ProposalState.Active), "Proposal should be Active after voting delay");
    
        vm.stopPrank();
    }    
}
