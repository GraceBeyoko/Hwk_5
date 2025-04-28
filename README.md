# Arti DAO
 

 
This DAO has been created in the context of our Solidity class as part of Homework 5.
 

 
## What is the DAO about
 
Arti DAO is a decentralized autonomous organization focused on curating and showcasing emerging artists. It allows members to propose new artworks, vote on featured pieces, and update a virtual gallery through on-chain governance.
 

 
### Tools and Frameworks Used
 
- **Solidity**: Smart contract development
 
- **Foundry**: Testing and deployment
 
- **OpenZeppelin**: ERC721 contracts
 
- **Hardhat**: Optional for local testing
 

 
### Smart Contracts
 
1. **Curator NFT**: A non-transferable soulbound ERC721 token for members
 
2. **Governance Contract**: Manages proposals and voting
 
3. **Gallery Contract**: Records and displays featured artworks
 
4. **MultiSig Execution Mechanism**: Ensures safe execution of on-chain proposals
 

 
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
 
forge install #unnecessary?
 
forge build
 
forge test #have to write the test code

forge create src/GovernanceToken.sol:GovernanceToken $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
 
```
 

 
## Usage Example  (NOT SURE ABOUT THIS PART YET)
 
1. **Mint a Curator NFT.ERC**  
 
   - Deploy the `CuratorNFT` contract.
 
   - Call the `mint(address to)` function to mint a non-transferable curator token to a new member. (Delete that if ERC20)
 

 
2. **Propose a New Artwork**  
 
   - Through the `Governance` contract, call `createProposal(string memory description, string memory artworkURL)`.
 
   - Members holding a Curator NFT/tokens can create proposals.
 

 
3. **Vote on Proposals**  
 
   - Members vote using the `vote(uint256 proposalId, bool support)` function.
 
   - Voting results are automatically tallied after a set duration
 

 
4. **Execute Approved Proposals**  
 
   - Once a proposal passes, execute it to add the new artwork to the `Gallery` contract.
 

 
5. **View the Gallery**  
 
   - Query the `Gallery` contract to retrieve and display featured artworks.
 

 
## Members of the group and contact???
 
Grace B. - @GraceBeyoko <br> 
 
Arina A. - @rinaaro <br>

Jahad J. - @Jahad812 <br>
