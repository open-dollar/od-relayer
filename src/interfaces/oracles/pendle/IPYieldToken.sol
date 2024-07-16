// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

import {IERC20Metadata} from '@interfaces/utils/IERC20Metadata.sol';

interface IRewardManager {
  function userReward(address token, address user) external view returns (uint128 index, uint128 accrued);
}

interface IPInterestManagerYT {
  event CollectInterestFee(uint256 amountInterestFee);

  function userInterest(address user) external view returns (uint128 lastPYIndex, uint128 accruedInterest);
}

interface IPYieldToken is IERC20Metadata, IRewardManager, IPInterestManagerYT {
  event NewInterestIndex(uint256 indexed newIndex);

  event Mint(
    address indexed caller,
    address indexed receiverPT,
    address indexed receiverYT,
    uint256 amountSyToMint,
    uint256 amountPYOut
  );

  event Burn(address indexed caller, address indexed receiver, uint256 amountPYToRedeem, uint256 amountSyOut);

  event RedeemRewards(address indexed user, uint256[] amountRewardsOut);

  event RedeemInterest(address indexed user, uint256 interestOut);

  event CollectRewardFee(address indexed rewardToken, uint256 amountRewardFee);

  function mintPY(address receiverPT, address receiverYT) external returns (uint256 amountPYOut);

  function redeemPY(address receiver) external returns (uint256 amountSyOut);

  function redeemPYMulti(
    address[] calldata receivers,
    uint256[] calldata amountPYToRedeems
  ) external returns (uint256[] memory amountSyOuts);

  function redeemDueInterestAndRewards(
    address user,
    bool redeemInterest,
    bool redeemRewards
  ) external returns (uint256 interestOut, uint256[] memory rewardsOut);

  function rewardIndexesCurrent() external returns (uint256[] memory);

  function pyIndexCurrent() external returns (uint256);

  function pyIndexStored() external view returns (uint256);

  function getRewardTokens() external view returns (address[] memory);

  function SY() external view returns (address);

  function PT() external view returns (address);

  function factory() external view returns (address);

  function expiry() external view returns (uint256);

  function isExpired() external view returns (bool);

  function doCacheIndexSameBlock() external view returns (bool);

  function pyIndexLastUpdatedBlock() external view returns (uint128);
}
