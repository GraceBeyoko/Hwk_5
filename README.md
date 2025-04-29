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
 
1. **ArtGalleryToken**: An ERC20 token contract allowing delegation, voting, and rage quitting. Users can delegate their voting power, vote on proposals, and rage quit to burn their tokens and reset their status.
 
2. **Gallery**: Manages the creation of proposals and voting logic. Tracks proposals and their execution status based on community votes.

 
## Requirements to Run Locally (NOT SURE ABOUT THIS PART YET)
 
1. **Dependencies**:
 
   - Node.js (≥ 18.x)
 
   - Foundry (Install via `curl -L https://foundry.paradigm.xyz | bash`)
     ```plaintext
     - forge install foundry-rs/forge-std --no-commit
     - forge install OpenZeppelin/openzeppelin-contracts --no-commit
     ```
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
 
forge test
```
 

## Usage Example -- check these

1. **Deploy the ArtGalleryToken contract**

Deploy the `ArtGalleryToken` contract first to create the ArtGalleryToken (AGT) token.

```plaintext
forge create src/ArtGalleryToken.sol:ArtGalleryToken --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
```

2. **Deploy the Gallery contract**

Deploy the `Gallery` contract, passing in the address of the deployed `ArtGalleryToken`.

4. **Create a Proposal**

Call `createProposal(string calldata description)` on the `Gallery` contract.

5. **Vote on Proposals**

Call `vote(uint256 proposalId, bool support)` on the `Gallery` contract to vote.

6. **Execute Approved Proposals**

Once voting is completed and a proposal has passed, it can be executed.
 


 
## Members of the group and contact
 
Grace B. - @GraceBeyoko <br> 
 
Arina A. - @rinaaro <br>

Jahad J. - @Jahad812 <br>

Duy-Tung T. - @duytungtony <br>

Xuanzheng L. - @XuanzhengL <br>
