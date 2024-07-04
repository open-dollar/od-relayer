// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

import {IERC20Metadata} from '@interfaces/utils/IERC20Metadata.sol';

interface IPPrincipalToken is IERC20Metadata {
  function burnByYT(address user, uint256 amount) external;

  function mintByYT(address user, uint256 amount) external;

  function initialize(address _YT) external;

  function SY() external view returns (address);

  function YT() external view returns (address);

  function factory() external view returns (address);

  function expiry() external view returns (uint256);

  function isExpired() external view returns (bool);
}
