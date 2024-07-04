// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {IStandardizedYield} from '@interfaces/oracles/pendle/IStandardizedYield.sol';
import {IPPrincipalToken} from '@interfaces/oracles/pendle/IPPrincipalToken.sol';
import {IPYieldToken} from '@interfaces/oracles/pendle/IPYieldToken.sol';

interface IPMarket {
  /**
   * required functions:
   *  getPtToSYRate
   *  readTokens()
   */
  function getPtToSyRate(address market, uint32 duration) external view returns (uint256);
  function readTokens() external view returns (IStandardizedYield _SY, IPPrincipalToken _PT, IPYieldToken _YT);
}
