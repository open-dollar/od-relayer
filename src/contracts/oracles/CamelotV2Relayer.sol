// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import '@cryptoalgebra/v1.9-core/contracts/libraries/FullMath.sol';
import '@cryptoalgebra/v1.9-core/contracts/libraries/LowGasSafeMath.sol';

import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {ICamelotFactory} from '@interfaces/camelot/ICamelotFactory.sol';
import {ICamelotPair} from '@interfaces/camelot/ICamelotPair.sol';

contract CamelotV2Relayer {
  int256 public immutable MULTIPLIER;
  uint32 public immutable QUOTE_PERIOD;
  uint128 public immutable BASE_AMOUNT;

  // --- Registry ---
  address public camelotV2Pair;
  address public baseToken;
  address public quoteToken;

  // --- Data ---
  string public symbol;

  // TWAP state variables
  uint256[] public priceHistory; // Array to store historical prices
  uint256[] public timestampHistory; // Array to store corresponding timestamps
  uint256 public constant MAX_HISTORY_LENGTH = 100; // Maximum number of price entries to store

  constructor(address _camelotV2Factory, address _baseToken, address _quoteToken, uint32 _quotePeriod) {
    camelotV2Pair = ICamelotFactory(_camelotV2Factory).getPair(_baseToken, _quoteToken);
    require(camelotV2Pair != address(0));
    require(ICamelotPair(camelotV2Pair).stableSwap() == false);

    uint112 reserve0;
    uint112 reserve1;
    (reserve0, reserve1,,) = ICamelotPair(camelotV2Pair).getReserves();
    require(reserve0 != 0 && reserve1 != 0, 'CamelotV2Relayer: INSUFFICIENT_RESERVES');

    address _token0 = ICamelotPair(camelotV2Pair).token0();
    address _token1 = ICamelotPair(camelotV2Pair).token1();

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
    uint256 price = getTWAP(QUOTE_PERIOD);

    _result = _parseResult(price);
    _validity = true;
  }

  function read() external view returns (uint256 _result) {
    _result = getCurrentPrice();
  }

  function getCurrentPrice() internal view returns (uint256) {
    uint112 _reserve0;
    uint112 _reserve1;
    (_reserve0, _reserve1,,) = ICamelotPair(camelotV2Pair).getReserves();

    require(_reserve0 > 0 && _reserve1 > 0, 'CamelotPair: INSUFFICIENT_RESERVES');

    uint256 price;
    if (baseToken == ICamelotPair(camelotV2Pair).token0()) {
      // baseToken is token0, quoteToken is token1
      price = FullMath.mulDiv(_reserve1, BASE_AMOUNT, _reserve0);
    } else {
      // baseToken is token1, quoteToken is token0
      price = FullMath.mulDiv(_reserve0, BASE_AMOUNT, _reserve1);
    }

    return _parseResult(price);
  }

  // Function to calculate the TWAP
  function getTWAP(uint32 period) internal view returns (uint256 twap) {
    uint256 totalWeightedPrice = 0;
    uint256 totalTime = 0;

    for (uint256 i = 0; i < priceHistory.length; i++) {
      if (block.timestamp - timestampHistory[i] <= period) {
        totalWeightedPrice += priceHistory[i] * (block.timestamp - timestampHistory[i]);
        totalTime += (block.timestamp - timestampHistory[i]);
      }
    }

    require(totalTime > 0, 'No price data available for the specified period');
    twap = totalWeightedPrice / totalTime;
  }

  function updatePrice() external {
    uint256 currentPrice = getCurrentPrice();
    uint256 currentTime = block.timestamp;

    priceHistory.push(currentPrice);
    timestampHistory.push(currentTime);

    if (priceHistory.length > MAX_HISTORY_LENGTH) {
      priceHistory.pop();
      timestampHistory.pop();
    }
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
