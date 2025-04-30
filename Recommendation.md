# Audit Evaluation

## Overall Security Evaluation

The Arti DAO project demonstrates a moderate level of security based on dynamic and static analyses. Two high-severity access control issues were detected alongside additional low-to-medium issues. A critical reentrancy pattern, revealed by static scanning (Slither), further elevates security concerns.

While gas optimization warnings and informational alerts were frequent, the key business risk centers around improper access controls and under-tested edge cases, which could lead to unauthorized actions or asset loss.

**Coverage Analysis:**
- Total coverage across contracts is 76.87%, indicating acceptable test coverage.
- Branch coverage (42%) is low, suggesting inadequate testing of edge cases, which is important for security testing.

**SolidityScan Summary Scores:**
- ArtGalleryToken.sol: 55.70
- Gallery.sol: 55.98

These scores indicate functional but non-production-grade security posture; security hardening is recommended before mainnet deployment.

## Top 3 Priority Issues to Address

### **1. Incorrect Access Control**  
**Contracts Affected:**  
- `ArtGalleryToken.sol`  
- `Gallery.sol`  

**Impact:**  
- Improper access control allows unauthorized minting, token burns, or role assignments, potentially enabling contract compromise or financial loss.

**Business Impact:**
- Average loss per exploit: ~$1M-20M+ (e.g., [Parity Wallet Hack](https://blog.openzeppelin.com/on-the-parity-wallet-multisig-hack-405a8c12e8f7))
- Remediation Time: 1–2 hours per function
- Cost of inaction: Total project compromise, legal liability, loss of user trust

**Recommendation:**  
- Ensure every sensitive function (minting, burning, fund withdrawals) has an `onlyOwner` or role-based modifier.
- Audit all mint, burn, role-change, and fund-transfer functions for misconfigurations.
- Implement a formal role-based access control system using OpenZeppelin’s `AccessControl` or `Ownable2Step`.


### **2. Reentrancy Risk in Voting Function**  

**Contract Affected:**   
- `Gallery.sol`  

**Impact:**
- The function `GalleryCore.castVoteQuadratic(uint256,bool,uint256)` contains external calls followed by state variable modifications; malicious actors could exploit this to repeatedly vote, disrupt proposal logic, or drain funds via reentrant cross-calls.
- External calls should be placed after state changes to avoid reentrancy attacks. This is especially critical as the contract has multiple interdependent proposals and voting functions that could be used in cross-function reentrancies.

**Business Impact:**
- Average loss per exploit: $500K–$3M (Reentrancy attacks like The DAO)
- Remediation Time: 1 hour (High recovery difficulty though)
- Recovery Difficulty: High (State corruption risk)

**Recommendation:**  
- Refactor `castVoteQuadratic` (and other similar functions) to follow the checks-effects-interactions pattern:
  - Perform state changes first
  - Execute external calls last

    
### **3. Missing Zero Address Validation**  
**Contract Affected:**  
- `Gallery.sol`  

**Impact:**  
- Critical operations (ownership, voting roles) could be accidentally assigned to the `0x0` address, permanently locking or bricking those flows.

**Why Top Priority (Business Perspective):**
- Cost of asset loss: $10K–$500K (Irretrievable loss of NFTs or tokens)
- Remediation Time: <30 minutes
- Recovery Difficulty: Often impossible due to blockchain immutability

**Recommendation:**  
- Add zero address checks (`require(address != address(0))`) to all ownership/role-related setters to prevent logic failures or locked roles.


## Vulnerability Risk Comparisons

| Issue                       | Severity | Avg Exploit Cost | Fix Time | Business Risk                          |
|-----------------------------|----------|------------------|----------|----------------------------------------|
| Incorrect Access Control    | Critical | $1M–$20M         | ~2 hrs   | Treasury compromise, contract takeover |
| Reentrancy (Voting)         | High     | $500K–$3M        | ~1 hr    | Disrupted DAO logic, fund siphoning    |
| Missing Zero Address Checks | Medium   | $10K–$500K       | <30 min  | Permanent logic failure or bricking    |

