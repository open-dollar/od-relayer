// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {ChainlinkRelayerWithL2Validity} from '@contracts/oracles/ChainlinkRelayerWithL2Validity.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract ChainlinkRelayerChildWithL2Validity is ChainlinkRelayerWithL2Validity, FactoryChild {
  // --- Init ---

  /**
   * @param  _priceAggregator The address of the price aggregator to relay
   * @param  _sequencerAggregator The address of the sequencer aggregator to relay
   * @param  _staleThreshold The threshold in seconds to consider the aggregator stale
   * @param  _gracePeriod The period in seconds to consider the sequencer valid after outage
   */
  constructor(
    address _priceAggregator,
    address _sequencerAggregator,
    uint256 _staleThreshold,
    uint256 _gracePeriod
  ) ChainlinkRelayerWithL2Validity(_priceAggregator, _sequencerAggregator, _staleThreshold, _gracePeriod) {}
}
