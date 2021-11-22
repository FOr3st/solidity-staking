//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is ReentrancyGuard, Ownable {
  // ---- State variables ----
  ERC20 private stakingToken;

  uint private totalSupply;
  uint private currentReward;
  mapping (address => uint) private userToStakeAmount;
  mapping (address => uint) private userToStakeTimeReward;

  // ---- Constructor ----
  constructor(address _stakingToken) {
    stakingToken = ERC20(_stakingToken);
  }

  // ---- Views ----
  function getAccountReward(address _account) private view returns (uint) {
    if (totalSupply == 0) {
      return 0;
    }

    uint _deposited = userToStakeAmount[_account];
    uint _rewardAtDepositTime = userToStakeTimeReward[_account];
    uint _resultingReward = _deposited * (currentReward - _rewardAtDepositTime) / 1e18; 

    return _resultingReward;
  }

  // ---- Externals ----
  function deposit(uint _amount) external nonReentrant {
    require(_amount > 0, "Can't stake 0");
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

  function distribute(uint _reward) external nonReentrant onlyOwner {
    // NOTE: needs proper implementation
    require(totalSupply > 0, "No stakers to distribute reward");

    currentReward += _reward * 1e18 / totalSupply;
  }

  function getAmountToWithdraw(address _account) external view returns (uint) {
    uint _reward = getAccountReward(_account);
    uint _deposited = userToStakeAmount[_account];
    return _deposited + _reward;
  }
}


interface ERC20 {
  function transfer(address recipient, uint amount) external returns (bool);
  
  function transferFrom(address sender, address recipient, uint amount) external returns (bool);
}