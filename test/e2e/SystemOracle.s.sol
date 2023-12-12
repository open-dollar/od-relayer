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
import {DenominatedOracle} from '@contracts/oracles/DenominatedOracle.sol';
import {IDenominatedOracle} from '@interfaces/oracles/IDenominatedOracle.sol';

/**
 * @dev ARBTIRUM_BLOCK == ETHEREUM_BLOCK
 * rollFork is set to ARBTIRUM_BLOCK, however
 * block.number will be read as ETHEREUM_BLOCK
 *
 * price information @ Dec-11-2023 approx. 11:27 PM +UTC
 * ETH = 2217.50 USD
 * ARB = 1.0768 USD
 */
contract OracleSetup is DSTestPlus {
  // using Math for uint256;

  uint256 ARBTIRUM_BLOCK = 159_201_690; // (Dec-11-2023 11:29:40 PM +UTC)
  uint256 ETHEREUM_BLOCK = 18_766_228; // (Dec-11-2023 11:26:35 PM +UTC)

  // price w/ 18 decimals
  uint256 CHAINLINK_ETH_USD_PRICE_H = 2_218_500_000_000_000_000_000; // +1 USD
  uint256 CHAINLINK_ETH_USD_PRICE_M = 2_217_500_000_000_000_000_000; // approx. price of ETH in USD
  uint256 CHAINLINK_ETH_USD_PRICE_L = 2_216_500_000_000_000_000_000; // -1 USD

  // price w/ 6 decimals
  int256 ETH_USD_PRICE_H = 221_850_000_000; // +1 USD
  int256 ETH_USD_PRICE_M = 221_750_000_000; // approx. price of ETH in USD
  int256 ETH_USD_PRICE_L = 221_650_000_000; // -1 USD

  uint256 CHAINLINK_ETH_ARB_PRICE = 965_000_000_000_000_000; // NOTE: 18 decimals

  uint256 ETH_ARB_PRICE = 2_046_975_875_739_099_288_474; // price of ETH in ARB
  uint256 ARB_ETH_PRICE = 488_525_542_412_135; // price of ARB in ETH
  uint256 ARB_USD_PRICE = 1_083_214_437_815_195_905; // price of ARB in USD
  uint256 USD_ARB_PRICE = 923_178_241_620_339_420; // price of USD in ARB

  // uint256 NEW_ETH_USD_PRICE = 200_000_000_000;
  // uint256 NEW_ETH_USD_PRICE_18_DECIMALS = 2_000_000_000_000_000_000_000;

  // CHANGED time

  IBaseOracle public ethUsdPriceSource; // from Chainlink
  IBaseOracle public ethArbPriceSource; // from Camelot pool
  IBaseOracle public arbEthPriceSource; // from Camelot pool

  IDenominatedOracle public arbUsdPriceSource;
  IDenominatedOracle public arbUsdPriceSourceInverted;

  /**
   * @dev Arbitrum block.number returns L1; createSelectFork does not work
   */
  function setUp() public {
    uint256 forkId = vm.createFork(vm.rpcUrl('mainnet'));
    vm.selectFork(forkId);
    vm.rollFork(ARBTIRUM_BLOCK);

    // --- Chainlink ---
    ethUsdPriceSource = IBaseOracle(address(new ChainlinkRelayer(CHAINLINK_ETH_USD_FEED, 1 days)));

    // --- Camelot ---
    arbEthPriceSource = IBaseOracle(address(new Relayer(MAINNET_ALGEBRA_FACTORY, ARB, ETH, 1 days))); // correct
    ethArbPriceSource = IBaseOracle(address(new Relayer(MAINNET_ALGEBRA_FACTORY, ETH, ARB, 1 days))); // inverted

    // --- Denominated ---
    arbUsdPriceSource = IDenominatedOracle(address(new DenominatedOracle(arbEthPriceSource, ethUsdPriceSource, false)));
    arbUsdPriceSourceInverted =
      IDenominatedOracle(address(new DenominatedOracle(ethArbPriceSource, ethUsdPriceSource, true)));
  }

  function test_ArbitrumFork() public {
    emit log_named_uint('L1 Block Number Oracle Fork', block.number);
    assertEq(block.number, ETHEREUM_BLOCK);
  }

  // --- Chainlink ---

  function test_ChainlinkOracle() public {
    int256 price = IChainlinkOracle(CHAINLINK_ETH_USD_FEED).latestAnswer();
    assertTrue(price >= ETH_USD_PRICE_L && price <= ETH_USD_PRICE_H);
  }

  function test_ChainlinkRelayer() public {
    uint256 price = ethUsdPriceSource.read();
    assertTrue(price >= CHAINLINK_ETH_USD_PRICE_L && price <= CHAINLINK_ETH_USD_PRICE_H);
  }

  function test_ChainlinkRelayerSymbol() public {
    assertEq(ethUsdPriceSource.symbol(), 'ETH / USD');
  }

  // --- Algebra ---

  function test_Relayer() public {
    assertEq(arbEthPriceSource.read(), ARB_ETH_PRICE);
  }

  function test_RelayerSymbol() public {
    assertEq(arbEthPriceSource.symbol(), 'ARB / WETH');
  }

  function test_Relayer_Inverted() public {
    assertEq(ethArbPriceSource.read(), ETH_ARB_PRICE);
  }

  function test_RelayerSymbolInverted() public {
    assertEq(ethArbPriceSource.symbol(), 'WETH / ARB');
  }

  // --- Denominated ---

  function test_DenominatedOracle() public {
    assertEq(arbUsdPriceSource.read(), ARB_USD_PRICE);
  }

  function test_DenominatedOracleSymbol() public {
    assertEq(arbUsdPriceSource.symbol(), '(ARB / WETH) * (ETH / USD)');
  }

  function test_DenominatedInvertedOracle() public {
    assertEq(arbUsdPriceSourceInverted.read(), ARB_USD_PRICE);
  }

  function test_DenominatedOracleInvertedSymbol() public {
    IDenominatedOracle arbUsdPriceSourceInvert =
      IDenominatedOracle(address(new DenominatedOracle(ethArbPriceSource, ethUsdPriceSource, true)));

    assertEq(arbUsdPriceSourceInvert.symbol(), '(WETH / ARB)^-1 / (ETH / USD)');
  }
}
