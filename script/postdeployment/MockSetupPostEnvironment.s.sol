// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;

import 'forge-std/console2.sol';
import '@script/Registry.s.sol';
import {CommonSepolia} from '@script/Common.s.sol';
import {IAlgebraFactory} from '@algebra-core/interfaces/IAlgebraFactory.sol';
import {IAlgebraPool} from '@algebra-core/interfaces/IAlgebraPool.sol';
import {IBaseOracle} from '@interfaces/oracles/IBaseOracle.sol';
import {MintableERC20} from '@contracts/for-test/MintableERC20.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Router} from '@contracts/for-test/Router.sol';

// BROADCAST
// source .env && forge script MockSetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC --broadcast --verify --etherscan-api-key $ARB_ETHERSCAN_API_KEY

// SIMULATE
// source .env && forge script MockSetupPostEnvironment --with-gas-price 2000000000 -vvvvv --rpc-url $ARB_SEPOLIA_RPC

contract MockSetupPostEnvironment is CommonSepolia {
  IAlgebraFactory public algebraFactory = IAlgebraFactory(SEPOLIA_ALGEBRA_FACTORY);
  MintableERC20 public mockWeth;

  function run() public {
    vm.startBroadcast(vm.envUint('ARB_SEPOLIA_DEPLOYER_PK'));
    mockWeth = new MintableERC20('Wrapped ETH', 'WETH', 18);

    algebraFactory.createPool(SEPOLIA_SYSTEM_COIN, address(mockWeth));
    address _pool = algebraFactory.poolByPair(SEPOLIA_SYSTEM_COIN, address(mockWeth));

    uint160 _sqrtPriceX96 = initialPrice(INIT_OD_AMOUNT, INIT_WETH_AMOUNT, _pool);
    IAlgebraPool(_pool).initialize(_sqrtPriceX96);

    IBaseOracle _odWethOracle = camelotRelayerFactory.deployAlgebraRelayer(
      SEPOLIA_ALGEBRA_FACTORY, SEPOLIA_SYSTEM_COIN, address(mockWeth), uint32(ORACLE_INTERVAL_TEST)
    );

    IBaseOracle chainlinkEthUSDPriceFeed =
      chainlinkRelayerFactory.deployChainlinkRelayer(SEPOLIA_CHAINLINK_ETH_USD_FEED, ORACLE_INTERVAL_TEST);

    // deploy systemOracle
    denominatedOracleFactory.deployDenominatedOracle(_odWethOracle, chainlinkEthUSDPriceFeed, false);

    authOnlyFactories();

    // check pool balance before
    IERC20(SEPOLIA_SYSTEM_COIN).balanceOf(_pool);
    IERC20(mockWeth).balanceOf(_pool);

    // mint SystemCoin and Weth to use as liquidity
    mintSystemCoin();
    mintMockWeth();

    // deploy Router for AlgebraPool
    Router _router = new Router(IAlgebraPool(_pool), deployer);

    // approve tokens to Router
    IERC20(SEPOLIA_SYSTEM_COIN).approve(address(_router), MINT_AMOUNT);
    IERC20(mockWeth).approve(address(_router), MINT_AMOUNT);

    // add liquidity
    (int24 bottomTick, int24 topTick) = generateTickParams(IAlgebraPool(_pool));
    _router.addLiquidity(bottomTick, topTick, uint128(100));

    // check pool balance after
    IERC20(SEPOLIA_SYSTEM_COIN).balanceOf(_pool);
    IERC20(mockWeth).balanceOf(_pool);

    vm.stopBroadcast();
  }

  function mintMockWeth() public {
    mockWeth.mint(deployer, MINT_AMOUNT);
  }

  function mintSystemCoin() public {
    (bool ok,) =
      SEPOLIA_SYSTEM_COIN.call{value: 0}(abi.encodeWithSignature('mint(address,uint256)', deployer, MINT_AMOUNT));
    require(ok, 'MintFail');
  }

  function generateTickParams(IAlgebraPool pool) public view returns (int24 bottomTick, int24 topTick) {
    (, int24 tick,,,,,) = pool.globalState();
    int24 tickSpacing = pool.tickSpacing();
    bottomTick = ((tick / tickSpacing) * tickSpacing) - 3 * tickSpacing;
    topTick = ((tick / tickSpacing) * tickSpacing) + 3 * tickSpacing;
  }
}
