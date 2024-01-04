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
    // mockOd = new MintableERC20('Open Dollar', 'OD', 18);

    algebraFactory.createPool(SEPOLIA_SYSTEM_COIN, address(mockWeth));
    pool = algebraFactory.poolByPair(SEPOLIA_SYSTEM_COIN, address(mockWeth));

    token0 = IERC20Metadata(IAlgebraPool(pool).token0());
    token1 = IERC20Metadata(IAlgebraPool(pool).token1());

    require(keccak256(abi.encodePacked('WETH')) == keccak256(abi.encodePacked(token0.symbol())), '!WETH');
    require(keccak256(abi.encodePacked('OD')) == keccak256(abi.encodePacked(token1.symbol())), '!OD');

    initPrice = ((INIT_WETH_AMOUNT * WAD) / INIT_OD_AMOUNT);

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

  // needs to be predeployed
  function testCamelotRelayerPrice() public {
    uint256 _result = camelotOdWethOracle.read();
    emit log_named_uint('Camelot OD/WETH', _result); //  / 1e18 =

    assertApproxEqAbs(initPrice, _result, 100_000_000); // 0.000000000100000000 variability
  }

  // function testDenominatedOraclePrice() public {}
}
