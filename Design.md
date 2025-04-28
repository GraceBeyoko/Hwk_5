**Design** 

This document dives deeper into the technical side of our DAO while providing insight into our design choices and challenges.

**Technical specification**

1.**GovernanceToken**

For our DAO, we choose to only use two smart contracts for simplicity purpose and amiliarity for users and developers. The first one is the GovernanceToken which is a ERC20. We choose this standard because... The goal of this contract is to allow user to mint new tokens which enable them to vote, delagate and exit the voting system. 

Here is a list of the key function : 

- `mint(address to, uint256 amount)`: Mints new tokens.

- `delegate(address delegatee)`: Delegates voting power to a chosen address.

- `rageQuit()`: Burns sender’s tokens and resets delegation/voting status.

2.**Governance**

The second contract is a governance. This contract defines the whole mecanism of our DAO. Indeed, it is via this contract that users (gallery members) can propose and vote for an art piece. Each proposal must be submitted by an eligible token holder (defined as having at least 10 delegated governance tokens). Each proposal must specify its type: either Routine or Strategic. This classification determines whether the proposal will follow a standard success-vote model or trigger the alternative selection mechanism. ADD HERE WHY WE DECIDED TO HAVE TWO OPTIONS

To avoid wealthy gallery members to have too much power over voting mechanism (hence creating a bias in the votinng process), we opt for a qauadratic voting system to diminish the  the marginal influence of each additional token.

NOT SURE YET : Moreover, in the case of strategic proposals, the quadratic votes received by each proposal are interpreted not as definitive decisions but as probabilistic weights. That is, once the voting period ends, a Weighted Random Dictatorship mechanism is used to select a single proposal for execution, where each candidate's chance of being selected is proportional to its received quadratic vote total. This mechanism introduces a probabilistic fairness that respects community preference while preventing the deterministic domination of the highest-vote option (Gibbard, 1977; Fishburn, 1982).

Each proposal includes voteStart and voteEnd timestamps, and its state is computed dynamically based on the current block timestamp. 
Proposals progress through a standard sequence: Pending (before voting begins), Active (during the voting window), Succeeded or Defeated (based on vote results after voting closes), and Executed (once an action is performed). This temporal structure allows external contracts or front-end clients to interact with proposals according to their state without requiring manual state transitions.

roposal success criteria follow a two-part rule. First, the number of yes votes must exceed the number of no votes. Second, the total number of quadratic votes cast must exceed a defined minimum threshold. This double condition ensures that proposals are not only net-positive in support but also sufficiently participated in. This addresses the common DAO problem of low-turnout approvals and encourages proposers to build consensus before submitting proposals. ADD MORE EXPLANATION 

Here is a list of the key function : 

- `createProposal(string calldata description)`: Creates a new proposal.

- `vote(uint256 proposalId, bool support)`: Vote 'yes' or 'no' on an active proposal.

- `executeProposal(uint256 proposalId)`: Executes the proposal if conditions are met.

ADD DIAGRAM

**Reflection**

