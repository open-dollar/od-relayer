// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';

interface IRelayerFactory {
  // --- Events ---
  event NewAlgebraRelayer(address indexed _relayer, address _baseToken, address _quoteToken, uint32 _quotePeriod);

  function deployAlgebraRelayer(
    address _algebraV3Factory,
    address _baseToken,
    address _quoteToken,
    uint32 _quotePeriod
  ) external returns (IBaseOracle _relayer);
}
