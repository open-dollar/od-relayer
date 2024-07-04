// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.24;

import '@pendle/contracts/oracles/PendlePYLpOracle.sol';
import '@pendle/contracts/interfaces/IPAllActionV3.sol';
import '@pendle/contracts/interfaces/IPMarket.sol';
import '@interfaces/oracles/IBaseOracle.sol';

/**
 * @title  PendleRelayer
 * @notice This contracts transforms a Pendle TWAP price feed into a standard IBaseOracle feed
 *
 */
contract PendleRelayer is IBaseOracle {
  using PendlePYOracleLib for IPMarket;
  using PendleLpOracleLib for IPMarket;

  IStandardizedYield public SY;
  IPPrincipalToken public PT;
  IPYieldToken public YT;

  IPMarket public market;
  PendlePYLpOracle public oracle;

  uint32 public twapDuration;

  constructor(address _market, address _oracle, uint32 _twapDuration) {
    require(_market != address(0) && _oracle != address(0), 'Invalid address');
    require(twapDuration != 0, 'Invalid TWAP duration');

    market = IPMarket(_market);
    oracle = PendlePYLpOracle(_oracle);
    twapDuration = _twapDuration;

    (SY, PT, YT) = market.readTokens();

    // test if oracle is ready
    (bool increaseCardinalityRequired,, bool oldestObservationSatisfied) = oracle.getOracleState(_market, _twapDuration);
    // It's required to call IPMarket(market).increaseObservationsCardinalityNext(cardinalityRequired) and wait
    // for at least the twapDuration, to allow data population.
    // also
    // It's necessary to wait for at least the twapDuration, to allow data population.
    require(!increaseCardinalityRequired && oldestObservationSatisfied, 'Oracle not ready');
  }

  function getResultWithValidity() external view returns (uint256 _resullt, bool _validity) {}

  function read() external view returns (uint256 _value) {}
  function symbol() external view returns (string memory _symbol) {}
}
