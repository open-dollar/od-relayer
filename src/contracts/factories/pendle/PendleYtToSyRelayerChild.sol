// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {PendleYtToSyRelayer} from '@contracts/oracles/pendle/PendleYtToSyRelayer.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract PendleYtToSyRelayerChild is PendleYtToSyRelayer, FactoryChild {
  // --- Init ---

  /**
   * @param  _market The address pendle market
   * @param  _oracle The address of the pendle oracle
   * @param _twapDuration the amount in seconds of the desired twap observations (recommended 900s)
   */
  constructor(
    address _market,
    address _oracle,
    uint32 _twapDuration
  ) PendleYtToSyRelayer(_market, _oracle, _twapDuration) {}
}
