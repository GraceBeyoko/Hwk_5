// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/access/Ownable.sol";

contract GovernanceToken is ERC20Votes, Ownable {
    mapping(address => bool) public hasDelegated;
    mapping(address => bool) public hasVoted;

    constructor() 
        ERC20("GovernanceToken", "GOV") 
        ERC20Permit("GovernanceToken") 
    {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function delegate(address delegatee) public override {
        require(!hasDelegated[msg.sender], "Already delegated");
        require(!hasVoted[msg.sender], "Already voted");
        super.delegate(delegatee);
        hasDelegated[msg.sender] = true;
    }

    function rageQuit() external {
        uint256 balance = balanceOf(msg.sender);
        require(balance > 0, "No tokens to rage quit");
        _burn(msg.sender, balance);

        // Clear delegation and voting record
        hasDelegated[msg.sender] = false;
        hasVoted[msg.sender] = false;
    }

    // Yul Assembly - functional sqrt
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        assembly {
            let z := add(div(x, 2), 1)
            y := x
            for { } lt(z, y) { } {
                y := z
                z := div(add(div(x, z), z), 2)
            }
        }
    }
}
