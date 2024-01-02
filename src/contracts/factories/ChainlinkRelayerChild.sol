// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {ChainlinkRelayer} from '@contracts/oracles/ChainlinkRelayer.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract ChainlinkRelayerChild is ChainlinkRelayer, FactoryChild {
  // --- Init ---

  /**
   * @param  _aggregator The address of the aggregator to relay
   * @param  _staleThreshold The threshold in seconds to consider the aggregator stale
   */
  constructor(address _aggregator, uint256 _staleThreshold) ChainlinkRelayer(_aggregator, _staleThreshold) {}
}
