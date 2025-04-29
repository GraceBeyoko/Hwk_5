# Slither Static Analysis Report

## Build Process
'forge clean' running (wd: /Users/rin/Desktop/Solidity/Hwk_5)
'forge config --json' running
'forge build --build-info --skip */test/** */script/** --force' running (wd: /Users/rin/Desktop/Solidity/Hwk_5)

## Summary Statistics
Compiled with Foundry
Total number of contracts in source files: 2
Number of contracts in dependencies: 30
Source lines of code (SLOC) in source files: 241
Source lines of code (SLOC) in dependencies: 2294
Number of  assembly lines: 0
Number of optimization issues: 2
Number of informational issues: 48
Number of low issues: 13
Number of medium issues: 12
Number of high issues: 1
ERCs: ERC2612, ERC20

## Contract Overview
+-----------------+-------------+---------------+--------------------+--------------+--------------------+
| Name            | # functions | ERCS          | ERC20 info         | Complex code | Features           |
+-----------------+-------------+---------------+--------------------+--------------+--------------------+
| ArtGalleryToken | 94          | ERC20,ERC2612 | ∞ Minting          | No           | Ecrecover          |
|                 |             |               | Approve Race Cond. |              | Assembly           |
|                 |             |               |                    |              |                    |
| GalleryCore     | 15          |               |                    | No           | Tokens interaction |
+-----------------+-------------+---------------+--------------------+--------------+--------------------+