// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {Relayer} from '@contracts/oracles/Relayer.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract RelayerChild is Relayer, FactoryChild {
  // --- Init ---
  constructor(
    address _algebraV3Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) Relayer(_algebraV3Factory, _baseToken, _quoteToken, _quotePeriod) {}
}
