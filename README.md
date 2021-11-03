# Basic Solidity staking contract

## General info
Users stake different quantities of ERC-20 token named “TKN”. Assume that an external caller would periodically transfer reward TKNs to a staking smart contract (no need to implement this logic). Rewards are proportionally distributed based on staked TKN.

Contract caller can:
* Stake
* Unstake (would be a plus if caller can unstake part of stake)
* See how many tokens each user can unstake
