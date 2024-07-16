// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

import {IStandardizedYield} from '@interfaces/oracles/pendle/IStandardizedYield.sol';
import {IPPrincipalToken} from '@interfaces/oracles/pendle/IPPrincipalToken.sol';
import {IPYieldToken} from '@interfaces/oracles/pendle/IPYieldToken.sol';
import {IERC20Metadata} from '@interfaces/utils/IERC20Metadata.sol';

interface IPMarket is IERC20Metadata {
  function readTokens() external view returns (IStandardizedYield _SY, IPPrincipalToken _PT, IPYieldToken _YT);
}
