// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';

interface IRelayer is IBaseOracle {
  /**
   * @dev Address of the AlgebraPair used to consult the TWAP
   */
  function algebraPool() external view returns (address _algebraPool);

  /**
   * @dev Address of the base token used to consult the quote
   */
  function baseToken() external view returns (address _baseToken);

  /**
   * @dev Address of the token used as a quote reference
   */
  function quoteToken() external view returns (address _quoteToken);

  /**
   * @dev The amount in wei of the base token used to consult the pool for a quote
   */
  function baseAmount() external view returns (uint128 _baseAmount);

  /**
   * @dev The multiplier used to convert the quote into an 18 decimals format
   */
  function multiplier() external view returns (uint256 _multiplier);

  /**
   * @dev The length of the TWAP used to consult the pool
   */
  function quotePeriod() external view returns (uint32 _quotePeriod);
}
