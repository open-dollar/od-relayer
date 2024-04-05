// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IChainlinkOracle} from '@interfaces/oracles/IChainlinkOracle.sol';

contract DataConsumerSequencerCheck {
  uint256 public immutable GRACE_PERIOD;

  // --- Registry ---
  IChainlinkOracle public immutable SEQUENCER_UPTIME_FEED;

  /**
   * @param  _aggregator The address of the Chainlink aggregator
   * @param  _gracePeriod The threshold before accepting answers after an outage
   */
  constructor(address _aggregator, uint256 _gracePeriod) {
    require(_aggregator != address(0)); // error msg will not show from constructor revert
    require(_gracePeriod != 0);

    SEQUENCER_UPTIME_FEED = IChainlinkOracle(_aggregator);
    GRACE_PERIOD = _gracePeriod;
  }

  /// @notice return false for invalid sequencer, true for valid sequencer
  function getSequencerFeedValidation() public view returns (bool) {
    (uint256 _roundId, int256 _answer, uint256 _startedAt, uint256 _updatedAt, uint256 _answeredInRound) =
      SEQUENCER_UPTIME_FEED.latestRoundData();
    if (_answer != 0) return false;

    uint256 timeSinceOnline = block.timestamp - _startedAt;
    if (timeSinceOnline < GRACE_PERIOD) return false;
    else return true;
  }
}
