// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ArtGalleryToken is ERC20, ERC20Votes, ERC20Permit, Ownable {
    mapping(address => bool) private _hasDelegated;
    mapping(address => bool) private _hasVoted;

    // Custom errors for gas-optimized reverts
    error ZeroAddress();
    error AlreadyDelegated();
    error AlreadyVoted();
    error NoTokensToRageQuit();

    // Event emissions for critical actions
    event TokensMinted(address indexed to, uint256 amount);
    event Delegated(address indexed delegatee, address indexed delegator);
    event RageQuit(address indexed account, uint256 amountBurned);
    event ContractDeployed(address indexed deployer);

    constructor() 
        ERC20("ArtGalleryToken", "AGT")
        ERC20Votes()
        ERC20Permit("ArtGalleryToken")
        Ownable(msg.sender)  
    {
        emit ContractDeployed(msg.sender);
    }

    // Minting tokens with custom error handling
    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // Delegation with custom error handling
    function delegate(address delegatee) public override {
        if (delegatee == address(0)) revert ZeroAddress();
        if (_hasDelegated[msg.sender]) revert AlreadyDelegated();
        if (_hasVoted[msg.sender]) revert AlreadyVoted();

        super.delegate(delegatee);  // Call to base contract's delegate function to update the delegatee in ERC20Votes
        _hasDelegated[msg.sender] = true;  // Track that the sender has delegated
        emit Delegated(delegatee, msg.sender);
    }

    // RageQuit function with event emission and gas optimization
    function rageQuit() external {
        uint256 balance = balanceOf(msg.sender);
        if (balance == 0) revert NoTokensToRageQuit();

        _burn(msg.sender, balance);  // Burn all tokens of the sender
        emit RageQuit(msg.sender, balance);

        delete _hasDelegated[msg.sender];  // Reset delegation state
        delete _hasVoted[msg.sender];  // Reset voting state
    }

    // Override the `_update` function to resolve the conflict
    function _update(address from, address to, uint256 value) internal virtual override(ERC20Votes, ERC20) {
        super._update(from, to, value);  // Ensure the base contract update is called
    }

    // Override nonces to resolve the conflict
    function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
        return super.nonces(owner);  // Return the nonce using the base contract logic
    }

    // Square root function with inline assembly
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

    // Override transferOwnership with custom error handling
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        super.transferOwnership(newOwner);  // Call the base contract's transferOwnership
    }

    // Getter function for hasDelegated mapping
    function hasDelegated(address account) public view returns (bool) {
        return _hasDelegated[account];  // Return whether the account has delegated or not
    }
}
