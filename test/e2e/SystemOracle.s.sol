// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

import {
  MAINNET_ALGEBRA_FACTORY,
  MAINNET_CHAINLINK_ETH_USD_FEED,
  MAINNET_CHAINLINK_ARB_USD_FEED,
  MAINNET_CHAINLINK_SEQUENCER_FEED,
  ETH,
  ARB,
  ETH_ARB_POOL
} from '@script/Registry.s.sol';
import {DSTestPlus} from '@test/utils/DSTestPlus.t.sol';
import {CamelotRelayer} from '@contracts/oracles/CamelotRelayer.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {ChainlinkRelayer} from '@contracts/oracles/ChainlinkRelayer.sol';
import {ChainlinkRelayerWithL2Validity} from '@contracts/oracles/ChainlinkRelayerWithL2Validity.sol';
import {IChainlinkRelayer} from '@interfaces/oracles/IChainlinkRelayer.sol';
import {IChainlinkOracle} from '@interfaces/oracles/IChainlinkOracle.sol';
import {DenominatedOracle} from '@contracts/oracles/DenominatedOracle.sol';
import {IDenominatedOracle} from '@interfaces/oracles/IDenominatedOracle.sol';
import {MockSequencerFeed} from '@contracts/for-test/MockSequencerFeed.sol';

