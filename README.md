# Arti DAO
 
This DAO has been created in the context of our Solidity class as part of Homework 5.
 
- [About](#about)
  - [Tools and Frameworks Used](#tools-and-frameworks-used)
  - [Smart Contracts](#smart-contracts)
- [Getting Started](#getting-started)
  - [Dependencies](#dependencies)
  - [Environment Setup](#environment-setup)
  - [Build](#build)
  - [Usage Example](#usage-example)
- [Group Members](#group-members)


## About
 
Arti DAO is a decentralized autonomous organization focused on curating and showcasing art pieces in a virtual art gallery. It allows members to propose new artworks and update a virtual gallery through on-chain governance. Members can delegate their voting power, vote on proposals, and exit the DAO entirely by rage quitting, burning their tokens and resetting their governance status.
 

### Tools and Frameworks Used
 
- **Solidity**: Smart contract development
 
- **Foundry**: Testing and deployment
 
- **OpenZeppelin**: ERC20 contracts and standard utilities
 
- **Hardhat**: Optional for local testing
 

 
### Smart Contracts
 
1. **ArtGalleryToken**: An ERC20 token contract allowing delegation, voting, and rage quitting. Users can delegate their voting power, vote on proposals, and rage quit to burn their tokens and reset their status.
   - Deployed at: `0x9b943bF963d9406960a0BbC7a4C62ca645730F73`
 
3. **Gallery**: Manages the creation of proposals and voting logic. Tracks proposals and their execution status based on community votes.
   - Deployed at: `0xD0445b4adB65491f61F3C1322776cca545d2d763`


## Getting Started
 
### Dependencies
 
   - Node.js (≥ 18.x)
   - Foundry (Install via `curl -L https://foundry.paradigm.xyz | bash`)
     ```plaintext
     - forge install foundry-rs/forge-std --no-commit
     - forge install OpenZeppelin/openzeppelin-contracts --no-commit
     ```
   - Alchemy, Infura, or Blast API key for Sepolia testnet deployments

 
### Environment Setup
 
Create a `.env` file with the following:
 
```plaintext
PRIVATE_KEY=your-wallet-private-key
 
SEPOLIA_RPC_URL=your-sepolia-rpc-url
```
 
### Build 
 
```plaintext
forge build
 
forge test
```
 

### Usage Example

1. **Deploy the contracts**

Using the Deploy.s.col script, deploy the `ArtGalleryToken` contract first to create the ArtGalleryToken (AGT) token, and then the `Gallery` contract, passing in the address of the deployed `ArtGalleryToken`.

```plaintext
forge script script/Deploy.s.sol:DeployScript --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

2. **Mint, Delegate, and Approve tokens**

Call `mint(address,uint256), delegate(address), and approve(address,uint256)` on the `ArtGalleryToken` contract.

```plaintext
cast send $ADDRESS(ArtGalleryToken) "mint(address,uint256)" $YOUR_ADDRESS $TOKEN_AMOUNT --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

cast send $ADDRESS(ArtGalleryToken) "delegate(address)" $YOUR_ADDRESS --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY

cast send $ADDRESS(ArtGalleryToken) "approve(address,uint256)" $ADDRESS(Gallery) $TOKEN_AMOUNT --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```
   
4. **Create a Proposal**

Call `createProposal(string calldata description)` on the `Gallery` contract.

```plaintext
cast send $ADDRESS(Gallery) "createProposal(string,bytes,uint8)" "$NAME" $CALLDATA $TYPE
```

5. **Vote on Proposals**

Call `vote(uint256 proposalId, bool support)` on the `Gallery` contract to vote.

```plaintext
cast send $ADDRESS(Gallery) "castVoteQuadratic(uint256,bool,uint256)" $PROPOSAL_ID $VOTE $TOKEN_AMOUNT --rpc-url $SEPOLIA_RPC_URL --private-key 
```

6. **Execute Approved Proposals**

Once voting is completed and a proposal has passed, it can be finalized by the owner, the execution confirmed by at least 2 of the signers, and then executed.

```plaintext
cast send $ADDRESS(Gallery) "finalizeProposal(uint256)" $PROPOSAL_ID --rpc-url $SEPOLIA_RPC_URL --private-key 

cast send $ADDRESS(Gallery) "confirmProposalExecution(uint256)" $PROPOSAL_ID --rpc-url $SEPOLIA_RPC_URL --private-key 

cast send $ADDRESS(Gallery) "executeProposal(uint256)" $PROPOSAL_ID --rpc-url $SEPOLIA_RPC_URL --private-key 
```

## Tests

As a way to ensure that the contracts works properly, we conducted several tests. 

#### For the `ArtGalleryToken` contract, here is a list of the tests conducted: 

- `testMint()`: This test verifies that after the mint function is called during setup, the user correctly holds exactly 100 tokens as expected.
- `testFuzz_Mint(uint256 amount)`: This fuzz test ensures that minting any amount of tokens between 1e18 and 1e24 properly updates the user’s balance without breaking.
- `testDelegate()`: This test checks that when a user delegates their voting power, the delegation is properly recorded and recognized by the system.
- `testRageQuit()`: This test ensures that when a user calls `rageQuit`, all of their tokens are burned and their balance correctly becomes zero afterward.
- `testFuzz_DelegateAndRageQuit(address delegatee, uint256 amount)`: This complex fuzz test checks that delegation succeeds or reverts for invalid addresses and that rage quitting properly burns all tokens afterwards.
- `testFullProposalLifecycle()`: This end-to-end test verifies that proposals can be created, voted on, finalized, confirmed by signers, and executed fully through their lifecycle.

#### For the `Gallery` contract, the following tests were performed: 

- `testCreateProposal`: Tests that a user with enough delegated tokens can successfully create a proposal and that the proposal’s state is set to "pending".
- `testCreateProposalWithInsufficientVotingPower`: Tests that a user with not enough voting power fails to create a proposal and triggers an "insufficient" voting power revert.
- `testCastVoteQuadratic`: Tests that a user can cast a quadratic vote on a proposal and verifies that the vote counts (yes, no, total) are updated correctly using the square root of the token amount.
- `testFuzzCreateProposal`: Verifies that a user can create a proposal with a random token amount between 1 and 100 tokens, ensuring the proposal moves to "pending" state.
- `testFuzzCastVoteQuadratic`: Checks that quadratic voting works correctly with random token amounts between 1 and 100 tokens, validating that the quadratic votes are computed accurately.
- `testFuzzProposalState`: After creating a proposal, it fast-forwards time with a random future timestamp and checks that the proposal correctly transitions to "active" after the voting delay.

 
## Group Members
 
Grace B. - @GraceBeyoko <br> 
 
Arina A. - @rinaaro <br>

Jahad J. - @Jahad812 <br>

Duy-Tung T. - @duytungtony <br>

Xuanzheng L. - @XuanzhengL <br>
