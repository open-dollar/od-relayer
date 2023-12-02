// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';

interface IAlgebraRelayer is IBaseOracle {
  /**
   * @notice Address of the AlgebraPair used to consult the TWAP
   */
  function algebraPool() external view returns (address _algebraPool);

  /**
   * @notice Address of the base token used to consult the quote
   */
  function baseToken() external view returns (address _baseToken);

  /**
   * @notice Address of the token used as a quote reference
   */
  function quoteToken() external view returns (address _quoteToken);

  /**
   * @notice The amount in wei of the base token used to consult the pool for a quote
   */
  function baseAmount() external view returns (uint128 _baseAmount);

  /**
   * @notice The multiplier used to convert the quote into an 18 decimals format
   */
  function multiplier() external view returns (uint256 _multiplier);

  /**
   * @notice The length of the TWAP used to consult the pool
   */
  function quotePeriod() external view returns (uint32 _quotePeriod);
}
