// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/Gallery.sol";
import "../src/ArtGalleryToken.sol";

contract GalleryTest is Test {
    GalleryCore core;
    ArtGalleryToken token;
    address owner = address(1);
    address user1 = address(2);

    function setUp() public {
        vm.startPrank(owner);
        token = new ArtGalleryToken();
        address[3] memory signers = [address(10), address(11), address(12)];
        core = new GalleryCore(address(token), signers);
        token.mint(user1, 100e18);
        vm.stopPrank();
    }

    function testMint() public view {
        assertEq(token.balanceOf(user1), 100e18);
    }

    function testFuzz_Mint(uint256 amount) public {
        // Bound the minting amount for gas optimization and test edge cases
        amount = bound(amount, 1e18, 1e24);

        // Ensure the token balance increases after minting
        uint256 initialBalance = token.balanceOf(user1);
        
        vm.startPrank(owner);
        token.mint(user1, amount);
        vm.stopPrank();

        uint256 newBalance = token.balanceOf(user1);
        assertEq(newBalance, initialBalance + amount, "Minted amount should reflect in the balance.");
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

    function testFuzz_DelegateAndRageQuit(address delegatee, uint256 amount) public {
        // Bound the address and the amount to valid ranges
        delegatee = address(uint160(delegatee)); // Convert uint256 to address
        amount = bound(amount, 1e18, 100e18);
    
        // Mint tokens to user1 for testing
        vm.startPrank(owner);
        token.mint(user1, 100e18);
        vm.stopPrank();
    
        // Handle delegation
        if (delegatee == address(0)) {
            // Expect revert on zero address delegation
            vm.expectRevert(ArtGalleryToken.ZeroAddress.selector);
            vm.startPrank(user1);
            token.delegate(delegatee);
            vm.stopPrank();
            return; // Exit early since the revert is expected
        }
    
        // Allow delegation (including self-delegation)
        vm.startPrank(user1);
        token.delegate(delegatee);
        vm.stopPrank();
    
        assertTrue(token.hasDelegated(user1), "Delegate function failed to register delegation.");
    
        // Now attempt rage quitting after delegation
        uint256 initialBalance = token.balanceOf(user1);
    
        if (amount <= initialBalance) {
            vm.startPrank(user1);
            token.rageQuit();
            vm.stopPrank();
            assertEq(token.balanceOf(user1), 0, "RageQuit should burn all tokens.");
        } else {
            vm.expectRevert(ArtGalleryToken.NoTokensToRageQuit.selector);
            vm.startPrank(user1);
            token.rageQuit();
            vm.stopPrank();
        }
    }    
    
    function testFullProposalLifecycle() public {
        address[6] memory users = [user1, address(3), address(4), address(5), address(6), address(7)];
    
        // Mint and delegate tokens to users
        vm.startPrank(owner);
        for (uint256 i = 0; i < users.length; ++i) {
            token.mint(users[i], 10e18);
        }
        vm.stopPrank();
    
        for (uint256 i = 0; i < users.length; ++i) {
            vm.prank(users[i]);
            token.delegate(users[i]);
    
            vm.prank(users[i]);
            token.approve(address(core), 10e18);
        }
    
        // Advance one block so the delegations are recognized
        vm.roll(block.number + 1);
    
        // Create the proposal from user1
        bytes memory callData = abi.encodeWithSignature("getProposalState(uint256)", 0);
        vm.prank(user1);
        core.createProposal("Proposal 1", callData, GalleryCore.ProposalType.Routine);

        // Advance time to allow voting
        uint256 voteStartTime = block.timestamp + core.VOTING_DELAY();
        uint256 voteEndTime = voteStartTime + core.VOTING_PERIOD();
        vm.warp(voteStartTime + 1); // Move to start of voting period
    
        // Each user votes
        for (uint256 i = 0; i < users.length; ++i) {
            vm.prank(users[i]);
            core.castVoteQuadratic(0, true, 10e18);
        }
    
        // Advance time to end the voting period
        vm.warp(voteEndTime + 1);
    
        // Finalize the proposal
        vm.prank(owner);
        core.finalizeProposal(0);

        // Assert state
        GovernanceCore.ProposalState state = core.getProposalState(0);
        assertEq(uint8(state), uint8(GovernanceCore.ProposalState.Succeeded));

        // Confirm the proposal execution using two multi-sig signers
        vm.prank(address(10)); // Signer 1
        core.confirmProposalExecution(0);
        
        vm.prank(address(11)); // Signer 2
        core.confirmProposalExecution(0);

        // Now execute the proposal
        vm.prank(owner); // Owner can execute after confirmations
        core.executeProposal(0);
        
        // Assert final state
        state = core.getProposalState(0);
        assertEq(uint8(state), uint8(GalleryCore.ProposalState.Executed));
    }
}
