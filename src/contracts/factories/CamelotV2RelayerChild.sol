// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {CamelotV2Relayer} from '@contracts/oracles/CamelotV2Relayer.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract CamelotV2RelayerChild is CamelotV2Relayer, FactoryChild {
  // --- Init ---
  constructor(
    address _camelotV2Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) CamelotV2Relayer(_camelotV2Factory, _baseToken, _quoteToken, _quotePeriod) {}
}
