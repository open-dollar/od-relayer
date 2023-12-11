// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

import {
  MAINNET_ALGEBRA_FACTORY,
  CHAINLINK_ETH_USD_FEED,
  CHAINLINK_ARB_USD_FEED,
  ETH,
  ARB,
  ETH_ARB_POOL
} from '@script/Registry.s.sol';
import {DSTestPlus} from '@test/utils/DSTestPlus.t.sol';
import {Relayer} from '@contracts/oracles/Relayer.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {ChainlinkRelayer} from '@contracts/oracles/ChainlinkRelayer.sol';
import {IChainlinkOracle} from '@interfaces/oracles/IChainlinkOracle.sol';

// add denominated oracle
// import MATH, WAD from Math lib?

contract OracleSetup is DSTestPlus {
  // using Math for uint256;

  uint256 FORK_BLOCK;
  uint256 FORK_CHANGE;

  uint256 CHAINLINK_ETH_USD_PRICE_18_DECIMALS = 1_097_858_600_000_000_000_000;
  uint256 CHAINLINK_ETH_ARB_PRICE = 965_000_000_000_000_000; // NOTE: 18 decimals

  int256 ETH_USD_PRICE_L = 107_800_000_000;
  int256 ETH_USD_PRICE_H = 120_200_000_000;

  uint256 NEW_ETH_USD_PRICE = 200_000_000_000;
  uint256 NEW_ETH_USD_PRICE_18_DECIMALS = 2_000_000_000_000_000_000_000;

  IBaseOracle public ethUsdPriceSource; // from Chainlink
  IBaseOracle public ethArbPriceSource; // from Camelot pool

  // IDenominatedOracle public wstethUsdPriceSource;

  /**
   * @dev Arbitrum block.number returns L1; createSelectFork does not work
   */
  function setUp() public {
    uint256 forkId = vm.createFork(vm.rpcUrl('mainnet'));
    vm.selectFork(forkId);
    vm.rollFork(FORK_BLOCK);

    // --- Chainlink ---
    ethUsdPriceSource = IBaseOracle(address(new ChainlinkRelayer(CHAINLINK_ETH_USD_FEED, 1 days)));

    // --- UniV3 ---
    ethArbPriceSource = IBaseOracle(address(new Relayer(MAINNET_ALGEBRA_FACTORY, ETH, ARB, 1 days)));

    // --- Denominated ---
    // arbUsdPriceSource = new DenominatedOracle(wstethEthPriceSource, ethUsdPriceSource, false);
  }

  function test_ArbitrumFork() public {
    emit log_named_uint('L1 Block Number Oracle Fork', block.number);
    assertEq(block.number, FORK_CHANGE);
  }

  // --- Chainlink ---

  // function test_ChainlinkOracle() public {
  //   int256 price = IChainlinkOracle(CHAINLINK_ETH_USD_FEED).latestAnswer();
  //   assertTrue(price >= ETH_USD_PRICE_L && price <= ETH_USD_PRICE_H);
  // }

  // function test_ChainlinkRelayer() public {
  //   assertEq(CHAINLINK_ETH_USD_PRICE_18_DECIMALS / 1e18, 1097);
  //   assertEq(ethUsdPriceSource.read(), CHAINLINK_ETH_USD_PRICE_18_DECIMALS);
  // }

  // function test_ChainlinkRelayerStalePrice() public {
  //   vm.warp(block.timestamp + 1 days);
  //   vm.expectRevert();

  //   ethUsdPriceSource.read();
  // }

  // function test_ChainlinkRelayerSymbol() public {
  //   assertEq(ethUsdPriceSource.symbol(), 'ETH / USD');
  // }

  // --- UniV3 ---

  /**
   * @dev This method may revert with 'OLD!' if the pool doesn't have enough cardinality or initialized history
   */
  // function test_UniV3Relayer() public {
  //   assertEq(ethArbPriceSource.read(), WBTC_ETH_PRICE);
  //   emit log_string('OLD; pool lacks cardinality or initialized history!');
  // }

  // function test_UniV3RelayerSymbol() public {
  //   assertEq(ethArbPriceSource.symbol(), 'CBETH / WSTETH');
  // }

  // --- Denominated ---

  /**
   * @dev This method may revert with 'OLD!' if the pool doesn't have enough cardinality or initialized history
   */
  // function test_DenominatedOracleUniV3() public {
  //   assertEq(WBTC_USD_PRICE / 1e18, 27_032); // 14.864 * 1818.65 = 27032
  //   assertEq(wbtcUsdPriceSource.read(), WBTC_USD_PRICE);
  //   emit log_string('OLD; pool lacks cardinality or initialized history!');
  // }

  // function test_DenominatedOracleSymbol() public {
  //   // assertEq(wstethUsdPriceSource.symbol(), '(WSTETH / ETH) * (ETH / USD)');
  //   emit log_string('(wstETH-stETH Exchange Rate) * (ETH / USD) => should be: (WSTETH / ETH) * (ETH / USD)');
  // }

  /**
   * NOTE: In this case, the symbols are ETH/USD - ETH/USD
   *       Using inverted = true, the resulting symbols are USD/ETH - ETH/USD
   */
  // function test_DenominatedOracleInverted() public {
  //   IDenominatedOracle usdPriceSource = new DenominatedOracle(ethUsdPriceSource, ethUsdPriceSource, true);

  //   assertApproxEqAbs(usdPriceSource.read(), WAD, 1e9); // 1 USD = 1 USD (with 18 decimals)
  // }

  // function test_DenominatedOracleInvertedSymbol() public {
  //   IDenominatedOracle usdPriceSource = new DenominatedOracle(ethUsdPriceSource, ethUsdPriceSource, true);

  //   assertEq(usdPriceSource.symbol(), '(ETH / USD)^-1 / (ETH / USD)');
  // }
}