// forge test --match-contract OracleSetup -vvv

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
  uint256 public constant ARBTIRUM_BLOCK = 159_201_690; // (Dec-11-2023 11:29:40 PM +UTC)
  uint256 public constant ETHEREUM_BLOCK = 18_766_228; // (Dec-11-2023 11:26:35 PM +UTC)

  // price w/ 18 decimals
  uint256 public constant CHAINLINK_ETH_USD_PRICE_H = 2_218_500_000_000_000_000_000; // +1 USD
  uint256 public constant CHAINLINK_ETH_USD_PRICE_M = 2_217_500_000_000_000_000_000; // approx. price of ETH in USD
  uint256 public constant CHAINLINK_ETH_USD_PRICE_L = 2_216_500_000_000_000_000_000; // -1 USD

  // price w/ 6 decimals
  int256 public constant ETH_USD_PRICE_H = 221_850_000_000; // +1 USD
  int256 public constant ETH_USD_PRICE_M = 221_750_000_000; // approx. price of ETH in USD
  int256 public constant ETH_USD_PRICE_L = 221_650_000_000; // -1 USD

  uint256 public constant CHAINLINK_ETH_ARB_PRICE = 965_000_000_000_000_000; // NOTE: 18 decimals

  uint256 public constant ETH_ARB_PRICE = 2_046_975_875_739_099_288_474; // price of ETH in ARB
  uint256 public constant ARB_ETH_PRICE = 488_525_542_412_135; // price of ARB in ETH
  uint256 public constant ARB_USD_PRICE = 1_083_214_437_815_195_905; // price of ARB in USD
  uint256 public constant USD_ARB_PRICE = 923_178_241_620_339_420; // price of USD in ARB

  uint256 public constant GRACE_PERIOD = 1 hours;
  uint32 public constant STALE_PRICE = 1 days;
  int256 public constant UP = 0;
  int256 public constant DOWN = 1;

  uint256 public startTime;

  IBaseOracle public ethUsdPriceSource; // from Chainlink
  IBaseOracle public ethUsdPriceSourceL2Verified; // from Chainlink
  IBaseOracle public ethUsdPriceSourceL2VerifiedMock; // from Chainlink
  IBaseOracle public ethArbPriceSource; // from Camelot pool
  IBaseOracle public arbEthPriceSource; // from Camelot pool

  IDenominatedOracle public arbUsdPriceSource;
  IDenominatedOracle public arbUsdPriceSourceL2Verified;
  IDenominatedOracle public arbUsdPriceSourceInverted;

  MockSequencerFeed public mockSeqFeed;

  /**
   * @dev Arbitrum block.number returns L1; createSelectFork does not work
   */
  function setUp() public {
    uint256 forkId = vm.createFork(vm.rpcUrl('mainnet'));
    vm.selectFork(forkId);
    vm.rollFork(ARBTIRUM_BLOCK);

    mockSeqFeed = new MockSequencerFeed();
    startTime = block.timestamp;

    // --- Chainlink ---
    ethUsdPriceSource = IBaseOracle(address(new ChainlinkRelayer(MAINNET_CHAINLINK_ETH_USD_FEED, STALE_PRICE)));
    ethUsdPriceSourceL2Verified = IBaseOracle(
      address(
        new ChainlinkRelayerWithL2Validity(
          MAINNET_CHAINLINK_ETH_USD_FEED, MAINNET_CHAINLINK_SEQUENCER_FEED, STALE_PRICE, GRACE_PERIOD
        )
      )
    );
    ethUsdPriceSourceL2VerifiedMock = IBaseOracle(
      address(
        new ChainlinkRelayerWithL2Validity(
          MAINNET_CHAINLINK_ETH_USD_FEED, address(mockSeqFeed), STALE_PRICE, GRACE_PERIOD
        )
      )
    );

    // --- Camelot ---
    arbEthPriceSource = IBaseOracle(address(new CamelotRelayer(MAINNET_ALGEBRA_FACTORY, ARB, ETH, STALE_PRICE))); // correct
    ethArbPriceSource = IBaseOracle(address(new CamelotRelayer(MAINNET_ALGEBRA_FACTORY, ETH, ARB, STALE_PRICE))); // inverted

    // --- Denominated ---
    arbUsdPriceSource = IDenominatedOracle(address(new DenominatedOracle(arbEthPriceSource, ethUsdPriceSource, false)));
    arbUsdPriceSourceL2Verified =
      IDenominatedOracle(address(new DenominatedOracle(arbEthPriceSource, ethUsdPriceSourceL2Verified, false)));
    arbUsdPriceSourceInverted =
      IDenominatedOracle(address(new DenominatedOracle(ethArbPriceSource, ethUsdPriceSource, true)));
  }

  // --- Setup ---

  function test_ArbitrumFork() public {
    emit log_named_uint('L1 Block Number Oracle Fork', block.number);
    assertEq(block.number, ETHEREUM_BLOCK);
  }

  function test_MockSequencerFeedUp() public {
    assertEq(mockSeqFeed.answer(), UP);
    assertEq(mockSeqFeed.startedAt(), startTime);
    (uint256 _roundId, int256 _answer, uint256 _startedAt, uint256 _updatedAt, uint256 _answeredInRound) =
      mockSeqFeed.latestRoundData();
    assertEq(_roundId, 1);
    assertEq(_answer, UP);
    assertEq(_startedAt, startTime);
    assertEq(_updatedAt, 1);
    assertEq(_answeredInRound, 1);
  }

  function test_MockSequencerFeedDown() public {
    mockSeqFeed.switchSequencer();
    assertEq(mockSeqFeed.answer(), DOWN);
    (uint256 _roundId, int256 _answer, uint256 _startedAt, uint256 _updatedAt, uint256 _answeredInRound) =
      mockSeqFeed.latestRoundData();
    assertEq(_roundId, 1);
    assertEq(_answer, DOWN);
    assertEq(_startedAt, startTime);
    assertEq(_updatedAt, 1);
    assertEq(_answeredInRound, 1);
  }

  // --- Chainlink ---
  function test_ChainlinkOracle() public {
    int256 price = IChainlinkOracle(MAINNET_CHAINLINK_ETH_USD_FEED).latestAnswer();
    assertTrue(price >= ETH_USD_PRICE_L && price <= ETH_USD_PRICE_H);
  }

  function test_InitializeChainlinkRelayer() public {
    vm.expectRevert();
    new ChainlinkRelayer(address(0), STALE_PRICE);
    vm.expectRevert();
    new ChainlinkRelayer(address(0x1234), 0);
  }

  function test_ChainlinkRelayer() public {
    uint256 price = ethUsdPriceSource.read();
    assertTrue(price >= CHAINLINK_ETH_USD_PRICE_L && price <= CHAINLINK_ETH_USD_PRICE_H);
  }

  function test_ChainlinkRelayerWithValidity() public {
    (uint256 price, bool valid) = ethUsdPriceSource.getResultWithValidity();
    assertTrue(valid);
    assertTrue(price >= CHAINLINK_ETH_USD_PRICE_L && price <= CHAINLINK_ETH_USD_PRICE_H);
  }

  function test_ChainlinkRelayerSymbol() public {
    assertEq(ethUsdPriceSource.symbol(), 'ETH / USD');
  }

  function test_InitializeChainlinkRelayerL2Verified() public {
    ChainlinkRelayerWithL2Validity _testRelayer;
    vm.expectRevert();
    _testRelayer = new ChainlinkRelayerWithL2Validity(address(0), address(0x1234), STALE_PRICE, GRACE_PERIOD);
    vm.expectRevert();
    _testRelayer = new ChainlinkRelayerWithL2Validity(address(0x1234), address(0), STALE_PRICE, GRACE_PERIOD);
    vm.expectRevert();
    _testRelayer = new ChainlinkRelayerWithL2Validity(address(0x1234), address(0x1234), 0, GRACE_PERIOD);
    vm.expectRevert();
    _testRelayer = new ChainlinkRelayerWithL2Validity(address(0x1234), address(0x1234), STALE_PRICE, 0);
  }

  function test_ChainlinkRelayerL2Verified() public {
    uint256 price = ethUsdPriceSourceL2Verified.read();
    assertTrue(price >= CHAINLINK_ETH_USD_PRICE_L && price <= CHAINLINK_ETH_USD_PRICE_H);
  }

  function test_ChainlinkRelayerL2VerifiedWithValidity() public {
    (uint256 price, bool valid) = ethUsdPriceSourceL2Verified.getResultWithValidity();
    assertTrue(valid);
    assertTrue(price >= CHAINLINK_ETH_USD_PRICE_L && price <= CHAINLINK_ETH_USD_PRICE_H);
  }

  function test_ChainlinkRelayerL2Verified_RevertAfterInit() public {
    vm.expectRevert('SequencerDown');
    ethUsdPriceSourceL2VerifiedMock.read(); // sequencer up, grace period deny
    (uint256 _result, bool _validity) = ethUsdPriceSourceL2VerifiedMock.getResultWithValidity();
    assertFalse(_validity);
  }

  function test_ChainlinkRelayerL2Verified_RevertGracePeriod() public {
    vm.warp(startTime + GRACE_PERIOD - 1);
    vm.expectRevert('SequencerDown'); // sequencer up, grace period deny
    ethUsdPriceSourceL2VerifiedMock.read();
    (uint256 _result, bool _validity) = ethUsdPriceSourceL2VerifiedMock.getResultWithValidity();
    assertFalse(_validity);
  }

  function test_ChainlinkRelayerL2Verified_RevertNetworkDown() public {
    vm.warp(startTime + GRACE_PERIOD);
    mockSeqFeed.switchSequencer();
    vm.expectRevert('SequencerDown'); // sequencer down, grace period accept
    ethUsdPriceSourceL2VerifiedMock.read();
    (uint256 _result, bool _validity) = ethUsdPriceSourceL2VerifiedMock.getResultWithValidity();
    assertFalse(_validity);
  }

  function test_ChainlinkRelayerL2Verified_RevertAll() public {
    vm.warp(startTime + GRACE_PERIOD - 1);
    mockSeqFeed.switchSequencer();
    vm.expectRevert('SequencerDown'); // sequencer down, grace period deny
    ethUsdPriceSourceL2VerifiedMock.read();
    (uint256 _result, bool _validity) = ethUsdPriceSourceL2VerifiedMock.getResultWithValidity();
    assertFalse(_validity);
  }

  function test_ChainlinkRelayerSymbolL2Verified() public {
    assertEq(ethUsdPriceSourceL2Verified.symbol(), 'ETH / USD');
  }

  // --- Algebra/Camelot ---

  function test_CamelotRelayer() public {
    assertEq(arbEthPriceSource.read(), ARB_ETH_PRICE);
  }

  function test_CamelotRelayerSymbol() public {
    assertEq(arbEthPriceSource.symbol(), 'ARB / WETH');
  }

  function test_CamelotRelayer_Inverted() public {
    assertEq(ethArbPriceSource.read(), ETH_ARB_PRICE);
  }

  function test_CamelotRelayerSymbolInverted() public {
    assertEq(ethArbPriceSource.symbol(), 'WETH / ARB');
  }

  // --- Denominated ---

  function test_DenominatedOracle() public {
    assertEq(arbUsdPriceSource.read(), ARB_USD_PRICE);
  }

  function test_DenominatedOracleL2Verified() public {
    assertEq(arbUsdPriceSourceL2Verified.read(), ARB_USD_PRICE);
  }

  function test_DenominatedOracleSymbol() public {
    assertEq(arbUsdPriceSource.symbol(), '(ARB / WETH) * (ETH / USD)');
  }

  function test_DenominatedOracleSymbolL2Verified() public {
    assertEq(arbUsdPriceSourceL2Verified.symbol(), '(ARB / WETH) * (ETH / USD)');
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
