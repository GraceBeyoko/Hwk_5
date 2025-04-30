# **Design** 

This document dives deeper into the technical side of our DAO while providing insight into our design choices and challenges.

## **Technical specification**

### 1. **ArtGalleryToken**

For our DAO, we choose to use the ERC20 token for simplicity purposes as well as capitalising on familiarity for both users and developers. Our first smart contract is the `ArtGalleryToken`. In our gallery context, this token is more than just a digital asset. In fact, it represents a member's right to participate in curating the gallery’s future. Users are allowed to mint new tokens which enable them to vote, delagate and exit the voting system. 

Here is a list of the key functions: 

- `mint(address to, uint256 amount)`: Issues new tokens, granting the recipient the ability to vote in gallery decisions.

- `delegate(address delegatee)`: Transfers one's voting power to another gallery member (can self delegate).

- `rageQuit()`: Burns the sender’s tokens and resets delegation/voting status.

### 2. **Gallery**

The second contract is the `Gallery`, which defines the management of our virtual art gallery. Through this contract, gallery members can propose and vote for an art piece. Participation is reserved for committed members (defined as having at least 10 delegated ArtGalleryToken). 

Each proposal must specify its type: either Routine or Strategic. Routine proposals are for minor decisions, such as small exhibitions, event logistics, etc. On the other hand, Strategic proposals deal with major decisions, such as acquisitions for the permanent collection, or redefinition of gallery themes. 

This classification determines whether the proposal will follow a standard success-vote model or trigger the alternative selection mechanism (weighted random dictatorship). In this case, after the voting period, instead of selecting the top-voted proposal, we apply a weighted random dictatorship. This means that each strategic proposal’s chance of being selected is proportional to the quadratic votes it received. This introduces an element of probabilistic fairness, honoring the community's broad support while avoiding the tyranny of numerical majorities — a method rooted in social choice theory. In particular, Gibbard’s (1977) analysis of strategy-proofness and the inevitability of dictatorial elements in deterministic voting, and Fishburn’s (1982) formalization of expected utility provide theoretical motivation for introducing randomness as a fairness-enhancing feature.

To avoid wealthy gallery members having too much power over voting mechanism (hence creating a bias in the votinng process), we opted for a qauadratic voting system to diminish the marginal influence of each additional token.

Each proposal includes voteStart and voteEnd timestamps, and its state is computed dynamically based on the current block timestamp. Proposals progress through a standard sequence: 

- Pending (before voting begins)
- Active (during the voting window)
- Succeeded or Defeated (based on vote results after voting closes)
- Executed (once an action is performed)

This temporal structure allows external contracts to interact with proposals according to their state without requiring manual state transitions.

Finally, a proposal must meet two conditions to be succesful. First, the number of yes votes must exceed the number of no votes. Second, the total number of quadratic votes cast must exceed a defined minimum threshold. This double condition ensures that proposals are not only net-positive in support but also sufficiently participated in. This addresses the common DAO problem of low-turnout approvals and encourages proposers to build consensus before submitting proposals.

Here is a list of the key functions: 

- `createProposal(string description, bytes calldata, uint8 type)`: Allows eligible members to propose a new decision.

- `castVoteQuadratic(uint256 proposalId, bool support, uint256 amount)`: Vote 'yes' or 'no' on an active proposal.

- `executeProposal(uint256 proposalId)`: Executes the proposal if conditions are met.

<img width="1174" alt="Screenshot 2025-05-01 at 01 15 45" src="https://github.com/user-attachments/assets/be879c0a-aa4d-46e7-93b6-1bfc0b347171" />


## **Reflection**

During development, we encountered a few technical and interpersonal challenges. On the technical side, we initially faced minor merge conflicts when combining our work, but these were quickly and easily resolved. Our major difficulty lay in optimizing the token contract to reduce gas usage and getting both contracts to function properly on Foundry. These issues took a considerable amount of time and iterations to solve. Managing the project as a group was also challenging, as we were all balancing internships and operating across different time zones, making scheduling and coordination difficult. 

Within the DevOps team, one of the hardest parts was reviewing and building upon each other's code. It required putting ourselves in the mindset of the designers, understanding why certain decisions were made, and constantly verifying whether the implementation still aligned with our overall project goals.

## **References**

Gibbard, A. (1977). Manipulation of voting schemes: A general result. Econometrica, 45(4), 665–681. https://doi.org/10.2307/1914083

Fishburn, P. C. (1982). The foundations of expected utility. Theory and Decision Library. Dordrecht: D. Reidel Publishing Company.

