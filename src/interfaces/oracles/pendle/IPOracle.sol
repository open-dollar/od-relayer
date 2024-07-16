// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.7.6;

// a minimal interface to interact with Pendle TWAP oracles
interface IPOracle {
  /*///////////////////////////////////////////////////////////////
                    PT, YT, LP to SY
    //////////////////////////////////////////////////////////////*/

  function getPtToSyRate(address market, uint32 duration) external view returns (uint256);

  function getYtToSyRate(address market, uint32 duration) external view returns (uint256);

  function getLpToSyRate(address market, uint32 duration) external view returns (uint256);

  /*///////////////////////////////////////////////////////////////
                    PT, YT, LP to Asset
    //////////////////////////////////////////////////////////////*/

  /// @notice make sure you have taken into account the risk of not being able to withdraw from SY to Asset
  function getPtToAssetRate(address market, uint32 duration) external view returns (uint256);

  function getYtToAssetRate(address market, uint32 duration) external view returns (uint256);

  function getLpToAssetRate(address market, uint32 duration) external view returns (uint256);

  /**
   * A check function for the cardinality status of the market
   * @param market PendleMarket address
   * @param duration twap duration
   * @return increaseCardinalityRequired a boolean indicates whether the cardinality should be increased to serve the duration
   * @return cardinalityRequired the amount of cardinality required for the twap duration
   */
  function getOracleState(
    address market,
    uint32 duration
  )
    external
    view
    returns (bool increaseCardinalityRequired, uint16 cardinalityRequired, bool oldestObservationSatisfied);
}
