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
        delegatee = address(uint160(delegatee)); // Convert uint256 to uint160, then to address
        amount = bound(amount, 1e18, 100e18);
    
        // Mint tokens to user1 for testing
        vm.startPrank(owner);
        token.mint(user1, 100e18);
        vm.stopPrank();
    
        // Test delegation if the delegatee is valid
        if (delegatee != user1 && delegatee != address(0)) {
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
                assertEq(token.balanceOf(user1), 0, "RageQuit should burn the appropriate amount of tokens.");
            } else {
                vm.expectRevert(GovernanceToken.NoTokensToRageQuit.selector);
                vm.startPrank(user1);
                token.rageQuit();
                vm.stopPrank();
            }
        } else {
            // If the delegatee is the zero address, expect revert with ZeroAddress error
            if (delegatee == address(0)) {
                vm.expectRevert(GovernanceToken.ZeroAddress.selector);
            } else {
                // Test invalid delegation (self-delegation)
                vm.expectRevert(GovernanceToken.AlreadyDelegated.selector);
            }
            
            vm.startPrank(user1);
            token.delegate(delegatee);
            vm.stopPrank();
        }
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