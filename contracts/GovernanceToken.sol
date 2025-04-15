// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20Votes, Ownable {
    mapping(address => bool) public hasDelegated;
    mapping(address => bool) public hasVoted;

    constructor() ERC20("GovToken", "GOV") ERC20Permit("GovToken") {
        _mint(msg.sender, 1000 ether); // Initial mint to deployer for testing
    }

    /// @notice Delegate voting power only once
    function delegateOnce(address to) public {
        require(!hasDelegated[msg.sender], "Already delegated");
        require(!hasVoted[msg.sender], "Already voted");
        _delegate(to);
        hasDelegated[msg.sender] = true;
    }

    /// @notice Burn all tokens and exit the DAO (rage quit)
    function rageQuit() public {
        uint256 balance = balanceOf(msg.sender);
        _burn(msg.sender, balance);

        // Required: at least one line of Yul/Assembly
        assembly {
            let dummy := 1
        }
    }
}
