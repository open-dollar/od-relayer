// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {ChainlinkRelayer} from '@contracts/oracles/ChainlinkRelayer.sol';
import {DataConsumerSequencerCheck} from '@contracts/utils/DataConsumerSequencerCheck.sol';

contract ChainlinkRelayerWithL2Validity is ChainlinkRelayer, DataConsumerSequencerCheck {
  constructor(
    address _priceAggregator,
    address _sequencerAggregator,
    uint256 _staleThreshold,
    uint256 _gracePeriod
  ) ChainlinkRelayer(_priceAggregator, _staleThreshold) DataConsumerSequencerCheck(_sequencerAggregator, _gracePeriod) {}

  function getResultWithValidity() public view override returns (uint256 _result, bool _validity) {
    require(getSequencerFeedValidation(), 'SequencerDown');
    super.getResultWithValidity();
  }

  function read() public view override returns (uint256 _result) {
    require(getSequencerFeedValidation(), 'SequencerDown');
    _result = super.read();
  }
}
