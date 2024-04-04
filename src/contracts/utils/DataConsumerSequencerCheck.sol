// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IChainlinkOracle} from '@interfaces/oracles/IChainlinkOracle.sol';

contract DataConsumerSequencerCheck {
  // --- Registry ---
  IChainlinkOracle public immutable SEQUENCER_UPTIME_FEED;

  // --- Data ---
  uint256 public immutable GRACE_PERIOD;

  /**
   * @param  _aggregator The address of the Chainlink aggregator
   * @param  _gracePeriod The threshold before accepting answers after an outage
   */
  constructor(address _aggregator, uint256 _gracePeriod) {
    require(_aggregator != address(0), 'NullAggregator');
    require(_gracePeriod != 0, 'NullGracePeriod');

    SEQUENCER_UPTIME_FEED = IChainlinkOracle(_aggregator);
    GRACE_PERIOD = _gracePeriod;
  }

  function getChainlinkDataFeedLatestAnswer() external view returns (int256) {}
}
