// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract GovernanceToken is ERC20Votes {
    mapping(address => bool) private _hasDelegated;

    constructor() ERC20("GovernanceToken", "GT") ERC20Permit("GovernanceToken") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function getVotes(address account) public view returns (uint256) {
        return _getVotes(account);
    }

    function delegateOnce(address delegatee) external {
        require(!_hasDelegated[msg.sender], "Already delegated");
        require(getVotes(msg.sender) > 0, "No votes to delegate");
        _delegate(msg.sender, delegatee);
        _hasDelegated[msg.sender] = true;
    }

    function rageQuit() external {
        uint256 balance = balanceOf(msg.sender);
        require(balance > 0, "No tokens to burn");
        _burn(msg.sender, balance);
    }

    function sqrt(uint256 y) public pure returns (uint256 z) {
        assembly {
            let x := y
            z := 0
            switch x
            case 0 { z := 0 }
            default {
                z := 1
                let xx := x
                for { } gt(xx, 1) { } {
                    xx := div(add(xx, div(x, xx)), 2)
                    z := div(add(z, xx), 2)
                }
            }
        }
    }
}
