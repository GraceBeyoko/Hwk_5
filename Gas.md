# ArtGalleryDAO — Governance Gas Cost & Incentive Analysis

This document provides an analysis of the gas cost for participating in governance actions within the ArtGalleryDAO protocol, including a proposed incentive model and an implementation outline for gas refunds.

The full gas report and snapshot can be found in gas-report.txt and .gas-snapshot respectively.
---

## Assumptions

- **Date:** April 29, 2025  
- **Current Gas Price**: 0.65 gwei  
- **ETH/USD Price**: $1,811  
- **Source Data**: Foundry Gas Snapshot from `GalleryTest`

---

## Voting Cost Breakdown

### `castVoteQuadratic`

- **Gas used**: 470,617  
- **ETH cost**:  
  `470,617 * 0.65 gwei = 0.0003059 ETH`  
- **USD equivalent**:  
  `0.0003059 ETH * $1,811 ≈ $0.55`

**Cost per vote**: ~$0.55

---

### Full Governance Lifecycle Cost

From token minting, delegation, and proposal creation, to voting, confirmation, and proposal execution, covered by `testFullProposalLifecycle()`.

- **Gas used**: 1,568,645  
- **ETH cost**:  
  `1,568,645 * 0.65 gwei = 0.0010196 ETH`  
- **USD equivalent**:  
  `0.0010196 ETH * $1,811 ≈ $1.85`

**End-to-end governance cycle cost**: ~$1.85

---

## Incentive Design Rationale

Although these costs seem low, they can become a barrier for:
- Small stakeholders
- High-frequency voters
- DAOs with low monetary value per decision

A rational user needs an expected benefit ≥ $2.00 (or over 2 times the gas costs) to justify participation. For small token holders, participation without incentives (like rewards or voting power impact) is economically irrational. Subsidies, gas rebates, or Layer-2 voting mechanisms may be necessary to encourage active participation. A refund mechanism in the DAO smart contract post-vote would also be useful.

### Suggested Incentive Ranges

| **Action**          | **Estimated Cost (USD)** | **Suggested Incentive (USD)** |
|---------------------|--------------------------|-------------------------------|
| Vote                | ~$0.55                   | $1.50 – $2.00                 |
| Full Proposal Flow  | ~$1.85                   | $5.00 – $6.00                 |

---
