// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {CamelotRelayer} from '@contracts/oracles/CamelotRelayer.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract CamelotRelayerChild is CamelotRelayer, FactoryChild {
  // --- Init ---
  constructor(
    address _algebraV3Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) CamelotRelayer(_algebraV3Factory, _baseToken, _quoteToken, _quotePeriod) {}
}
