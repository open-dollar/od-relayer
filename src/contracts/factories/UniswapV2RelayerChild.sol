// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {UniswapV2Relayer} from '@contracts/oracles/UniswapV2Relayer.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract UniswapV2RelayerChild is UniswapV2Relayer, FactoryChild {
  // --- Init ---
  constructor(
    address _algebraV2Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) UniswapV2Relayer(_algebraV2Factory, _baseToken, _quoteToken, _quotePeriod) {}
}
