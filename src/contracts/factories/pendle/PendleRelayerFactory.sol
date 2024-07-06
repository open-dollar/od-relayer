// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {PendlePtToSyRelayerChild} from '@contracts/factories/pendle/PendlePtToSyRelayerChild.sol';
import {PendleYtToSyRelayerChild} from '@contracts/factories/pendle/PendleYtToSyRelayerChild.sol';
import {PendleLpToSyRelayerChild} from '@contracts/factories/pendle/PendleLpToSyRelayerChild.sol';
import {Authorizable} from '@contracts/utils/Authorizable.sol';
import 'forge-std/console2.sol';

contract PendleRelayerFactory is Authorizable {
  uint256 public relayerId;

  // --- Events ---
  event NewPendlePtRelayer(address indexed _market, address _oracle, uint32 _twapDuration);
  event NewPendleYtRelayer(address indexed _market, address _oracle, uint32 _twapDuration);
  event NewPendleLpRelayer(address indexed _market, address _oracle, uint32 _twapDuration);

  // --- Data ---
  mapping(uint256 => address) public relayerById;

  // --- Init ---
  constructor() Authorizable(msg.sender) {}

  // --- Methods ---

  function deployPendlePtRelayer(
    address _market,
    address _oracle,
    uint32 _twapDuration
  ) external isAuthorized returns (IBaseOracle _pendlePtRelayerChild) {
    _pendlePtRelayerChild = IBaseOracle(address(new PendlePtToSyRelayerChild(_market, _oracle, _twapDuration)));
    relayerId++;
    relayerById[relayerId] = address(_pendlePtRelayerChild);
    emit NewPendlePtRelayer(address(_market), _oracle, _twapDuration);
  }

  function deployPendleYtRelayer(
    address _market,
    address _oracle,
    uint32 _twapDuration
  ) external isAuthorized returns (IBaseOracle _pendleYtRelayerChild) {
    _pendleYtRelayerChild = IBaseOracle(address(new PendleYtToSyRelayerChild(_market, _oracle, _twapDuration)));
    relayerId++;
    relayerById[relayerId] = address(_pendleYtRelayerChild);
    emit NewPendleYtRelayer(address(_market), _oracle, _twapDuration);
  }

  function deployPendleLpRelayer(
    address _market,
    address _oracle,
    uint32 _twapDuration
  ) external isAuthorized returns (IBaseOracle _pendleLpRelayerChild) {
    _pendleLpRelayerChild = IBaseOracle(address(new PendleLpToSyRelayerChild(_market, _oracle, _twapDuration)));
    relayerId++;
    relayerById[relayerId] = address(_pendleLpRelayerChild);
    emit NewPendleLpRelayer(address(_market), _oracle, _twapDuration);
  }
}
