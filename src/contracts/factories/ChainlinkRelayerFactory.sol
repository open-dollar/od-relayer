// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {ChainlinkRelayerChild} from '@contracts/factories/ChainlinkRelayerChild.sol';
import {ChainlinkRelayerChildWithL2Validity} from '@contracts/factories/ChainlinkRelayerChildWithL2Validity.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';

contract ChainlinkRelayerFactory is Authorizable {
  uint256 public relayerId;
  uint256 public relayerWithL2ValidityId;

  // --- Events ---
  event NewChainlinkRelayer(address indexed _chainlinkRelayer, address _aggregator, uint256 _staleThreshold);
  event NewChainlinkRelayerWithL2Validity(
    address indexed _chainlinkRelayer,
    address _priceAggregator,
    address _sequencerAggregator,
    uint256 _staleThreshold,
    uint256 _gracePeriod
  );

  // --- Data ---
  mapping(uint256 => address) public relayerById;
  mapping(uint256 => address) public relayerWithL2ValidityById;

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Methods ---

  function deployChainlinkRelayer(
    address _aggregator,
    uint256 _staleThreshold
  ) external isAuthorized returns (IBaseOracle _chainlinkRelayer) {
    _chainlinkRelayer = IBaseOracle(address(new ChainlinkRelayerChild(_aggregator, _staleThreshold)));
    relayerId++;
    relayerById[relayerId] = address(_chainlinkRelayer);
    emit NewChainlinkRelayer(address(_chainlinkRelayer), _aggregator, _staleThreshold);
  }

  function deployChainlinkRelayerWithL2Validity(
    address _priceAggregator,
    address _sequencerAggregator,
    uint256 _staleThreshold,
    uint256 _gracePeriod
  ) external isAuthorized returns (IBaseOracle _chainlinkRelayer) {
    _chainlinkRelayer = IBaseOracle(
      address(
        new ChainlinkRelayerChildWithL2Validity(_priceAggregator, _sequencerAggregator, _staleThreshold, _gracePeriod)
      )
    );
    relayerWithL2ValidityId++;
    relayerWithL2ValidityById[relayerWithL2ValidityId] = address(_chainlinkRelayer);
    emit NewChainlinkRelayerWithL2Validity(
      address(_chainlinkRelayer), _priceAggregator, _sequencerAggregator, _staleThreshold, _gracePeriod
    );
  }
}
