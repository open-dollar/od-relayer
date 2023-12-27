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

  uint256 constant INIT_WETH = 1 ether;
  uint256 constant INIT_OD = 2221.3997 ether;

  IAlgebraFactory public algebraFactory = IAlgebraFactory(SEPOLIA_ALGEBRA_FACTORY);
  CamelotRelayerFactory public camelotRelayerFactory;
  ChainlinkRelayerFactory public chainlinkRelayerFactory;
  DenominatedOracleFactory public denominatedOracleFactory;

  MintableERC20 public mockWeth;
  IERC20Metadata public token0;
  IERC20Metadata public token1;

  address public pool;

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

    require(keccak256(abi.encodePacked('WETH')) == keccak256(abi.encodePacked(token0.symbol())), '!WETH');
    require(keccak256(abi.encodePacked('OD')) == keccak256(abi.encodePacked(token1.symbol())), '!OD');

    uint256 _price = ((INIT_WETH * WAD) / INIT_OD);

    uint256 _sqrtPriceX96 = Sqrt.sqrtAbs(int256(_price)) * (2 ** 96);

    IAlgebraPool(pool).initialize(uint160(_sqrtPriceX96));

    IBaseOracle _odWethOracle = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, SEPOLIA_SYSTEM_COIN, SEPOLIA_WETH, uint32(ORACLE_INTERVAL_TEST)
    );

    IBaseOracle chainlinkEthUSDPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(SEPOLIA_CHAINLINK_ETH_USD_FEED, ORACLE_INTERVAL_TEST);

    // deploy systemOracle
    denominatedOracleFactory.deployDenominatedOracle(_odWethOracle, chainlinkEthUSDPriceFeed, false);
  }

  function testPoolPrice() public {
    IAlgebraPool _pool = IAlgebraPool(pool);
    (uint160 sqrtPriceX96,,,,,,) = _pool.globalState();

    emit log_named_uint('sqrtPriceX96', sqrtPriceX96);

    uint256 price = (SafeMath.div(uint256(sqrtPriceX96), (2 ** 96))) ** 2;

    // 1 / 2221.3997 = 0.000450166605436900 price of OD in terms of WETH
    emit log_named_uint('Price from LPool', price);
    emit log_named_uint('Price Calculated', (INIT_WETH * WAD) / INIT_OD);
  }
}
