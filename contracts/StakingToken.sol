//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// /**
// * @title Staking Token (STK)
// * @author Alberto Cuesta Canada
// * @notice Implements a basic ERC20 staking token with incentive distribution.
// */
// contract StakingToken is ERC20, Ownable {
//    using SafeMath for uint256;

//    /**
//     * @notice The constructor for the Staking Token.
//     * @param _owner The address to receive all tokens on construction.
//     * @param _supply The amount of tokens to mint on construction.
//     */
//    constructor(address _owner, uint256 _supply) public
//    {
//       _mint(_owner, _supply);
//    }
// }

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 * Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/examples/SimpleToken.sol
 */
contract StakingToken is ERC20 {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}