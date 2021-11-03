//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is ReentrancyGuard, Ownable {
  // ---- State variables ----
  ERC20 private stakingToken;
  ERC20 private rewardToken;

  uint private totalSupply;
  uint private currentReward;
  mapping (address => uint) private userToStakeAmount;
  mapping (address => uint) private userToStakeTimeReward;

  // ---- Constructor ----
  constructor(address _stakingToken, address _rewardToken) {
    stakingToken = ERC20(_stakingToken);
    rewardToken = ERC20(_rewardToken);
  }

  // ---- Views ----
  function getAccountReward(address account) private view returns (uint) {
    if (totalSupply == 0) {
      return 0;
    }

    uint _deposited = userToStakeAmount[account];
    uint _rewardAtDepositTime = userToStakeTimeReward[account];
    uint _resultingReward = _deposited * (currentReward - _rewardAtDepositTime); 

    return _resultingReward;
  }

  // ---- Externals ----
  function deposit(uint _amount) external nonReentrant {
    require(userToStakeAmount[msg.sender] == 0, "User already has deposit");

    userToStakeAmount[msg.sender] += _amount;
    userToStakeTimeReward[msg.sender] = currentReward;
    totalSupply += _amount;

    stakingToken.transferFrom(msg.sender, address(this), _amount);
  }

  function withdraw() external nonReentrant {
    uint _reward = getAccountReward(msg.sender);
    uint _deposited = userToStakeAmount[msg.sender];
    uint _withdrawAmount = _deposited + _reward;

    totalSupply -= _deposited;
    userToStakeAmount[msg.sender] = 0;

    stakingToken.transfer(msg.sender, _withdrawAmount);
  }

  function distribute(uint reward) external nonReentrant onlyOwner {
    // NOTE: needs proper implementation
    currentReward += reward / totalSupply;
  }

  function getAmountToWithdraw(address account) external view returns (uint) {
    uint _reward = getAccountReward(account);
    uint _deposited = userToStakeAmount[account];
    return _deposited + _reward;
  }
}


interface ERC20 {
  function transfer(address recipient, uint amount) external returns (bool);
  
  function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}