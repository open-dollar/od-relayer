// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {IPMarket} from '@interfaces/oracles/pendle/IPMarket.sol';
import {IPOracle} from '@interfaces/oracles/pendle/IPOracle.sol';
import {IStandardizedYield} from '@interfaces/oracles/pendle/IStandardizedYield.sol';
import {IPPrincipalToken} from '@interfaces/oracles/pendle/IPPrincipalToken.sol';
import {IPYieldToken} from '@interfaces/oracles/pendle/IPYieldToken.sol';

interface IPendleRelayer is IBaseOracle {
  function twapDuration() external view returns (uint32);
  function market() external view returns (IPMarket);
  function oracle() external view returns (IPOracle);
  function SY() external view returns (IStandardizedYield);
  function PT() external view returns (IPPrincipalToken);
  function YT() external view returns (IPYieldToken);
}
