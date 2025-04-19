// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Governance
 * @dev This contract implements DAO governance with:
 * - Proposal creation (Routine/Strategic)
 * - Quadratic voting
 * - Voting eligibility
 * - Voting lifecycle tracking
 * - Proposal success evaluation
 * - Weighted random dictatorship for strategic proposals
 */

import "./GovernanceToken.sol";

contract GovernanceCore {
    GovernanceToken public token;

    uint256 public proposalCount;
    uint256 public constant PROPOSAL_THRESHOLD = 10 * 1e18;
    uint256 public constant VOTING_PERIOD = 5 days;
    uint256 public constant VOTING_DELAY = 1 days;
    uint256 public constant MIN_TOTAL_VOTES_FOR_PASS = 5; // example threshold (sqrt votes)

    enum ProposalState { Pending, Active, Succeeded, Defeated, Executed }
    enum ProposalType { Routine, Strategic }

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        bytes callData;
        uint256 voteStart;
        uint256 voteEnd;
        ProposalState state;
        ProposalType pType;
        uint256 totalQuadraticVotes;
        uint256 yesVotes;
        uint256 noVotes;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(
        uint256 indexed proposalId,
        address proposer,
        string description,
        uint256 voteStart,
        uint256 voteEnd,
        ProposalType proposalType
    );

    event VoteCast(
        uint256 indexed proposalId,
        address voter,
        bool support,
        uint256 rawAmount,
        uint256 weightedVote
    );

    event ProposalExecuted(uint256 indexed proposalId);

    constructor(address _tokenAddress) {
        token = GovernanceToken(_tokenAddress);
    }

    /// @notice Create proposal (Routine or Strategic)
    function createProposal(
        string memory _description,
        bytes memory _callData,
        ProposalType _pType
    ) public {
        require(token.getVotes(msg.sender) >= PROPOSAL_THRESHOLD, "Insufficient voting power");

        uint256 proposalId = proposalCount++;
        uint256 start = block.timestamp + VOTING_DELAY;
        uint256 end = start + VOTING_PERIOD;

        Proposal storage p = proposals[proposalId];
        p.id = proposalId;
        p.proposer = msg.sender;
        p.description = _description;
        p.callData = _callData;
        p.voteStart = start;
        p.voteEnd = end;
        p.state = ProposalState.Pending;
        p.pType = _pType;

        emit ProposalCreated(proposalId, msg.sender, _description, start, end, _pType);
    }

    /// @notice Quadratic vote (support = true for yes, false for no)
    function castVoteQuadratic(uint256 proposalId, bool support, uint256 amount) public {
        Proposal storage p = proposals[proposalId];

        require(block.timestamp >= p.voteStart && block.timestamp <= p.voteEnd, "Voting not active");
        require(!p.hasVoted[msg.sender], "Already voted");

        // ✅ Eligibility: must have token votes
        require(token.getVotes(msg.sender) > 0, "Not eligible");

        // Lock or transfer token (simplified)
        token.transferFrom(msg.sender, address(this), amount);

        uint256 sqrtVote = sqrt(amount);

        if (support) {
            p.yesVotes += sqrtVote;
        } else {
            p.noVotes += sqrtVote;
        }

        p.totalQuadraticVotes += sqrtVote;
        p.hasVoted[msg.sender] = true;

        emit VoteCast(proposalId, msg.sender, support, amount, sqrtVote);
    }

    /// @notice Anyone can finalize proposal result after voting ends
    function finalizeProposal(uint256 proposalId) public {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp > p.voteEnd, "Voting not ended");
        require(p.state == ProposalState.Pending || p.state == ProposalState.Active, "Already finalized");

        if (
            p.yesVotes > p.noVotes &&
            p.totalQuadraticVotes >= MIN_TOTAL_VOTES_FOR_PASS
        ) {
            p.state = ProposalState.Succeeded;
        } else {
            p.state = ProposalState.Defeated;
        }
    }

    /// @notice Execute a passed proposal (Routine or Strategic)
    function executeProposal(uint256 proposalId) public {
        Proposal storage p = proposals[proposalId];
        require(p.state == ProposalState.Succeeded, "Proposal not passed");
        require(p.callData.length > 0, "No executable call");

        (bool success, ) = address(this).call(p.callData);
        require(success, "Call execution failed");

        p.state = ProposalState.Executed;

        emit ProposalExecuted(proposalId);
    }

    /// @notice Select winner among strategic proposals (weighted random)
    function selectProposalRandomly(uint256[] memory proposalIds) public view returns (uint256) {
        uint256 totalWeight = 0;

        for (uint i = 0; i < proposalIds.length; i++) {
            require(proposals[proposalIds[i]].pType == ProposalType.Strategic, "Not strategic");
            require(block.timestamp > proposals[proposalIds[i]].voteEnd, "Voting not ended");
            require(proposals[proposalIds[i]].state == ProposalState.Succeeded, "Not passed");
            totalWeight += proposals[proposalIds[i]].yesVotes;
        }

        require(totalWeight > 0, "No votes");

        uint256 rand = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), msg.sender))) % totalWeight;

        uint256 cumulative = 0;
        for (uint i = 0; i < proposalIds.length; i++) {
            cumulative += proposals[proposalIds[i]].yesVotes;
            if (rand < cumulative) {
                return proposalIds[i];
            }
        }

        revert("No proposal selected");
    }

    function getProposalState(uint256 proposalId) public view returns (ProposalState) {
        Proposal storage p = proposals[proposalId];

        if (p.state == ProposalState.Executed) return ProposalState.Executed;
        if (block.timestamp < p.voteStart) return ProposalState.Pending;
        if (block.timestamp <= p.voteEnd) return ProposalState.Active;
        return p.state;
    }

    /// @notice Babylonian integer square root
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = x / 2 + 1;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
