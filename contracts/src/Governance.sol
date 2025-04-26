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
        uint40 voteStart;  // Packed timestamps
        uint40 voteEnd;
        ProposalState state;
        ProposalType pType;
        uint256 totalQuadraticVotes;
        uint256 yesVotes;
        uint256 noVotes;
        // Moved mapping to separate storage slot
    }

    mapping(uint256 => Proposal) public proposals;
    address[3] public multiSigSigners;
    mapping(uint256 => mapping(address => bool)) public proposalConfirmations;
    mapping(uint256 => mapping(address => bool)) public hasVoted;


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

    constructor(address _tokenAddress, address[3] memory _signers) {
        token = GovernanceToken(_tokenAddress);
        multiSigSigners = _signers;
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
        p.voteStart = uint40(start);
        p.voteEnd = uint40(end);
        p.state = ProposalState.Pending;
        p.pType = _pType;

        emit ProposalCreated(proposalId, msg.sender, _description, start, end, _pType);
    }

    // Add confirmation function (add check to only confirm once per user!)
    function confirmProposalExecution(uint256 proposalId) public {
        require(isMultiSigSigner(msg.sender), "Not authorized signer");
        require(proposals[proposalId].state == ProposalState.Succeeded, "Proposal not passed");
        
        proposalConfirmations[proposalId][msg.sender] = true;
    }

    /// @notice Quadratic vote (support = true for yes, false for no)
    function castVoteQuadratic(uint256 proposalId, bool support, uint256 amount) public {
        Proposal storage p = proposals[proposalId];
        
        if (p.state == ProposalState.Pending && block.timestamp >= p.voteStart) {
            p.state = ProposalState.Active;
        }

        require(block.timestamp >= p.voteStart && block.timestamp <= p.voteEnd, "Voting not active");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        hasVoted[proposalId][msg.sender] = true;

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

    // Modified executeProposal with multi-sig
    function executeProposal(uint256 proposalId) public {
        Proposal storage p = proposals[proposalId];
        require(p.state == ProposalState.Succeeded, "Proposal not passed");
        require(p.callData.length > 0, "No executable call");
        require(getConfirmationsCount(proposalId) >= 2, "Insufficient confirmations");

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

    /// @notice Yul implementation of Babylonian square root
    /// @dev Uses assembly for gas efficiency
    /// @param x The number to calculate square root of
    /// @return y The square root of x
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        assembly {
            // Handle edge case
            if iszero(x) {
                return(0, 0)
            }
            
            let z := add(div(x, 2), 1)
            y := x
            
            for {} lt(z, y) {} {
                y := z
                z := div(add(div(x, z), z), 2)
            }
        }
    }

    // Aux functions
    function isMultiSigSigner(address _address) private view returns (bool) {
        for (uint i = 0; i < 3; i++) {
            if (multiSigSigners[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function getConfirmationsCount(uint256 proposalId) private view returns (uint256) {
        uint256 count = 0;
        for (uint i = 0; i < 3; i++) {
            if (proposalConfirmations[proposalId][multiSigSigners[i]]) {
                count++;
            }
        }
        return count;
    }
}
