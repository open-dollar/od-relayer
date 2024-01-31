// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IChainlinkOracle} from '@interfaces/oracles/IChainlinkOracle.sol';

/**
 * @title  ChainlinkRelayer
 * @notice This contracts transforms a Chainlink price feed into a standard IBaseOracle feed
 *         It also verifies that the reading is new enough, compared to a staleThreshold
 */
contract ChainlinkRelayer {
  // --- Registry ---

  IChainlinkOracle public chainlinkFeed;

  // --- Data ---

  string public symbol;
  int256 public multiplier;
  uint256 public staleThreshold;

  // --- Init ---

  /**
   * @param  _aggregator The address of the Chainlink aggregator
   * @param  _staleThreshold The threshold after which the price is considered stale
   */
  constructor(address _aggregator, uint256 _staleThreshold) {
    require(_aggregator != address(0), 'NullAggregator');
    require(_staleThreshold != 0, 'NullStaleThreshold');

    staleThreshold = _staleThreshold;
    chainlinkFeed = IChainlinkOracle(_aggregator);

    multiplier = int256(18) - int256(uint256(chainlinkFeed.decimals()));
    symbol = chainlinkFeed.description();
  }

  function getResultWithValidity() external view returns (uint256 _result, bool _validity) {
    // Fetch values from Chainlink
    (, int256 _aggregatorResult,, uint256 _aggregatorTimestamp,) = chainlinkFeed.latestRoundData();

    // Parse the quote into 18 decimals format
    _result = _parseResult(_aggregatorResult);

    // Check if the price is valid
    _validity = _aggregatorResult > 0 && _isValidFeed(_aggregatorTimestamp);
  }

  function read() external view returns (uint256 _result) {
    // Fetch values from Chainlink
    (, int256 _aggregatorResult,, uint256 _aggregatorTimestamp,) = chainlinkFeed.latestRoundData();

    // Revert if price is invalid
    require(_aggregatorResult != 0 || _isValidFeed(_aggregatorTimestamp), 'InvalidPriceFeed');

    // Parse the quote into 18 decimals format
    _result = _parseResult(_aggregatorResult);
  }

  /// @notice Parses the result from the aggregator into 18 decimals format
  function _parseResult(int256 _chainlinkResult) internal view returns (uint256 _result) {
    if (multiplier > 0) {
      return uint256(_chainlinkResult) * (10 ** uint256(multiplier));
    } else if (multiplier < 0) {
      return uint256(_chainlinkResult) / (10 ** abs(multiplier));
    } else {
      return uint256(_chainlinkResult);
    }
  }

  /// @notice Checks if the feed is valid, considering the staleThreshold and the feed timestamp
  function _isValidFeed(uint256 _feedTimestamp) internal view returns (bool _valid) {
    uint256 _now = block.timestamp;
    if (_feedTimestamp > _now) return false;
    return _now - _feedTimestamp <= staleThreshold;
  }

  // @notice Return the absolute value of a signed integer as an unsigned integer
  function abs(int256 x) internal pure returns (uint256) {
    x >= 0 ? x : -x;
    return uint256(x);
  }
}
