// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {ChainlinkRelayerChild} from '@contracts/factories/ChainlinkRelayerChild.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';

contract ChainlinkRelayerFactory is Authorizable {
  uint256 public relayerId;

  // --- Events ---
  event NewChainlinkRelayer(address indexed _chainlinkRelayer, address _aggregator, uint256 _staleThreshold);

  // --- Data ---
  mapping(uint256 => address) public relayerById;

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
}
