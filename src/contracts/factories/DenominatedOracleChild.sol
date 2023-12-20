// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {DenominatedOracle} from '@contracts/oracles/DenominatedOracle.sol';
import {FactoryChild} from '@contracts/factories/FactoryChild.sol';

contract DenominatedOracleChild is DenominatedOracle, FactoryChild {
  // --- Init ---

  /**
   * @param  _priceSource Address of the price source
   * @param  _denominationPriceSource Address of the denomination price source
   * @param  _inverted Boolean indicating if the denomination quote should be inverted
   */
  constructor(
    IBaseOracle _priceSource,
    IBaseOracle _denominationPriceSource,
    bool _inverted
  ) DenominatedOracle(_priceSource, _denominationPriceSource, _inverted) {}
}
