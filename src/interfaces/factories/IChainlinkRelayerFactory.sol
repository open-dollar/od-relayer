// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';

interface IChainlinkRelayerFactory {
  // --- Events ---
  event NewChainlinkRelayer(address indexed _chainlinkRelayer, address _aggregator, uint256 _staleThreshold);
  event NewChainlinkRelayerWithL2Validity(
    address indexed _chainlinkRelayer,
    address _priceAggregator,
    address _sequencerAggregator,
    uint256 _staleThreshold,
    uint256 _gracePeriod
  );

  function deployChainlinkRelayer(address _aggregator, uint256 _staleThreshold) external returns (IBaseOracle _relayer);

  function deployChainlinkRelayerWithL2Validity(
    address _priceAggregator,
    address _sequencerAggregator,
    uint256 _staleThreshold,
    uint256 _gracePeriod
  ) external returns (IBaseOracle _chainlinkRelayer);
}
