// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
pragma abicoder v2;

import 'forge-std/Test.sol';
import '@script/Registry.s.sol';
import {SafeMath} from '@openzeppelin/contracts/math/SafeMath.sol';
import {Sqrt} from '@algebra-core/libraries/Sqrt.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {CamelotRelayerFactory} from '@contracts/factories/CamelotRelayerFactory.sol';
import {ChainlinkRelayerFactory} from '@contracts/factories/ChainlinkRelayerFactory.sol';
import {DenominatedOracleFactory} from '@contracts/factories/DenominatedOracleFactory.sol';
import {IERC20Metadata} from '@algebra-periphery/interfaces/IERC20Metadata.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';

// forge test --match-contract QMath -vvvvv

/**
 * @dev large price fluctuations in the price of ETH may break these tests
 * in the case of large price fluctuation, adjust INIT_OD_AMOUNT in the Registry to set OD / ETH price
 */
contract QMath is Test {
  using SafeMath for uint256;

  // -- Factories --
  IAlgebraFactory public algebraFactory = IAlgebraFactory(SEPOLIA_ALGEBRA_FACTORY);
  CamelotRelayerFactory public camelotRelayerFactory;
  ChainlinkRelayerFactory public chainlinkRelayerFactory;
  DenominatedOracleFactory public denominatedOracleFactory;

  // -- Tokens --
  MintableERC20 public mockWeth;
  IERC20Metadata public token0;
  IERC20Metadata public token1;

  // -- Liquidity Pool --
  address public pool;
  uint256 public initPrice;

  // -- Relayers
  IBaseOracle public camelotOdWethOracle;
  IBaseOracle public chainlinkEthUSDPriceFeed;
  IBaseOracle public systemOracle;

  function setUp() public {
    uint256 forkId = vm.createFork(vm.rpcUrl('sepolia'));
    vm.selectFork(forkId);
    camelotRelayerFactory = new CamelotRelayerFactory();
    chainlinkRelayerFactory = new ChainlinkRelayerFactory();
    denominatedOracleFactory = new DenominatedOracleFactory();

    mockWeth = new MintableERC20('Wrapped ETH', 'WETH', 18);

    algebraFactory.createPool(SEPOLIA_SYSTEM_COIN, address(mockWeth));
    pool = algebraFactory.poolByPair(SEPOLIA_SYSTEM_COIN, address(mockWeth));

    token0 = IERC20Metadata(IAlgebraPool(pool).token0());
    token1 = IERC20Metadata(IAlgebraPool(pool).token1());

    uint256 inverted;

    // price = token1 / token0
    if (address(token0) == SEPOLIA_SYSTEM_COIN) {
      require(keccak256(abi.encodePacked('OD')) == keccak256(abi.encodePacked(token0.symbol())), '!OD');
      initPrice = ((INIT_WETH_AMOUNT * WAD) / INIT_OD_AMOUNT);
    } else {
      require(keccak256(abi.encodePacked('WETH')) == keccak256(abi.encodePacked(token0.symbol())), '!WETH');
      initPrice = ((INIT_OD_AMOUNT * WAD) / INIT_WETH_AMOUNT);
      inverted = 1;
    }

    emit log_named_uint('Inverted', inverted);

    uint256 _sqrtPriceX96 = Sqrt.sqrtAbs(int256(initPrice)) * (2 ** 96);

    IAlgebraPool(pool).initialize(uint160(_sqrtPriceX96));

    camelotOdWethOracle = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, SEPOLIA_SYSTEM_COIN, address(mockWeth), uint32(ORACLE_INTERVAL_TEST)
    );

    chainlinkEthUSDPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(SEPOLIA_CHAINLINK_ETH_USD_FEED, ORACLE_INTERVAL_TEST);

    systemOracle =
      denominatedOracleFactory.deployDenominatedOracle(camelotOdWethOracle, chainlinkEthUSDPriceFeed, false);
  }

  function testPoolPrice() public {
    IAlgebraPool _pool = IAlgebraPool(pool);
    (uint160 _sqrtPriceX96,,,,,,) = _pool.globalState();

    emit log_named_uint('sqrtPriceX96', _sqrtPriceX96);

    uint256 _price = (SafeMath.div(uint256(_sqrtPriceX96), (2 ** 96))) ** 2;
    assertApproxEqAbs(initPrice, _price, 100_000_000); // 0.000000000100000000 variability

    // 1 / 2221.3997 = 0.000450166605436900 price of OD in terms of WETH
    emit log_named_uint('Price from LPool', _price);
    emit log_named_uint('Price Calculated', (INIT_WETH_AMOUNT * WAD) / INIT_OD_AMOUNT);
  }

  function testChainlinkRelayerPrice() public {
    uint256 _result = chainlinkEthUSDPriceFeed.read();
    emit log_named_uint('Chainlink ETH/USD', _result); // 2347556500000000000000 / 1e18 = 2347.556500000000000000

    assertApproxEqAbs(INIT_OD_AMOUNT / 1e18, _result / 1e18, 500); // $500 flux
  }

  function testCamelotRelayerPrice() public {
    vm.warp(block.timestamp + 1 minutes + 1 seconds);
    uint256 _result = camelotOdWethOracle.read();
    emit log_named_uint('Camelot OD/WETH', _result);

    assertApproxEqAbs((INIT_OD_AMOUNT * _result) / 1e18, 1 ether, 0.1 ether); // 1 USD
  }

  function testOldCamelotRelayerPrice() public {
    vm.expectRevert(bytes('OLD'));
    camelotOdWethOracle.read();
  }
}
