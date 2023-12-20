// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {EnumerableSet} from '@openzeppelin/contracts/utils/EnumerableSet.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {ChainlinkRelayerChild} from '@contracts/factories/ChainlinkRelayerChild.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';

contract ChainlinkRelayerFactory is Authorizable {
  using EnumerableSet for EnumerableSet.AddressSet;

  uint256 public relayerId;

  // --- Events ---
  event NewChainlinkRelayer(address indexed _chainlinkRelayer, address _aggregator, uint256 _staleThreshold);

  mapping(uint256 => address) public relayerById;

  // --- Data ---
  EnumerableSet.AddressSet internal _chainlinkRelayers;

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Methods ---

  function deployChainlinkRelayer(
    address _aggregator,
    uint256 _staleThreshold
  ) external isAuthorized returns (IBaseOracle _chainlinkRelayer) {
    _chainlinkRelayer = IBaseOracle(address(new ChainlinkRelayerChild(_aggregator, _staleThreshold)));
    _chainlinkRelayers.add(address(_chainlinkRelayer));
    relayerId++;
    relayerById[relayerId] = address(_chainlinkRelayer);
    emit NewChainlinkRelayer(address(_chainlinkRelayer), _aggregator, _staleThreshold);
  }
}
