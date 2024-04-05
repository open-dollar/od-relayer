// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IDataStorageOperator} from '@algebra-core/interfaces/IDataStorageOperator.sol';
import {DataStorageLibrary} from '@algebra-periphery/libraries/DataStorageLibrary.sol';

contract CamelotRelayer {
  int256 public immutable MULTIPLIER;
  uint32 public immutable QUOTE_PERIOD;
  uint128 public immutable BASE_AMOUNT;

  // --- Registry ---
  address public algebraPool;
  address public baseToken;
  address public quoteToken;

  // --- Data ---
  string public symbol;

  constructor(address _algebraV3Factory, address _baseToken, address _quoteToken, uint32 _quotePeriod) {
    algebraPool = IAlgebraFactory(_algebraV3Factory).poolByPair(_baseToken, _quoteToken);
    require(algebraPool != address(0));

    address _token0 = IAlgebraPool(algebraPool).token0();
    address _token1 = IAlgebraPool(algebraPool).token1();

    // The factory validates that both token0 and token1 are desired baseToken and quoteTokens
    if (_token0 == _baseToken) {
      baseToken = _token0;
      quoteToken = _token1;
    } else {
      baseToken = _token1;
      quoteToken = _token0;
    }

    BASE_AMOUNT = uint128(10 ** IERC20Metadata(_baseToken).decimals());
    MULTIPLIER = int256(18) - int256(uint256(IERC20Metadata(_quoteToken).decimals()));
    QUOTE_PERIOD = _quotePeriod;

    symbol = string(abi.encodePacked(IERC20Metadata(_baseToken).symbol(), ' / ', IERC20Metadata(_quoteToken).symbol()));
  }

  function getResultWithValidity() external view returns (uint256 _result, bool _validity) {
    // TODO: add catch if the pool doesn't have enough history - return false

    // Consult the query with a TWAP period of QUOTE_PERIOD
    int24 _arithmeticMeanTick = DataStorageLibrary.consult(algebraPool, QUOTE_PERIOD);
    // Calculate the quote amount
    uint256 _quoteAmount = DataStorageLibrary.getQuoteAtTick({
      tick: _arithmeticMeanTick,
      baseAmount: BASE_AMOUNT,
      baseToken: baseToken,
      quoteToken: quoteToken
    });
    // Process the quote result to 18 decimal quote
    _result = _parseResult(_quoteAmount);
    _validity = true;
  }

  function read() external view returns (uint256 _result) {
    // This call may revert with 'OLD!' if the pool doesn't have enough cardinality or initialized history
    int24 _arithmeticMeanTick = DataStorageLibrary.consult(algebraPool, QUOTE_PERIOD);
    uint256 _quoteAmount = DataStorageLibrary.getQuoteAtTick({
      tick: _arithmeticMeanTick,
      baseAmount: BASE_AMOUNT,
      baseToken: baseToken,
      quoteToken: quoteToken
    });
    _result = _parseResult(_quoteAmount);
  }

  function _parseResult(uint256 _quoteResult) internal view returns (uint256 _result) {
    if (MULTIPLIER == 0) {
      return _quoteResult;
    } else if (MULTIPLIER > 0) {
      return _quoteResult * (10 ** uint256(MULTIPLIER));
    } else {
      return _quoteResult / (10 ** _abs(MULTIPLIER));
    }
  }

  // @notice Return the absolute value of a signed integer as an unsigned integer
  function _abs(int256 x) internal pure returns (uint256) {
    x >= 0 ? x : -x;
    return uint256(x);
  }
}
