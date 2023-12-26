// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {CamelotRelayerChild} from '@contracts/factories/CamelotRelayerChild.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';

contract CamelotRelayerFactory is Authorizable {
  uint256 public relayerId;

  // --- Events ---
  event NewAlgebraRelayer(address indexed _relayer, address _baseToken, address _quoteToken, uint32 _quotePeriod);

  // --- Data ---
  mapping(uint256 => address) public relayerById;

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Methods ---

  function deployAlgebraRelayer(
    address _algebraV3Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) external isAuthorized returns (IBaseOracle _relayer) {
    _relayer = IBaseOracle(address(new CamelotRelayerChild(_algebraV3Factory, _baseToken, _quoteToken, _quotePeriod)));
    relayerId++;
    relayerById[relayerId] = address(_relayer);
    emit NewAlgebraRelayer(address(_relayer), _baseToken, _quoteToken, _quotePeriod);
  }
}
