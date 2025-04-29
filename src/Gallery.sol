// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title Gallery
 * @dev This contract implements DAO governance with:
 * - Proposal creation (Routine/Strategic)
 * - Quadratic voting
 * - Voting eligibility
 * - Voting lifecycle tracking
 * - Proposal success evaluation
 * - Weighted random dictatorship for strategic proposals
 */

import "./ArtGalleryToken.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract GalleryCore is ReentrancyGuard {
    ArtGalleryToken public token;

    uint256 public proposalCount;
    uint256 public constant PROPOSAL_THRESHOLD = 10 * 1e18;
    uint256 public constant VOTING_PERIOD = 5 days;
    uint256 public constant VOTING_DELAY = 1 days;
    uint256 public constant MIN_TOTAL_VOTES_FOR_PASS = 5;

    address private _contractAddress;

    enum ProposalState { Pending, Active, Succeeded, Defeated, Executed }
    enum ProposalType { Routine, Strategic }

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        bytes callData;
        uint40 voteStart;
        uint40 voteEnd;
        ProposalState state;
        ProposalType pType;
        uint256 totalQuadraticVotes;
        uint256 yesVotes;
        uint256 noVotes;
    }

    mapping(uint256 => Proposal) public proposals;
    address[3] public multiSigSigners;
    mapping(uint256 => mapping(address => bool)) public proposalConfirmations;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => uint256)) public voterDeposits;

    event ProposalCreated(
        uint256 indexed proposalId,
        address proposer,
        string description,
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
        token = ArtGalleryToken(_tokenAddress);
        multiSigSigners = _signers;
        _contractAddress = address(this);
    }

    function createProposal(
        string memory _description,
        bytes memory _callData,
        ProposalType _pType
    ) public {
        require(token.getVotes(msg.sender) > PROPOSAL_THRESHOLD - 1, "Insufficient voting power");

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

        emit ProposalCreated(proposalId, msg.sender, _description, _pType);
    }

    function confirmProposalExecution(uint256 proposalId) public {
        bool isSigner = false;
        for (uint i = 0; i < 3; ++i) {
            if (multiSigSigners[i] == msg.sender) {
                isSigner = true;
                break;
            }
        }
        require(isSigner, "Not authorized signer");
        require(!proposalConfirmations[proposalId][msg.sender], "Already confirmed");

        Proposal storage p = proposals[proposalId];
        require(p.state == ProposalState.Succeeded, "Proposal not passed");

        proposalConfirmations[proposalId][msg.sender] = true;
    }

    function castVoteQuadratic(uint256 proposalId, bool support, uint256 amount) public nonReentrant {
        Proposal storage p = proposals[proposalId];

        if (p.state == ProposalState.Pending && block.timestamp >= p.voteStart) {
            p.state = ProposalState.Active;
        }

        require(block.timestamp >= p.voteStart && block.timestamp <= p.voteEnd, "Voting not active");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        require(token.getVotes(msg.sender) > 0, "Not eligible");

        hasVoted[proposalId][msg.sender] = true;

        require(token.transferFrom(msg.sender, _contractAddress, amount), "Transfer failed");

        voterDeposits[proposalId][msg.sender] = amount;  // Track locked tokens

        uint256 sqrtVote = sqrt(amount);

        if (support) {
            p.yesVotes += sqrtVote;
        } else {
            p.noVotes += sqrtVote;
        }

        p.totalQuadraticVotes += sqrtVote;

        emit VoteCast(proposalId, msg.sender, support, amount, sqrtVote);
    }

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

    function executeProposal(uint256 proposalId) public nonReentrant {
        Proposal storage p = proposals[proposalId];
        require(p.state == ProposalState.Succeeded, "Proposal not passed");
        require(p.callData.length != 0, "No executable call");
        require(getConfirmationsCount(proposalId) > 1, "Insufficient confirmations");

        p.state = ProposalState.Executed;

        (bool success, ) = _contractAddress.call(p.callData);
        require(success, "Call execution failed");

        emit ProposalExecuted(proposalId);
    }

    function selectProposalRandomly(uint256[] memory proposalIds) public view returns (uint256) {
        uint256 totalWeight = 0;

        for (uint i = 0; i < proposalIds.length; ++i) {
            Proposal storage p = proposals[proposalIds[i]];
            require(p.pType == ProposalType.Strategic, "Not strategic");
            require(block.timestamp > p.voteEnd, "Voting not ended");
            require(p.state == ProposalState.Succeeded, "Not passed");
            totalWeight += p.yesVotes;
        }

        require(totalWeight > 0, "No votes");

        uint256 rand = uint256(keccak256(abi.encodePacked(block.prevrandao, msg.sender))) % totalWeight;

        uint256 cumulative = 0;
        for (uint i = 0; i < proposalIds.length; ++i) {
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

    function sqrt(uint256 x) public pure returns (uint256 y) {
        if (x == 0) return 0;

        uint256 z = (x + 1) / 2;
        y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function getConfirmationsCount(uint256 proposalId) private view returns (uint256) {
        uint256 count = 0;
        for (uint i = 0; i < 3; ++i) {
            if (proposalConfirmations[proposalId][multiSigSigners[i]]) {
                count++;
            }
        }
        return count;
    }

    /// @notice Refund tokens after voting has ended and proposal is finalized
    function claimRefund(uint256 proposalId) public nonReentrant {
        Proposal storage p = proposals[proposalId];
        require(block.timestamp > p.voteEnd, "Voting still active");
        require(p.state == ProposalState.Succeeded || p.state == ProposalState.Defeated, "Proposal not finalized");

        uint256 deposited = voterDeposits[proposalId][msg.sender];
        require(deposited > 0, "No refundable deposit");

        voterDeposits[proposalId][msg.sender] = 0;
        require(token.transfer(msg.sender, deposited), "Refund transfer failed");
    }
}
