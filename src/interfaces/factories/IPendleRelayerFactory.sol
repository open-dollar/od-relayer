// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {IAuthorizable} from '@interfaces/utils/IAuthorizable.sol';

interface IPendleRelayerFactory is IAuthorizable {
  // --- Events ---
  event NewPendlePtRelayer(address indexed _market, address _oracle, uint32 _twapDuration);
  event NewPendleYtRelayer(address indexed _market, address _oracle, uint32 _twapDuration);
  event NewPendleLpRelayer(address indexed _market, address _oracle, uint32 _twapDuration);

  // --- Methods ---
  function relayerId() external view returns (uint256);

  function deployPendlePtRelayer(
    address _market,
    address _oracle,
    uint32 _twapDuration
  ) external returns (IBaseOracle _pendlePtRelayerChild);

  function deployPendleYtRelayer(
    address _market,
    address _oracle,
    uint32 _twapDuration
  ) external returns (IBaseOracle _pendleYtRelayerChild);

  function deployPendleLpRelayer(
    address _market,
    address _oracle,
    uint32 _twapDuration
  ) external returns (IBaseOracle _pendleLpRelayerChild);
}
