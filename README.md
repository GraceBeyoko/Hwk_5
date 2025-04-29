# Arti DAO
 

 
This DAO has been created in the context of our Solidity class as part of Homework 5.
 

 
## What is the DAO about
 
Arti DAO is a decentralized autonomous organization focused on curating and showcasing art pieces in a virtual art gallery. It allows members to propose new artworks and update a virtual gallery through on-chain governance. Members can delegate their voting power, vote on proposals, and exit the DAO entirely by rage quitting, burning their tokens and resetting their governance status.
 

 
### Tools and Frameworks Used
 
- **Solidity**: Smart contract development
 
- **Foundry**: Testing and deployment
 
- **OpenZeppelin**: ERC20 contracts and standard utilities
 
- **Hardhat**: Optional for local testing
 

 
### Smart Contracts
 
1. **GovernanceToken**: An ERC20 token contract allowing delegation, voting, and rage quitting. Users can delegate their voting power, vote on proposals, and rage quit to burn their tokens and reset their status.
 
2. **Governance Contract**: Manages the creation of proposals and voting logic. Tracks proposals and their execution status based on community votes.

 
## Requirements to Run Locally (NOT SURE ABOUT THIS PART YET)
 
1. **Dependencies**:
 
   - Node.js (≥ 18.x)
 
   - Foundry (Install via `curl -L https://foundry.paradigm.xyz | bash`)
 
   - Alchemy or Infura API key for Sepolia testnet deployments
 

 
2. **Environment Setup**:
 
Create a `.env` file with the following:
 
```plaintext
 
PRIVATE_KEY=your-wallet-private-key
 
SEPOLIA_RPC_URL=your-sepolia-rpc-url
 
```
 
3. **Run the following command** : 
 
```plaintext
 
forge build
 
forge test #have to write the test code

forge create src/GovernanceToken.sol:GovernanceToken $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
 
```
 

 
## Usage Example 

1. **Deploy the GovernanceToken contract**

Deploy the `GovernanceToken` contract first to create the governance token.

2. **Deploy the Governance contract**

Deploy the `Governance contract`, passing in the address of the deployed `GovernanceToken`.

4. **Create a Proposal**

Call `createProposal(string calldata description)` on the `Governance` contract.

5. **Vote on Proposals**

Call `vote(uint256 proposalId, bool support)` on the `Governance` contract to vote.

6. **Execute Approved Proposals**

Once voting is completed and a proposal has passed, it can be executed.
 


 
## Members of the group and contact
 
Grace B. - @GraceBeyoko <br> 
 
Arina A. - @rinaaro <br>

Jahad J. - @Jahad812 <br>

Duy-Tung T. @duytungtony <br>
