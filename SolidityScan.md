SolidityScan Report
GovernanceToken.sol

File: Hwk_5-1745770314247/contracts/src/GovernanceToken.sol
Issues
# | Name | Severity | Confidence | Description | Remediation
1 | Incorrect Access Control | Critical | 1 | Missing access control modifier on sensitive function. | Not Available
2 | Outdated Compiler Version | Low | 2 | Using outdated compiler version with potential known issues. | Not Available
3 | Use Ownable2Step | Low | 0 | Safer ownership transfer recommended. | Not Available
4 | Use of Floating Pragma | Low | 2 | Floating pragma used; not considered safe. | Not Available
5 | Missing Events | Low | 1 | Events missing on some functions, limiting off-chain traceability. | Not Available
6 | In-line Assembly Detected | Informational | 2 | Inline assembly bypasses safety features. | Not Available
7 | Missing Underscore in Naming Variables | Informational | 0 | Naming conventions for internal/private variables not followed. | Not Available
8 | Name Mapping Parameters | Informational | 0 | Naming mapping parameters for clarity introduced in Solidity 0.8.18. | Not Available
9 | Revert Statements and DoS | Informational | 0 | Improper revert use can lead to denial-of-service vulnerabilities. | Not Available
10 | Define Constructor as Payable | Gas | 0 | Saves gas during deployment. | Line 24:31
11 | Reverting Functions Can Be Payable | Gas | 0 | Payable modifier on reverting functions can reduce gas. | Line 34:38
12 | Optimizing Address ID Mapping | Gas | 0 | Combine mappings using struct to save storage/gas. | Lines 9:9, 10:10
13 | Internal Functions Never Used | Gas | 0 | Remove unused internal functions. | Lines 74:83

Scan Summary:

    Lines Analyzed: 79

    Scan Score: 55.70

    Issue Distribution: { "critical": 2, "gas": 5, "high": 0, "informational": 10, "low": 5, "medium": 0 }

Governance.sol

File: Hwk_5-1745770314247/contracts/src/Governance.sol
Issues
# | Name | Severity | Confidence | Description | Remediation
1 | Incorrect Access Control | Critical | 1 | Missing access control modifier. | Not Available
2 | Block.number Inconsistencies | Medium | 0 | L2 vs. L1 block number discrepancies can affect timing. | Not Available
3 | Account Existence Check for Low-level Calls | Medium | 0 | Low-level calls do not verify if address exists. | Not Available
4 | Weak PRNG | Low | 0 | Use of predictable randomness sources like block.timestamp. | Not Available
5 | Event-based Reentrancy | Low | 1 | Events emitted after external calls can be risky. | Not Available
6 | Outdated Compiler Version | Low | 2 | Compiler version may have known bugs. | Not Available
7 | Missing Events | Low | 1 | Functions lack proper events. | Not Available
8 | Use of Floating Pragma | Low | 2 | Floating pragma can be compiled with unsafe versions. | Not Available
9 | Missing Zero Address Validation | Low | 2 | Lack of zero address checks. | Not Available
10 | Return Inside Loop | Informational | 2 | Early return in loop causes incomplete execution. | Not Available
11 | Block Values as Time Proxy | Informational | 1 | Unreliable time representation using block values. | Not Available
12 | In-line Assembly Detected | Informational | 2 | Unsafe and bypasses Solidity safety. | Not Available
13 | Missing Underscore in Naming Variables | Informational | 0 | Coding style for internal/private vars not followed. | Not Available
14 | If-statement Refactoring | Informational | 0 | Could be refactored into ternary operators. | Not Available
15 | Name Mapping Parameters | Informational | 0 | Mapping parameter naming improves clarity. | Not Available
16 | abi.encodePacked May Cause Collision | Informational | 2 | Risk of hash collisions. | Not Available
17 | Storage Variable Caching | Gas | 0 | Use memory caching to reduce SLOAD costs. | Lines 120:148, 181:204
18 | Cheaper Conditional Operators | Gas | 0 | Use != 0 instead of > 0 for efficiency. | Lines 132:132, 191:191
19 | Public Constants Can Be Private | Gas | 2 | Reduce cost by setting constants to private. | Lines 21:24
20 | Define Constructor as Payable | Gas | 0 | Saves gas during deployment. | Lines 69:74
21 | Optimizing Address ID Mapping | Gas | 0 | Use structs to reduce storage cost. | Lines 49:50
22 | Named Return Saves Gas | Gas | 0 | Named returns are cheaper. | Lines 236:245
23 | Cheaper Inequalities in if() | Gas | 1 | Use non-strict inequality to save gas. | Lines 157:157, 210:210
24 | Array Length Caching | Gas | 2 | Cache array length in loops to reduce reads. | Lines 184:189, 196:201
25 | Struct Packing for Gas Optimization | Gas | 0 | Reorder struct members to reduce padding. | Lines 32:45
26 | Cheaper Inequality in require() | Gas | 1 | Use strict comparison for cost savings. | Line 127:127
27 | Splitting require() Statements | Gas | 1 | Separate require() calls for better deployment gas. | Line 127:127
28 | Use Custom Errors | Gas | 2 | Use error() instead of revert() for gas efficiency. | Line 203:203

Scan Summary:

    Lines Analyzed: 200

    Scan Score: 59.00

    Issue Distribution: { "critical": 5, "gas": 20, "high": 0, "informational": 17, "low": 7, "medium": 2 }